FROM nickblah/lua:5.3-luarocks-stretch

RUN echo "deb http://ppa.launchpad.net/jonathonf/tup/ubuntu xenial main" \
      >/etc/apt/sources.list.d/tup.list
RUN apt-get update && \
    apt-get install -y --allow-unauthenticated \
      build-essential m4 tup sassc \
      libmarkdown2-dev libsqlite3-dev libssl-dev
RUN luarocks install discount DISCOUNT_INCDIR=/usr/include/x86_64-linux-gnu
RUN luarocks install sqlite3 && \
    luarocks install moonscript && \
    luarocks install http && \
    luarocks install luaposix && \
    luarocks install lua-cjson 2.1.0-1

COPY . /code
WORKDIR /code
RUN tup init && tup generate build-static.sh && ./build-static.sh

EXPOSE 8000
ENTRYPOINT ["moon", "build/server.moon", "fs", "0.0.0.0", "8000"]
