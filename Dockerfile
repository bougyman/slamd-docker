FROM voidlinux/voidlinux
RUN xbps-install -Syu xbps && \
    xbps-install -Syu && \
    xbps-install -y bash && \
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
    rm -rvf /var/cache/xbps/*
RUN xbps-install -y libevent ncurses-base openjdk11
COPY service/slamd-server /etc/sv/slamd-server
COPY service/slamd-client /etc/sv/slamd-client
COPY service/tmux /etc/sv/tmux
COPY usr/local/bin/tmux /usr/local/bin/tmux
COPY usr/local/slamd /usr/local/slamd
RUN mkdir -p /etc/runit/runsvdir/slamd && ln -s /etc/runit/runsvdir/current /service && \
    runsvchdir slamd && ln -s /etc/sv/slamd-client /service && \
    ln -s /etc/sv/tmux /service && ln -s /etc/sv/slamd-server /service && mkdir -vp /home/slamd
WORKDIR /home/slamd
# For debugging
#CMD /usr/local/bin/tmux
ENTRYPOINT ["/sbin/runsvdir", "-P", "/service", "'LOG: ..............................................'"]
