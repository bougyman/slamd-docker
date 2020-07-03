FROM voidlinux/voidlinux
COPY tmux /usr/src/tmux
RUN xbps-install -Syu xbps && \
    xbps-install -Syu && \
    xbps-install -y libevent-devel base-devel ncurses-base ncurses-devel bash && \
    sed -i 's/^#en_US/en_US/' /etc/default/libc-locales && \
    xbps-reconfigure -f glibc-locales && \
    xbps-reconfigure -a && \
    ls -d /usr/share/locale/* | egrep -v 'en_US|locale.alias' | xargs rm -rf && \
    ls /usr/share/i18n/locales/* | egrep -v 'en_US|locale.alias' | xargs rm -vf && \
    rm -rvf /usr/share/X11 && \
    rm -rvf /usr/share/info/* && \
    rm -rvf /usr/share/doc/* && \
    rm -rvf /usr/share/man/* && \
    rm -rvf /usr/lib/gconv/libCNS.so /usr/lib/gconv/IBM* /usr/lib/gconv/BIG5HKSCS.so && \
    rm -rvf /var/cache/xbps/* && \
    mkdir -vp /etc/runit/runsvdir/tmux && \
    ln -sf /etc/runit/runsvdir/tmux /var/service && \
    ln -sf /var/service /service && \
    ln -s /etc/sv/tmux /service/tmux && \
    cd /usr/src/tmux && ./autogen.sh && \
    ./configure --prefix=/usr/local && make && make install && rm -rf /usr/src/tmux && \
    xbps-remove -y m4 autoconf automake bc binutils-doc binutils bison ed libfl-devel flex libgcc-devel \
                   libstdc++-devel libssp libssp-devel kernel-libc-headers glibc-devel gcc gettext-libs \
                   gettext groff libtool make base-minimal binutils patch base-devel perl \
                   texinfo libressl-devel libevent-devel ncurses-devel
COPY service/tmux /etc/sv/tmux
ENTRYPOINT ["/sbin/runsvdir", "-P", "/service", "'LOG: ..............................................'"]
