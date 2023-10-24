# dotFiles
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

## RISC-V Fedora on Qemu with Rivai-CD Server

1. Make directories as you wish

   ```shell
   mkdir -p riscv_fedora_on_qemu/{fw_repos,3rd-resrcs}
   export WORK_SPACE=$(realpath riscv_fedora_on_qemu)
   ```

2. fetch firmwares

   ```shell
   git clone https://github.com/u-boot/u-boot.git ${WORK_SPACE}/fw_repos/u-boot
   git clone https://github.com/riscv-software-src/opensbi.git ${WORK_SPACE}/fw_repos/opensbi
   git clone https://github.com/qemu/qemu.git ${WORK_SPACE}/fw_repos/qemu
   ```

3. openssl on this machine is way too old, fetch and build it

   ```shell
   pushd ${WORK_SPACE}/3rd-resrcs
   wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz
   tar xzvf openssl-1.1.1w.tar.gz
   cd openssl-1.1.1w && mkdir build
   ./Configure linux-x86_64 --prefix="$(realpath ./build)"
   make -j32 && make install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/openssl-1.1.1w/build/lib/pkgconfig:$PKG_CONFIG_PATH
   ```
   
   ```shell
   diff --git a/configs/qemu-riscv32_smode_defconfig b/configs/qemu-riscv32_smode_defconfig
   index 0c7389e2f9..cb85807593 100644
   --- a/configs/qemu-riscv32_smode_defconfig
   +++ b/configs/qemu-riscv32_smode_defconfig
   @@ -9,6 +9,9 @@ CONFIG_SYS_MONITOR_LEN=786432
    CONFIG_SYS_LOAD_ADDR=0x80200000
    CONFIG_TARGET_QEMU_VIRT=y
    CONFIG_RISCV_SMODE=y
   +CONFIG_RISCV_ISA_D=y
   +CONFIG_RISCV_ISA_C=y
   +CONFIG_CMODEL_MEDANY=y
    CONFIG_FIT=y
    CONFIG_DISTRO_DEFAULTS=y
    CONFIG_DISPLAY_CPUINFO=y
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
   ```
   
   ```shell
   pushd ${WORK_SPACE}/fw_repos/u-boot
   export CROSS_COMPILE=/work/home/pfu/dev/.local/riscv-toolchain/bin/riscv64-unknown-linux-gnu-  # path to your own riscv toolchains
   make qemu-riscv64_smode_defconfig
   make -j32
   popd
   ```

4. build opensbi

   ```shell
   pushd ${WORK_SPACE}/fw_repos/opensbi
   make PLATFORM=generic PLATFORM_RISCV_ABI=lp64d PLATFORM_RISCV_ISA=rv64imafdc_zicsr_zifencei \
   	PLATFORM_RISCV_XLEN=64 FW_PAYLOAD_PATH=${WORK_SPACE}/fw_repos/u-boot/u-boot.bin
   popd
   ```

