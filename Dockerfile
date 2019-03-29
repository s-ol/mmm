FROM nickblah/lua:5.3-luarocks-stretch AS build-env
RUN echo "deb http://ppa.launchpad.net/jonathonf/tup/ubuntu xenial main" >/etc/apt/sources.list.d/tup.list
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated build-essential tup sassc libmarkdown2-dev
RUN luarocks install moonscript
RUN luarocks install discount DISCOUNT_INCDIR=/usr/include/x86_64-linux-gnu
COPY . /build
RUN cd /build && tup init && tup generate --config tup.docker.config build.sh && ./build.sh

FROM nginx:alpine
COPY --from=build-env /build/root /usr/share/nginx/html
RUN chmod 555 -R /usr/share/nginx/html
