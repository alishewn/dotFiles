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
## RISC-V Fedora on Qemu with Details

1. Make working directories as you like.

    ```bash
    export WORK_SPACE="/home/pennix/dev/riscv_fedora_on_qemu"
    mkdir -p ${WORK_SPACE}/{fw_repos,3rd-resrcs}
    ```
2. fetch necessary firmwares.

    ```bash
    git clone https://github.com/u-boot/u-boot.git ${WORK_SPACE}/fw_repos/u-boot
    git clone https://github.com/riscv-software-src/opensbi.git ${WORK_SPACE}/fw_repos/opensbi
    git clone https://github.com/qemu/qemu.git ${WORK_SPACE}/fw_repos/qemu
    ```
3. openssl on current Host OS may be incompatible with u-boot, build it from source code and make it visible.

    ```bash
    pushd ${WORK_SPACE}/3rd-resrcs
    	wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
    	tar xzvf openssl-1.1.1w.tar.gz
    	cd openssl-1.1.1w && mkdir build
    	./Configure linux-x86_64 --prefix="$(realpath ./build)"
    	make -j32 && make install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/openssl-1.1.1w/build/lib/pkgconfig:$PKG_CONFIG_PATH
    ```
4. modify u-boot source code && build it

    ```bash
    pushd ${WORK_SPACE}/fw_repos/u-boot

    cat << EOF
    diff --git a/configs/qemu-riscv64_smode_defconfig b/configs/qemu-riscv64_smode_defconfig
    index 1d0f021ade..b78ddb76f2 100644
    --- a/configs/qemu-riscv64_smode_defconfig
    +++ b/configs/qemu-riscv64_smode_defconfig
    @@ -8,6 +8,9 @@ CONFIG_DEFAULT_DEVICE_TREE="qemu-virt64"
    CONFIG_SYS_LOAD_ADDR=0x80200000
    CONFIG_TARGET_QEMU_VIRT=y
    CONFIG_ARCH_RV64I=y
    +CONFIG_RISCV_ISA_D=y
    +CONFIG_RISCV_ISA_C=y
    +CONFIG_CMODEL_MEDANY=y
    CONFIG_RISCV_SMODE=y
    CONFIG_FIT=y
    CONFIG_DISTRO_DEFAULTS=y
    diff --git a/tools/Makefile b/tools/Makefile
    index 1aa1e36137..98059da7df 100644
    --- a/tools/Makefile
    +++ b/tools/Makefile
    @@ -168,6 +168,7 @@ ifdef CONFIG_TOOLS_LIBCRYPTO
    HOST_EXTRACFLAGS       += -DCONFIG_FIT_SIGNATURE
    HOST_EXTRACFLAGS       += -DCONFIG_FIT_SIGNATURE_MAX_SIZE=0xffffffff
    HOST_EXTRACFLAGS       += -DCONFIG_FIT_CIPHER
    +HOST_EXTRACFLAGS        += $(shell pkg-config --cflags libssl libcrypto 2> /dev/null || echo "")
    endif
    EOF | git apply

    popd
    ```

    ```bash
    pushd ${WORK_SPACE}/fw_repos/u-boot
    	# path to your own riscv toolchains
    	export CROSS_COMPILE=/home/pennix/dev/local/riscv-gnu-toolchain/bin/riscv64-unknown-linux-gnu-
    	make qemu-riscv64_smode_defconfig
    	make -j32
    popd
    ```
5. build opensbi with payload of u-boot

    ```bash
    pushd ${WORK_SPACE}/fw_repos/opensbi
    make PLATFORM=generic PLATFORM_RISCV_ABI=lp64d PLATFORM_RISCV_ISA=rv64imafdc_zicsr_zifencei \
    	PLATFORM_RISCV_XLEN=64 \
    	FW_PAYLOAD_PATH=${WORK_SPACE}/fw_repos/u-boot/u-boot.bin
    popd
    ```
