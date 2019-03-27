In this post I'll break down the setup of my self-hosted virtual home: https://s-ol.nu.

First a quick overview of what this guide will cover:

- HTTPS server with multiple subdomains and varying backends
  - [traefik][traefik] reverse-proxy maintains SSL certificates and serves all requests
  - [docker-compose][docker-compose] manages running sites/microservices
  - single DNS wildcard route
- a private-public git server
  - access control, management with [gitolite][gitolite]
  - [klaus][klaus] web frontend for browsing and cloning public repos
  - fine-grained permissions and SSH public-key access
- micro 'CI' setup rebuilds & redeploys docker images when updates are pushed

# HTTPS server


[traefik]: https://traefik.io/
[docker-compose]: https://docs.docker.com/compose/
[gitolite]: http://gitolite.com/gitolite/index.html
[klaus]: https://github.com/jonashaag/klaus
