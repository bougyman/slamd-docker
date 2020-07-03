#!/bin/bash
# author is simply the maintainer tag in image/container metadata
: "${author:=at hey dot com @bougyman}"
# created_by will be the prefix of the images, as well. i.e. bougyman/voidlinux
: "${created_by:=bougyman}"

voidjdk=$(buildah from ${created_by}/void-openjdk)

buildah copy "$voidjdk" service/slamd-server /etc/sv/slamd-server
buildah copy "$voidjdk" service/tmux /etc/sv/tmux
buildah copy "$voidjdk" service/slamd-client /etc/sv/slamd-client
buildah copy "$voidjdk" usr/local/slamd /usr/local/slamd
buildah run "$voidjdk" -- sh -c "mkdir -p /etc/runit/runsvdir/slamd && ln -s /etc/runit/runsvdir/current /service && \
                              runsvchdir slamd && ln -s /etc/sv/slamd-client /service && \
                              ln -s /etc/sv/tmux /service && ln -s /etc/sv/slamd-server /service && mkdir -vp /home/slamd"
# For debugging
# buildah config --cmd /usr/local/bin/tmux "$void"

# For reals, yo, run the runsvdir supervisor
buildah config --entrypoint '["/sbin/runsvdir", "-P", "/service", "LOG: .............................................."]' "$voidjdk"

buildah config --workingdir /home/slamd "$voidjdk"
buildah config --author "$author" "$voidjdk"
buildah config --created-by "$created_by" "$voidjdk"
buildah unmount "$voidjdk"
buildah commit "$voidjdk" "${created_by}/slamd"
buildah rm "$voidjdk"

