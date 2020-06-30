FROM ubuntu
RUN apt-get update && apt-get install -qy tmux bash openjdk-11-jdk vim
COPY upstream /usr/src/slamd
WORKDIR /usr/src/slamd
RUN ./build.sh && sed -i -e 's/\(exec.*\) start/\1 run/' build/package/slamd/bin/startup.sh
CMD ./build/package/slamd/start-slamd-server.sh
