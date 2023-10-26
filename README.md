## RISC-V Fedora on Qemu with Details

- Make directories as you wish

  ```shell
  export WORK_SPACE="~/dev/riscv_fedora_on_qemu"
  mkdir -p ${WORK_SPACE}/{fw_repos,3rd-resrcs}
  ```

- fetch firmwares

  ```shell
  git clone https://github.com/u-boot/u-boot.git ${WORK_SPACE}/fw_repos/u-boot
  git clone https://github.com/riscv-software-src/opensbi.git ${WORK_SPACE}/fw_repos/opensbi
  git clone https://github.com/qemu/qemu.git ${WORK_SPACE}/fw_repos/qemu
  ```

- openssl on this machine is way too old, fetch and build it

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

- modify u-boot source code && build it

  ```shell
  
  ```

  ```shell
  pushd ${WORK_SPACE}/fw_repos/u-boot
  # path to your own riscv toolchains
  export CROSS_COMPILE=/home/pennix/dev/local/riscv-gnu-toolchain/bin/riscv64-unknown-linux-gnu-
  make qemu-riscv64_smode_defconfig
  make -j32
  popd
  ```

- build opensbi with payload of u-boot

  ```shell
  pushd ${WORK_SPACE}/fw_repos/opensbi
  make PLATFORM=generic PLATFORM_RISCV_ABI=lp64d PLATFORM_RISCV_ISA=rv64imafdc_zicsr_zifencei \
  	PLATFORM_RISCV_XLEN=64 \
  	FW_PAYLOAD_PATH=${WORK_SPACE}/fw_repos/u-boot/u-boot.bin
  popd
  ```

- prepare requirements of qemu using system package manager

  ```shell
  sudo apt install libaio-dev libvdeplug-dev libbrlapi-dev \
  	liblz4-dev libsasl2-dev libpam0g-dev libsnappy-dev \
  	liblzo2-dev librdmacm-dev libxen-dev valgrind
  ```

  prepare requirements of qemu from source

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

  ```shell
  pushd ${WORK_SPACE}/fw_repos/qemu
  ./configure --prefix="${WORK_SPACE}/fw_repos/qemu/build" --target-list=riscv64-softmmu --disable-docs --enable-debug-tcg \
              --enable-debug --enable-debug-info -enable-trace-backends=log --enable-gtk --enable-kvm --enable-opengl --enable-slirp \
              --enable-opengl --enable-virglrenderer --enable-sdl --enable-sdl-image
  make -j32 && make install
  popd
  ```

- runing Ubuntu 20.04 LTS

  ```shell
  ## fetch the image of ubuntu2004 and enlarge it for desktop environment
  pushd ${WORK_SPACE}/3rd-resrcs
  wget https://cdimage.ubuntu.com/releases/20.04.6/release/ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img.xz
  unxz -k ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img.xz
  ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw ubuntu-20.04.5-preinstalled-server-riscv64+unmatched.img +20G
  popd
  ```

  ```shell
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

  ```shell
  ## once ubuntu booted, you may use ubuntu/ubuntu to login, close qemu and restart if the shell told you wrong passwd
  ## once logged in, change the apt repo sources
  sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
  sudo sed -i "s/ports.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list
  ## here you can also add http(s)_proxy to your env virable to speed up the downloading process
  
  ## prepare the desktop environment. the procedure shall take a lot of time, wait patiently
  sudo apt-get update
  sudo apt-get install xfce4 lightdm
  ```

- running openSUSE 

  ```shell
  # fetching the SUSE distro image
  pushd ${WORK_SPACE}/3rd-resrcs
  wget https://download.opensuse.org/ports/riscv/tumbleweed/images/openSUSE-Tumbleweed-RISC-V-XFCE.riscv64-rootfs.riscv64-2023.10.11-Build1.18.tar.xz
  unxz -k openSUSE-Tumbleweed-RISC-V-XFCE.riscv64-rootfs.riscv64-2023.10.11-Build1.18.tar.xz
  ${WORK_SPACE}/fw_repos/qemu/build/qemu-img resize -f raw openSUSE-Tumbleweed-RISC-V-XFCE.riscv64-rootfs.riscv64-2023.10.11-Build1.18.raw +20G
  popd
  ```

  inspired by the [Linux guest kernel configuration](https://github.com/qemu/qemu/blob/a95260486aa7e78d7c7194eba65cf03311ad94ad/docs/system/arm/virt.rst#linux-guest-kernel-configuration) part, we need to check whether 

  ```bash
  CONFIG_PCI=y
  CONFIG_VIRTIO_PCI=y
  CONFIG_PCI_HOST_GENERIC=y
  
  CONFIG_DRM=y
  CONFIG_DRM_VIRTIO_GPU=y
  ```

  were selected properly in the kernel image of the distro image, as follows

  ```shell
  pushd ${WORK_SPACE}/3rd-resrcs
  
  # mount the file system of openSUSE raw image
  LOOP_DEV=$(echo $(sudo kpartx -a -v openSUSE-Tumbleweed-RISC-V-XFCE.riscv64-rootfs.riscv64-2023.10.11-Build1.18.raw) | grep -oE 'loop[[:alnum:]]**p3')
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
  sudo kpartx -d -v openSUSE-Tumbleweed-RISC-V-XFCE.riscv64-rootfs.riscv64-2023.10.11-Build1.18.raw
  
  popd
  ```

  notice that the `virtio-gpu-pci` module is not enabled in `openSUSE_kernel_defconfig`

  ```shell
  
  ```

  hence we shall build the kernel manually with [buildroot](https://github.com/buildroot/buildroot.git) and replace the original one in the distro

  ```shell
  pushd ${WORK_SPACE}/fw_repos
  git clone https://github.com/buildroot/buildroot.git
  git clone https://github.com/openSUSE/kernel.git
  popd
  ```

  

  ```shell
  pushd ${WORK_SPACE}/fw_repos/qemu/build
  
  install -m a+x /dev/null ./run_opensuse.sh
  
  cat >> ./run_opensuse.sh <<EOF
      ./qemu-system-riscv64 -machine virt -m 8G -smp cpus=4 \
      -kernel ${WORK_SPACE}/3rd-resrcs//u-boot.bin
      -netdev user,id=net0 \
      -device virtio-net-device,netdev=net0 \
      -device virtio-blk-device,drive=hd0 \
      -drive file=${WORK_SPACE}/3rd-resrcs/openSUSE-Tumbleweed-RISC-V-XFCE.riscv64-rootfs.riscv64-2023.10.11-Build1.18.raw,format=raw,id=hd0 \
      -device virtio-rng-pci \
      -serial mon:stdio \
      -vga none -device virtio-gpu-pci \
      -display gtk,gl=on,show-cursor=on \
      -full-screen \
      -device qemu-xhci \
      -device usb-kbd \
      -device usb-mouse
  EOF
  
  ./run_opensuse.sh
  popd
  ```
