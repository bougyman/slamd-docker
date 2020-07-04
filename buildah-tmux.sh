#!/bin/bash
# author is simply the maintainer tag in image/container metadata
: "${author:=at hey dot com @bougyman}"
# created_by will be the prefix of the images, as well. i.e. bougyman/voidlinux
: "${created_by:=bougyman}"

void=$(buildah from ${created_by}/voidlinux)
if ! voidmount=$(buildah mount "$void")
then
    echo "Could not mount '$void', bailing" >&2
    exit 2
fi

set -e
buildah copy "$void" tmux /usr/src/tmux
buildah run "$void" -- sh -c "xbps-install -y base-devel ncurses-devel libevent-devel && \
                             cd /usr/src/tmux && ./autogen.sh && mkdir /home/tmux && \
                             ./configure --prefix=/usr/local && make && make install"
mkdir -p usr
cp -a "$voidmount"/usr/local usr/
# For debugging
# buildah config --cmd /usr/local/bin/tmux "$void"

# For reals, yo, run a tmux
buildah config --entrypoint '["/usr/local/bin/tmux", "-S", "/tmp/voidmux"]' "$void"

buildah config --workingdir /home/tmux "$void"
buildah config --author "$author" "$void"
buildah config --created-by "$created_by" "$void"
buildah unmount "$void"
buildah commit "$void" "${created_by}/voidlinux-tmux"