6. prepare requirements of qemu using system package manager

    ```bash
    sudo apt install libaio-dev libvdeplug-dev libbrlapi-dev \
    	liblz4-dev libsasl2-dev libpam0g-dev libsnappy-dev \
    	liblzo2-dev librdmacm-dev libxen-dev valgrind
    ```

    prepare requirements of qemu from source

    ```bash
    pushd ${WORK_SPACE}/3rd-resrcs

    # liburing
    git clone https://github.com/axboe/liburing.git
    pushd liburing
    mkdir build
    ./configure --prefix="$(realpath build)"
    make -j32 && make install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/liburing/build/lib/pkgconfig:$PKG_CONFIG_PATH

    # libnfs
    git clone https://github.com/sahlberg/libnfs.git
    pushd libnfs
    ./bootstrap
    mkdir build
    ./configure --prefix="$(realpath build)"
    make -j32 && make install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/libnfs/build/lib/pkgconfig:$PKG_CONFIG_PATH

    # capstone
    git clone https://github.com/capstone-engine/capstone.git
    pushd capstone
    mkdir build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$(realpath .)"
    cmake --build . --config Release -j32
    cmake --install .
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/capstone/build/lib/pkgconfig:$PKG_CONFIG_PATH

    # [gtk3] --> virtio-gpu display frontend
    wget https://download.gnome.org/sources/gtk+/3.24/gtk+-3.24.37.tar.xz
    mkdir gtk3
    tar xJvf gtk+-3.24.37.tar.xz -C gtk3 --strip-components=1
    pushd gtk3
    mkdir build output
    meson setup --prefix="$(realpath output)"  --buildtype=release \
                -Dman=true -Dbroadway_backend=true build
    popd

    # [epoxy] --> dependency of virglrenderer
    git clone https://github.com/anholt/libepoxy.git
    pushd libepoxy
    mkdir build output
    meson setup --prefix="$(realpath output)"  --buildtype=release build
    ninja -C build -j32
    ninja -C build install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/libepoxy/output/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

    # [virgl] --> virtio-gpu backend
    git clone https://gitlab.freedesktop.org/virgl/virglrenderer.git
    pushd virglrenderer
    mkdir build output
    meson setup --prefix="$(realpath output)"  --buildtype=release build
    ninja -C build -j32
    ninja -C build install
    popd:
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/virglrenderer/output/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

    # [sdl2] --> virtio-gpu display frontend
    wget https://github.com/libsdl-org/SDL/releases/download/release-2.28.4/SDL2-2.28.4.tar.gz
    mkdir sdl2
    tar xzvf SDL2-2.28.4.tar.gz -C sdl2 --strip-components=1
    pushd sdl2
    mkdir output
    ./configure --prefix="$(realpath ./output)"
    make -j32 && make install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/sdl2/output/lib/pkgconfig:$PKG_CONFIG_PATH

    # [sdl2_image] --> virtio-gpu display frontend
    wget https://github.com/libsdl-org/SDL_image/releases/download/release-2.6.3/SDL2_image-2.6.3.tar.gz
    mkdir sdl2_image
    tar xzvf SDL2_image-2.6.3.tar.gz -C sdl2_image --strip-components=1
    pushd sdl2_image
    mkdir output
    ./configure --prefix="$(realpath ./output)"
    make -j32 && make install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/sdl2_image/output/lib/pkgconfig:$PKG_CONFIG_PATH

    # [libslirp] --> network related
    git clone https://gitlab.freedesktop.org/slirp/libslirp.git
    pushd libslirp
    mkdir build output
    meson setup --prefix="$(realpath output)"  --buildtype=release build
    ninja -C build -j32
    ninja -C build install
    popd
    export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/libslirp/output/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

    popd
    ```

    ```bash
    pushd ${WORK_SPACE}/fw_repos/qemu
    ./configure --prefix="${WORK_SPACE}/fw_repos/qemu/build" --target-list=riscv64-softmmu --disable-docs --enable-debug-tcg \
                --enable-debug --enable-debug-info -enable-trace-backends=log --enable-gtk --enable-kvm --enable-opengl --enable-slirp \
                --enable-opengl --enable-virglrenderer --enable-sdl --enable-sdl-image
    make -j32 && make install
    popd
    ```
7. runing Ubuntu 20.04 LTS

    ```bash
    ## fetch the image of ubuntu2004 and enlarge it for desktop environment
    pushd ${WORK_SPACE}/3rd-resrcs
    wget https://cdimage.ubuntu.com/releases/20.04.6/release/ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img.xz
    unxz -k ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img.xz
    ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img +20G
    popd
    ```

    ```bash
    pushd ${WORK_SPACE}/fw_repos/qemu/build

    install -m a+x /dev/null ./run_ubuntu.sh

    cat >> ./run_ubuntu.sh <<EOF
    ./qemu-system-riscv64 -machine virt -m 8G -smp cpus=4 \
    	-bios ${WORK_SPACE}/fw_repos/opensbi/build/platform/generic/firmware/fw_payload.bin \
    	-netdev user,id=net0 \
    	-device virtio-net-device,netdev=net0 \
        -drive file=${WORK_SPACE}/3rd-resrcs/ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img,format=raw,if=virtio \
        -device virtio-rng-pci \
        -serial mon:stdio \
        -vga none -device virtio-gpu-pci \
        -display gtk,gl=on,show-cursor=on \
        -full-screen \
        -device qemu-xhci \
        -device usb-kbd \
        -device usb-mouse
    EOF

    ./run_ubuntu.sh
    popd
    ```

    take a glance at the boot message of linux kernel we could easily find that

    ```shell

    ```

    after that, the Qemu graphic UI took over the display ports

    ```bash
    ## once ubuntu booted, you may use ubuntu/ubuntu to login, close qemu and restart if the shell told you wrong passwd
    ## once logged in, change the apt repo sources
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo sed -i "s/ports.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list
    ## here you can also add http(s)_proxy to your env virable to speed up the downloading process

    ## prepare the desktop environment. the procedure shall take a lot of time, wait patiently
    sudo apt-get update
    sudo apt-get install xfce4 lightdm
    ```