5. prepare requirements of qemu

   ```shell
   sudo apt install libaio-dev libcap-ng libvdeplug-dev libbrlapi-dev liblz4-dev libsasl2-dev libpam0g-dev libsnappy-dev liblzo2-dev librdmacm-dev libxen-dev valgrind
   ```

   ```shell
   pushd ${WORK_SPACE}/3rd-resrcs
   
   # liburing
   git clone https://github.com/axboe/liburing.git
   pushd liburing
   mkdir build
   ./configure --prefix="$(realpath build)"
   make -j32 && make install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/liburing/build/lib/pkgconfig:$PKG_CONFIG_PATH
   
   # iasl
   git clone git://github.com/acpica/acpica.git
   pushd acpica
   make -j32
   popd
   export PATH=${WORK_SPACE}/3rd-resrcs/acpica/generate/unix/bin:$PATH
   
   # libnfs
   git clone https://github.com/sahlberg/libnfs.git
   pushd libnfs
   ./bootstrap
   mkdir build
   ./configure --prefix="$(realpath build)"
   make -j32 && make install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/libnfs/build/lib/pkgconfig:$PKG_CONFIG_PATH
   
   git clone https://github.com/capstone-engine/capstone.git
   pushd capstone
   mkdir build
   cd build
   cmake .. -DCMAKE_INSTALL_PREFIX="$(realpath .)"
   cmake --build . --config Release -j32
   cmake --install .
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/capstone/build/lib/pkgconfig:$PKG_CONFIG_PATH
   
   # gtk3
   wget https://download.gnome.org/sources/gtk+/3.24/gtk+-3.24.37.tar.xz
   mkdir gtk3
   tar xJvf gtk+-3.24.37.tar.xz -C gtk3 --strip-components=1
   pushd gtk3
   mkdir build output
   meson setup --prefix="$(realpath output)"  --buildtype=release -Dman=true -Dbroadway_backend=true build
   popd
   
   # epoxy -> dependency of virgl
   git clone https://github.com/anholt/libepoxy.git
   pushd libepoxy
   mkdir build output
   meson setup --prefix="$(realpath output)"  --buildtype=release build
   ninja -C build -j32
   ninja -C build install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/libepoxy/output/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
   
   # virgl
   git clone https://gitlab.freedesktop.org/virgl/virglrenderer.git
   pushd virglrenderer
   mkdir build output
   meson setup --prefix="$(realpath output)"  --buildtype=release build
   ninja -C build -j32
   ninja -C build install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/virglrenderer/output/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
   
   # sdl2
   wget https://github.com/libsdl-org/SDL/releases/download/release-2.28.4/SDL2-2.28.4.tar.gz
   mkdir sdl2
   tar xzvf SDL2-2.28.4.tar.gz -C sdl2 --strip-components=1
   pushd sdl2
   mkdir output
   ./configure --prefix="$(realpath ./output)"
   make -j32 && make install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/sdl2/output/lib/pkgconfig:$PKG_CONFIG_PATH
   
   # sdl2_image
   wget https://github.com/libsdl-org/SDL_image/releases/download/release-2.6.3/SDL2_image-2.6.3.tar.gz
   mkdir sdl2_image
   tar xzvf SDL2_image-2.6.3.tar.gz -C sdl2_image --strip-components=1
   pushd sdl2_image
   mkdir output
   ./configure --prefix="$(realpath ./output)"
   make -j32 && make install
   popd
   export PKG_CONFIG_PATH=${WORK_SPACE}/3rd-resrcs/sdl2_image/output/lib/pkgconfig:$PKG_CONFIG_PATH

   # libslirp
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

   ```shell
   pushd ${WORK_SPACE}/fw_repos/qemu
   ./configure --prefix="${WORK_SPACE}/fw_repos/qemu/build" --target-list=riscv64-softmmu --disable-docs --enable-debug-tcg --enable-debug --enable-debug-info -enable-trace-backends=log --enable-gtk --enable-kvm --enable-opengl --enable-virglrenderer --enable-sdl --enable-sdl-image
   make -j32 && make install
   popd
   ```

6. runing Ubuntu 20.04 LTS version

   ```shell
   ## fetch the image of ubuntu2004 and enlarge it
   pushd ${WORK_SPACE}/3rd-resrcs
   wget https://cdimage.ubuntu.com/releases/20.04.6/release/ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img.xz
   unxz -k ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img.xz
   ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img +20G
   popd
   ```

   ```shell
   pushd ${WORK_SPACE}/fw_repos/qemu/build
   ./qemu-system-riscv64 -machine virt -m 8G -smp cpus=4 \
   -bios ${WORK_SPACE}/fw_repos/opensbi/build/platform/generic/firmware/fw_payload.bin \
   -netdev user,id=net0 \
   -device virtio-net-device,netdev=net0 \
   -drive file=${WORK_SPACE}/3rd-resrcs/ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img,format=raw,if=virtio \
   -device virtio-rng-pci \
   -serial mon:stdio \
   -device virtio-gpu-pci -full-screen  \
   -device qemu-xhci \
   -device usb-kbd \
   -device usb-mouse
   popd
   ```

   ```shell
   ## once ubuntu booted, you may use ubuntu/ubuntu to login, close qemu and restart if the shell told you wrong passwd
   ## once logged in, change the apt repo sources
   sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
   sudo sed -i "s/http:\/\/ports.ubuntu.com/http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports/g" /etc/apt/sources.list
   ## here you can also add http(s)_proxy to your env virable to speed up the downloading process
   
   ## prepare the desktop environment. the procedure shall take a lot of time, wait patiently
   sudo apt-get update
   sudo apt-get install \
     adwaita-icon-theme-full \
     mutter \
     gdm3 \
     gnome \
     gnome-shell-extension-appindicator \
     gnome-shell-extension-desktop-icons-ng \
     gnome-shell-extension-ubuntu-dock \
     gnome-terminal \
     network-manager-gnome \
     ubuntu-gnome-wallpapers \
     ubuntu-settings
   ## set WaylandEnable=false in /etc/gdm3/custom.conf
   sudo systemctl start gdm3
   ```

7. runing Fedora 38 on Qemu with graphic env

   ```shell
   ## fetch image
   pushd ${WORK_SPACE}/3rd-resrcs
   
   wget https://dl04.fedoraproject.org/pub/alt/risc-v/disk_images/Fedora-Developer-38-20230519.n.0.SiFive.Unmatched.and.QEMU/Fedora-Developer-38-20230519.n.0-qemu.raw.img.xz
   
   unxz -k Fedora-Developer-38-20230519.n.0-qemu.raw.img.xz
   
   # The original image size is not enough for image building, we need enlarge it first.
   ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw Fedora-Developer-38-20230519.n.0-qemu.raw.img +40G
   
   ## We need to modify extlinux.conf for QEMU
   mkdir -p /tmp/disk_img
   sudo kpartx -a -v Fedora-Developer-38-20230519.n.0-qemu.raw.img
   # We need to mount the 1st partition (or /boot partition)
   sudo mount /dev/mapper/loop2p1 /tmp/disk_img
   # Edit extlinux.conf
   sudo nvim /tmp/disk_img/extlinux/extlinux.conf
   # remove the 'fdtdir' line and save
   sudo sync
   sudo umount /tmp/disk_img
   sudo kpartx -d -v Fedora-Developer-38-20230519.n.0-qemu.raw.img
   
   popd
   
   ```

   



   
