#!/bin/bash
# author is simply the maintainer tag in image/container metadata
: "${author:=at hey dot com @bougyman}"
# created_by will be the prefix of the images, as well. i.e. bougyman/voidlinux
: "${created_by:=bougyman}"

void=$(buildah from ${created_by}/voidlinux)
buildah run "$void" -- sh -c "xbps-install -Syu xbps && \
                              xbps-install -Syu && \
                              xbps-install -y bash && \
                              rm -rvf /var/cache/xbps/*"
buildah run "$void" -- sh -c "xbps-install -y libevent ncurses-base openjdk11"
buildah copy "$void" usr/local/bin/tmux /usr/local/bin/tmux
buildah config --author "$author" "$void"
buildah config --created-by "$created_by" "$void"
buildah unmount "$void"
buildah commit "$void" "${created_by}/void-openjdk"
buildah rm "$void"

