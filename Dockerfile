FROM voidlinux/voidlinux
COPY tmux /usr/src/tmux
RUN xbps-install -Syu xbps && \
    xbps-install -Syu && \
    xbps-install -y libevent-devel base-devel openjdk11 ncurses-base ncurses-devel bash && \
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
    cd /usr/src/tmux && ./autogen.sh && \
    ./configure --prefix=/usr/local && make && make install && rm -rf /usr/src/tmux && \
    xbps-remove -y m4 autoconf automake bc binutils-doc binutils bison ed libfl-devel flex libgcc-devel \
                   libstdc++-devel libssp libssp-devel kernel-libc-headers glibc-devel gcc gettext-libs \
                   gettext groff libtool make base-minimal binutils patch base-devel perl \
                   texinfo libressl-devel libevent-devel ncurses-devel
COPY upstream /usr/src/slamd
RUN cd /usr/src/slamd && ./build.sh && sed -i -e 's/\(exec.*\) start/\1 run/' build/package/slamd/bin/startup.sh && \
    mkdir -p /etc/runit/runsvdir/slamd && ln -s /etc/runit/runsvdir/current /service && \
    runsvchdir slamd && ln -s /etc/sv/slamd-client /service && \
    ln -s /etc/sv/tmux /service && ln -s /etc/sv/slamd-server /service && \
    mv build/package/slamd /usr/local/ && cd /usr/local/slamd && unzip slamd-client-*.zip && \
    mkdir -p /home/slamd && rm -rf /usr/src/slamd
COPY service/slamd-server /etc/sv/slamd-server
COPY service/slamd-client /etc/sv/slamd-client
COPY service/tmux /etc/sv/tmux
WORKDIR /home/slamd
# For debugging
#CMD /usr/local/bin/tmux
ENTRYPOINT ["/sbin/runsvdir", "-P", "/service", "'LOG: ..............................................'"]
