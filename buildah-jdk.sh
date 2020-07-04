#!/bin/bash
# author is simply the maintainer tag in image/container metadata
: "${author:=at hey dot com @bougyman}"
# created_by will be the prefix of the images, as well. i.e. bougyman/voidlinux
: "${created_by:=bougyman}"

void=$(buildah from ${created_by}/voidlinux)
trap 'buildah unmount "$void"; buildah rm "$void"' EXIT
if ! buildah mount "$void"
then
    echo "Could not mount '$void', baling" >&2
    exit 2
fi
buildah run "$void" -- sh -c "xbps-install -Syu xbps && \
                              xbps-install -Syu && \
                              rm -rvf /var/cache/xbps/*"
buildah run "$void" -- sh -c "xbps-install -y openjdk11 && rm -rvf /var/cache/xbps/*"
buildah copy "$void" upstream /usr/src/slamd
buildah run "$void" -- sh -c "xbps-install -Sy unzip && cd /usr/src/slamd && ./build.sh && \
                              sed -i -e 's/\(exec.*\) start/\1 run/' build/package/slamd/bin/startup.sh && \
                              mkdir -vp /home/slamd && \
                              mkdir -vp /etc/runit/runsvdir/slamd && \
                              cd /usr/src/slamd/build/package/slamd && unzip slamd-client-*.zip && \
                              mv /usr/src/slamd/build/package/slamd /usr/local/slamd && \
                              rm -rf /usr/src/slamd && xbps-remove -y unzip && rm -rvf /var/cache/xbps/*"
buildah config --author "$author" "$void"
buildah config --created-by "$created_by" "$void"
buildah unmount "$void"
buildah commit "$void" "${created_by}/void-openjdk"
