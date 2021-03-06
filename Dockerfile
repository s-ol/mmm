FROM nickblah/lua:5.3-luarocks-stretch

RUN apt-get update && \
    apt-get install -y \
      build-essential m4 sassc libmarkdown2-dev libsqlite3-dev libssl-dev
RUN luarocks install discount DISCOUNT_INCDIR=/usr/include/x86_64-linux-gnu
RUN luarocks install sqlite3 && \
    luarocks install moonscript && \
    luarocks install http && \
    luarocks install luaposix && \
    luarocks install lua-cjson 2.1.0-1

COPY . /code
WORKDIR /code
RUN mkdir -p root/static/mmm && \
  find mmm -name '*.moon' | \
  moon build/bundle_modules.moon 'root/static/mmm/text$lua.lua'

EXPOSE 8000
ENTRYPOINT ["moon", "build/server.moon"]
CMD ["fs", "0.0.0.0", "8000", "--cache", "--no-rw"]
