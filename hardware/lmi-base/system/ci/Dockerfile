# Arm64 build image for the local package set and the base rootfs. Built on the
# verified Arch Linux ARM bootstrap (bootstrap-alarm.sh); signature checking
# stays on in pacman.
FROM alarm-base:latest
RUN pacman-key --init && pacman-key --populate archlinuxarm \
 && pacman -Syu --noconfirm --needed base-devel arch-install-scripts squashfs-tools \
      git python meson ninja cpio zstd \
 && pacman -Scc --noconfirm \
 && useradd -m builder \
 && echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