8. Experience of Running openSUSE

    * fetching the SUSE distro image

      ```bash
      pushd ${WORK_SPACE}/3rd-resrcs
      wget https://download.opensuse.org/ports/riscv/tumbleweed/images/openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw.xz
      unxz -k openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw.xz
      ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw +20G
      popd
      ```

    * inspired by the [Linux guest kernel configuration](https://github.com/qemu/qemu/blob/a95260486aa7e78d7c7194eba65cf03311ad94ad/docs/system/arm/virt.rst#linux-guest-kernel-configuration) part, we need to check whether following configurations were selected properly in the kernel image of the openSUSE image, as follows

      ```dsconfig
      CONFIG_PCI=y
      CONFIG_VIRTIO_PCI=y
      CONFIG_PCI_HOST_GENERIC=y

      CONFIG_DRM=y
      CONFIG_DRM_VIRTIO_GPU=y
      ```

      ```bash
      pushd ${WORK_SPACE}/3rd-resrcs

      # mount the file system of openSUSE raw image
      LOOP_DEV=$(echo $(sudo kpartx -a -v openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw) | grep -oE 'loop[[:alnum:]]*p3')
      mkdir -p /tmp/disk_img
      sudo mount /dev/mapper/${LOOP_DEV} /tmp/disk_img

      # extract the kernel config file and u-boot binary
      pushd /tmp/disk_img
      cp ./usr/lib/modules/6.5.8-1-default/config ${WORK_SPACE}/3rd-resrcs/openSUSE_kernel_defconfig
      cp ./boot/u-boot.bin ${WORK_SPACE}/3rd-resrcs/
      popd

      # umount the file system of openSUSE raw image
      sudo sync
      sudo umount /tmp/disk_img
      sudo kpartx -d -v openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw

      popd
      ```
    * notice that the `virtio-gpu-pci` module is not enabled in `openSUSE_kernel_defconfig`

      ```shell
      < CONFIG_PCI_HOST_GENERIC=y
      ---
      > # CONFIG_PCI_HOST_GENERIC is not set
      6336c6336
      < CONFIG_DRM_VIRTIO_GPU=y
      ---
      > CONFIG_DRM_VIRTIO_GPU=m
      9852c9852
      < CONFIG_MODULE_SIG_KEY=""
      ---
      > CONFIG_MODULE_SIG_KEY=".kernel_signing_key.pem"
      ```
    * surely the virtual display device driver shall not work properly, but inspired from [this](https://tutorialforlinux.com/2021/01/05/step-by-step-build-kernel-opensuse-easy-guide/) article, we still boot OpenSuse in the console

      ```bash
      pushd ${WORK_SPACE}/fw_repos/qemu/build

      cat >> ./run_opensuse.sh <<EOF
      ./qemu-system-riscv64 -machine virt -m 8G -smp cpus=4 \\
      	-kernel ${WORK_SPACE}/3rd-resrcs/u-boot.bin \\
          -netdev user,id=net0 \\
          -device virtio-net-device,netdev=net0 \\
          -device virtio-blk-device,drive=hd0 \\
          -drive file=${WORK_SPACE}/3rd-resrcs/openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw,format=raw,id=hd0 \\
          -device virtio-rng-pci \\
          -serial mon:stdio \\
          -vga none -device virtio-gpu-pci \\
          -display gtk,gl=on,show-cursor=on \\
          -full-screen \\
          -device qemu-xhci \\
          -device usb-kbd \\
          -device usb-mouse
      EOF

      chmod a+x ./run_opensuse.sh && sh ./run_opensuse.sh
      popd
      ```

    hence we shall build the kernel manually with [buildroot](https://github.com/buildroot/buildroot.git) and replace the original one in the distro

    ```bash
    pushd ${WORK_SPACE}/fw_repos
    	git clone https://github.com/buildroot/buildroot.git
    	git clone https://github.com/openSUSE/kernel.git
    popd
    ```

    ```bash
    pushd ${WORK_SPACE}/fw_repos/buildroot

    git clean -xdf

    cp ${WORK_SPACE}/3rd-resrcs/openSUSE_kernel_defconfig .

    cat >> ./override.mk <<EOF
    LINUX_OVERRIDE_SRCDIR = ../kernel
    LINUX_OVERRIDE_SRCDIR_RSYNC_EXCLUSIONS = --exclude LICENSES
    EOF

    cat >> ./openSUSE_buildroot_defconfig <<EOF
    BR2_riscv=y
    BR2_riscv_custom=y
    BR2_RISCV_ISA_RVM=y
    BR2_RISCV_ISA_RVA=y
    BR2_RISCV_ISA_RVF=y
    BR2_RISCV_ISA_RVD=y
    BR2_RISCV_ISA_RVC=y
    BR2_RISCV_ISA_RVV=y
    BR2_PACKAGE_OVERRIDE_FILE="${WORK_SPACE}/fw_repos/buildroot/override.mk"
    BR2_DEFCONFIG="${WORK_SPACE}/fw_repos/buildroot/openSUSE_buildroot_defconfig"
    BR2_LINUX_KERNEL=y
    BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG=y
    BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="${WORK_SPACE}/fw_repos/buildroot/openSUSE_kernel_defconfig"
    EOF

    make defconfig BR2_DEFCONFIG="${WORK_SPACE}/fw_repos/buildroot/openSUSE_buildroot_defconfig"
    make linux -j8
    popd
    ```

    * we replace the kernel image generated to the origin distribution

      ```bash
      pushd ${WORK_SPACE}/3rd-resrcs

      # mount the file system of openSUSE raw image
      LOOP_DEV=$(echo $(sudo kpartx -a -v openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw) | grep -oE 'loop[[:alnum:]]*p3')
      mkdir -p /tmp/disk_img
      sudo mount /dev/mapper/${LOOP_DEV} /tmp/disk_img

      pushd /tmp/disk_img
      cp ${WORK_SPACE}/fw_repos/buildroot/output/images/Image ./usr/lib/modules/6.5.8-1-default/
      popd

      # umount the file system of openSUSE raw image
      sudo sync
      sudo umount /tmp/disk_img
      sudo kpartx -d -v openSUSE-Tumbleweed-RISC-V-XFCE-efi.riscv64-2023.10.11-Build1.17.raw

      popd

      ```
    *
9. Experience About Fedora 38

    * fetching the Fedora distro image

      ```bash
      pushd ${WORK_SPACE}/3rd-resrcs
      wget https://dl04.fedoraproject.org/pub/alt/risc-v/disk_images/Fedora-Developer-38-20230519.n.0.SiFive.Unmatched.and.QEMU/Fedora-Developer-38-20230519.n.0-qemu.raw.img.xz
      unxz -k Fedora-Developer-38-20230519.n.0-qemu.raw.img.xz
      popd
      ```
    * check the kernel configurations

      ```bash
      pushd ${WORK_SPACE}/3rd-resrcs

      # mount the file system of openSUSE raw image
      LOOP_DEV=$(echo $(sudo kpartx -a -v Fedora-Developer-38-20230519.n.0-qemu.raw.img) | grep -oE 'loop[[:alnum:]]*p2')
      mkdir -p /tmp/disk_img
      sudo mount /dev/mapper/${LOOP_DEV} /tmp/disk_img

      # extract the kernel config file and u-boot binary
      pushd /tmp/disk_img
      cp ./usr/lib/modules/6.5.8-1-default/config ${WORK_SPACE}/3rd-resrcs/openSUSE_kernel_defconfig
      cp ./boot/u-boot.bin ${WORK_SPACE}/3rd-resrcs/
      popd

      # umount the file system of openSUSE raw image
      sudo sync
      sudo umount /tmp/disk_img
      sudo kpartx -d -v Fedora-Developer-38-20230519.n.0-qemu.raw.img

      ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw Fedora-Developer-38-20230519.n.0-qemu.raw.img +20G
      popd
      ```
    * abc

      ```bash
      pushd ${WORK_SPACE}/fw_repos/qemu/build

      cat >> ./run_fedora.sh <<EOF
      ./qemu-system-riscv64 -machine virt -m 8G -smp cpus=4 \\
      	-bios ${WORK_SPACE}/fw_repos/opensbi/build/platform/generic/firmware/fw_payload.bin \\
      	-netdev user,id=net0 \\
      	-device virtio-net-device,netdev=net0 \\
          -drive file=${WORK_SPACE}/3rd-resrcs/Fedora-Developer-38-20230519.n.0-qemu.raw.img,format=raw,if=virtio \\
          -device virtio-rng-pci \\
          -serial mon:stdio \\
          -vga none -device virtio-gpu-pci \\
          -display gtk,gl=on,show-cursor=on \\
          -full-screen \\
          -device qemu-xhci \\
          -device usb-kbd \\
          -device usb-mouse
      EOF

      chmod a+x ./run_fedora.sh && sh ./run_fedora.sh

      popd
      ```
    *
