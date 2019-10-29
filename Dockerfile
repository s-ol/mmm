FROM nickblah/lua:5.3-luarocks-stretch

RUN echo "deb http://ppa.launchpad.net/jonathonf/tup/ubuntu xenial main" \
      >/etc/apt/sources.list.d/tup.list
RUN apt-get update && \
    apt-get install -y --allow-unauthenticated \
      build-essential m4 tup sassc \
      libmarkdown2-dev libsqlite3-dev libssl-dev
RUN luarocks install discount DISCOUNT_INCDIR=/usr/include/x86_64-linux-gnu
RUN luarocks install moonscript
RUN luarocks install sqlite3
RUN luarocks install http

COPY . /code
WORKDIR /code
RUN tup init && tup generate --config tup.docker.config build-static.sh && ./build-static.sh

EXPOSE 8000
ENTRYPOINT ["moon", "build/server.moon", "fs", "0.0.0.0", "8000", "^/sandbox/"]
