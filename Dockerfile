FROM debian:sid
ARG DEBIAN_FRONTEND="noninteractive"
ARG LANG="C.UTF-8"
ARG LC_ALL="C.UTF-8"
ARG CACHING_PROXY=""
ENV DEBIAN_FRONTEND="noninteractive" LANG="C.UTF-8" LC_ALL="C.UTF-8" CACHING_PROXY=""
RUN adduser --disabled-password --home /home/livebuilder --shell /bin/bash --disabled-password --gecos "livebuilder" livebuilder
RUN adduser livebuilder sudo
RUN apt-get update && apt-get install -yq --fix-missing --reinstall \
        apt-transport-https apt-utils iproute debconf
RUN echo "Acquire::HTTP::Proxy \"$CACHING_PROXY\";" | tee -a /etc/apt/apt.conf.d/01proxy
RUN apt-get update && apt-get install -yq --fix-missing --reinstall \
                gnupg2 \
                bash \
                make \
                apt-utils \
                live-build \
                debootstrap \
                make \
                curl \
                sudo \
                procps \
                ca-certificates \
                debian-keyring \
                debian-archive-keyring \
                dirmngr \
                e2fsprogs \
                squashfs-tools \
                syslinux-common \
                cpio \
                less
RUN echo 'livebuilder ALL=(ALL) NOPASSWD: ALL' | tee -a /etc/sudoers
RUN chown -R livebuilder:livebuilder /home/livebuilder/
WORKDIR /home/livebuilder/live
RUN chown -R livebuilder:livebuilder /home/livebuilder/live
RUN lb init -t 3 5; true
USER livebuilder
RUN lb config --debian-installer live \
        --distribution sid \
        --archive-areas main contrib non-free \
        --firmware-chroot true \
        --firmware-binary true \
        --image-name lxde-min \
        --system live \
        --initsystem systemd \
        --initsystem none \
        --bootloader syslinux \
        --apt-recommends true
RUN echo 'lxdm' > config/packages/desktop.list.chroot; \
     echo 'lxpanel' >> config/packages/desktop.list.chroot; \
     echo 'lxde-desktop' >> config/packages/desktop.list.chroot; \
     echo 'lxlauncher' >> config/packages/desktop.list.chroot; \
     echo 'lxterminal' >> config/packages/desktop.list.chroot; \
     echo 'lxsession' >> config/packages/desktop.list.chroot; \
     echo 'networkmanager' >> config/packages/desktop.list.chroot; \
     echo 'apper' >> config/packages/desktop.list.chroot; \
     echo 'firefox' >> config/packages/desktop.list.chroot; \
     echo 'gimp' >> config/packages/desktop.list.chroot; \
     echo 'kodi' >> config/packages/desktop.list.chroot; \
     echo 'libreoffice' >> config/packages/desktop.list.chroot; \
     cd config/packages && ln -s desktop.list.chroot desktop.list.binary
CMD sudo -E lb build
