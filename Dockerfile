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
USER livebuilder
RUN sudo -E lb init -t 3 5; true
RUN lb config --debian-installer live \
        --distribution jessie \
        --archive-areas 'main contrib non-free' \
        --firmware-chroot true \
        --firmware-binary true \
        --image-name lxde-min \
        --system live \
        --initsystem runit \
        --bootloader syslinux \
        --debootstrap-options '--variant=minbase --components=main,contrib,non-free' \
        --apt-recommends false
RUN echo 'lxdm' > config/package-lists/desktop.list.chroot; \
     echo 'lxpanel' >> config/package-lists/desktop.list.chroot; \
     echo 'lxlauncher' >> config/package-lists/desktop.list.chroot; \
     echo 'lxterminal' >> config/package-lists/desktop.list.chroot; \
     echo 'lxsession' >> config/package-lists/desktop.list.chroot; \
     echo 'wicd-gtk' >> config/package-lists/desktop.list.chroot; \
     echo 'firmware-linux-free' >> config/package-lists/desktop.list.chroot; \
     echo 'firmware-linux' >> config/package-lists/desktop.list.chroot; \
     cd config/package-lists && ln -s desktop.list.chroot desktop.list.binary
CMD sudo -E lb build
