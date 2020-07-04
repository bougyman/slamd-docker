#!/bin/bash
# author is simply the maintainer tag in image/container metadata
: "${author:=at hey dot com @bougyman}"
# created_by will be the prefix of the images, as well. i.e. bougyman/voidlinux
: "${created_by:=bougyman}"

slamd=$(buildah from ${created_by}/voidlinux)
voidjdk=$(buildah from ${created_by}/void-openjdk)
voidtmux=$(buildah from ${created_by}/voidlinux-tmux)
trap 'buildah unmount "$voidjdk"; buildah rm "$voidjdk"; buildah unmount "$voidtmux"; buildah rm "$voidtmux"; buildah unmount "$slamd"; buildah rm "$slamd"' EXIT
if ! tmux_mount=$(buildah mount "$voidtmux")
then
    echo "Could not mount '$voidtmux', bailing" >&2
    exit 2
fi
if ! jdk_mount=$(buildah mount "$voidjdk")
then
    echo "Could not mount '$voidjdk', bailing" >&2
    exit 2
fi

buildah copy "$slamd" service/slamd-server /etc/sv/slamd-server
buildah copy "$slamd" service/tmux /etc/sv/tmux
buildah copy "$slamd" service/slamd-client /etc/sv/slamd-client
buildah copy "$slamd" "$tmux_mount"/usr/local/bin/tmux /usr/local/bin/tmux
buildah copy "$slamd" "$jdk_mount"/usr/local/slamd /usr/local/slamd
buildah run "$slamd" -- sh -c "mkdir -vp /home/slamd && \
                               mkdir -vp /etc/runit/runsvdir/slamd && \
                               ln -s /etc/sv/tmux /etc/runit/runsvdir/slamd/ && \
                               ln -s /etc/sv/slamd-server /etc/runit/runsvdir/slamd/ && \
                               ln -s /etc/sv/slamd-client /etc/runit/runsvdir/slamd/ && \
                               xbps-install -Sy openjdk8-jre libevent ncurses-base && \
                               rm -rvf /var/cache/xbps/* &&
                               runsvchdir slamd && ln -s /etc/runit/runsvdir/current /service"
# For debugging
# buildah config --cmd /usr/local/bin/tmux "$void"

# For reals, yo, run the runsvdir supervisor
buildah config --cmd "" --entrypoint '["/sbin/runsvdir", "-P", "/service", "LOG: .............................................."]' "$slamd"

buildah config --env JRE_HOME=/usr/lib/jvm/java-1.8-openjdk/jre "$slamd"
buildah config --env TERM=linux "$slamd"
buildah config --workingdir /home/slamd "$slamd"
buildah config --author "$author" "$slamd"
buildah config --created-by "$created_by" "$slamd"
buildah unmount "$slamd"
buildah commit "$slamd" "${created_by}/slamd"
