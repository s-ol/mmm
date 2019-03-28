In this post I'll break down the setup of my self-hosted virtual home: https://s-ol.nu.

First a quick overview of what this guide will cover:

- HTTPS server with multiple subdomains and varying backends
  - [traefik][traefik] reverse-proxy maintains SSL certificates and serves all requests
  - [docker-compose][docker-compose] manages running sites/microservices
- a private-public git server
  - access control, management with [gitolite][gitolite]
  - [klaus][klaus] web frontend for browsing and cloning public repos
  - fine-grained permissions and SSH public-key access
- micro 'CI' setup rebuilds & redeploys docker images when updates are pushed

Most of these projects are very well documented so I won't go into a lot of detail on setting them up.

# HTTPS Server
To run multiple subdomains from a single machine, the HTTP requests need to be matched according to the 'Host' header.
Most HTTP servers have good facilities for doing this, e.g. apache has vhosts, nginx has server directives etc.

In the past I had used apache as my main server, which worked well for static content and PHP apps,
but not all applications fit into this scheme too well and configuration is a tad tedious.

With this latest iteration I am using [traefik][traefik] as a "reverse proxy".
This means traefik doesn't serve anything (not even static content) by itself,
it just delegates requests to one of multiple configured services based on a system of rules.

It also handles letsencrypt certificate generation and updates out-of-the-box and can be tightly integrated with docker, 
so that it automatically reacts to new services being added.

Traefik can be run at system level, but currently I prefer installing the least system-level applications to have my setup
as self-contained as possible. Therefore I went with this [traefik in docker-compose][traefik-in-docker] setup from kilian.io:

    version: '3.4'

    services:
      traefik:
        image: traefik:1.5-alpine
        restart: always
        ports:
          - 80:80
          - 443:443
        networks:
          - web
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - ./traefik.toml:/traefik.toml
          - ./acme.json:/acme.json
        container_name: traefik


    networks:
      web:
        external: true

with the small addition of the `:ro` at the end of the docker socket volume,
to prevent attacks on traefik from being able to take over the host docker system (too easily).
In the guide you can find more details, including the `traefik.toml` that I am using almost verbatim.

# Hosting Sites
With traefik set up, dockerized services can be added and exposed trivially.
For example to start `redirectly`, a tiny link redirect service, this addition suffices:

    redirectly:
      image: local/redirectly:git
      restart: always
      networks:
        - web
      labels:
        - "traefik.frontend.rule=Host:s-ol.nu"
        - "traefik.enable=true"

By setting different subdomains in the frontend-rule section, many different services can be provided.

The image `local/redirectly:git` in this case is built automatically when a repo is pushed (see below).

note: if a container doesn't have an EXPOSE directive, or EXPOSEs multiple ports,
you will have to add a `traefik.port` label specifying which port to use.

# private/public Git Server
While I still have a lot of code on Github, where collaboration is easy,
I prefer to own the infrastructure that I store my private projects on.
I also wanted to have a public web index of some of the projects.

The git infrastructure itself is mananged by [gitolite][gitolite], which I really enjoy using.

    repo gitolite-admin @all
      RW+ = s-ol
      C   = s-ol

    repo public/.*
      R = @all daemon
      option writer-is-owner = 1

    repo ... ...
      RW+ = ludopium

In the first block I grant myself full access to all repos, as well as the right to automatically create repos by
attempting to push/pull from them.

The second block makes all repos prefixed with `public/` readable by anyone in the gitolite system,
as well as the `git-daemon`, which allows cloning via `git://....` access (port 9418).
The `write-is-owner` option lets me set the git `description` field using `ssh git@git.s-ol.nu desc`.

I chose the `public/` prefix because it results in all public repos being stored in one directory together
(`/var/lib/gitolite/repositories/public`), where klaus can easily pick them up.

The klaus web frontend is set up using traefik above like so:

    klaus:
      image: hiciu/klaus-dockerfile
      restart: always
      networks:
        - web
      volumes:
        - /var/lib/gitolite/repositories/public:/srv/git:ro
      command: /opt/klaus/venv/bin/uwsgi --wsgi-file /opt/klaus/venv/local/lib/python2.7/site-packages/klaus/contrib/wsgi_autoreload.py --http 0.0.0.0:8080 --processes 1 --threads 2
      environment:
        KLAUS_REPOS_ROOT: /srv/git
        KLAUS_SITE_NAME: git.s-ol.nu
        KAUS_CTAGS_POLICY: tags-and-branches
        KLAUS_USE_SMARTHTTP: y
      labels:
        - "traefik.frontend.rule=Host:git.s-ol.nu"
        - "traefik.enable=true"

I am using the ['autoreload' feature][klaus-autoreload] and the `hiciu/klaus-dockerfile` docker image.
Setting `KLAUS_USE_SMARTHTTP` allows cloning repos via HTTP.

In the future I would like to modify klaus a bit, for example by showing the README in the root of a project per default
and applying a custom theme.

# Micro-CI
The last piece of the puzzle is automatically deploying projects whenever they are pushed.
This can be realized using git's `post-receive` hooks and is generally pretty well known.

I followed this gitolite guide for [storing repo-specific hooks in the gitolite-admin repo][gitolite-hooks].
It requires a change in the gitolite rc file (on the server), but after that you can configure deployment processes in the conf like this:

    @dockerize = public/redirectly ...
    @jekyllify = blog

    repo @dockerize
      option hook.post-receive = docker-deploy

    # i actually dont have a jekyll blog anymore but its an easy one as well
    repo @jekyllify
      option hook.post-receive = jekyll-deploy

The hooks are stored in the same repo under `local/hooks/repo-specific`.
Here is the `docker-deploy` hook I am using:

    #!/bin/bash
    read oldrev newrev refname
    set -e

    # Get project name
    PROJECT=$(basename "$PWD")
    PROJECT=${PROJECT%.git}

    # Paths
    CHECKOUT_DIR=/tmp/git/${PROJECT}
    TARGET_DIR=... # POINT TO docker-compose.yml directory

    if [ ! -d ${TARGET_DIR} ]; then
      echo -e "\e[1;32mNo target directory to compile into\e[00m"
    fi

    mkdir -p ${CHECKOUT_DIR}
    GIT_WORK_TREE=${CHECKOUT_DIR} git checkout -q -f $newrev
    echo -e "\e[1;32mChecked out ${PROJECT}.\e[00m"

    cd ${CHECKOUT_DIR}
    docker build -t local/${PROJECT}:git .
    echo -e "\e[1;32mImage built.\e[00m"

    cd ${TARGET_DIR}
    docker-compose up -d ${PROJECT}
    echo -e "\e[1;32mContainer restarted.\e[00m"

It will build a `local/$REPO:git` image whenever you push, then run `docker-compose up -d $REPO` in `$TARGET_DIR`.
Just make sure that your docker-compose service is called the same as the image name (like in the `redirectly` example above).

This hook definetely needs an addition to filter which pushes trigger a redeploy (e.g. only tags or only master),
but that should be trivial to add (and well documented online).

---

That's basically it!
If you have questions or comments i'll be happy to hear from you on twitter, github or [mastodon][merveilles].

[traefik]: https://traefik.io/
[docker-compose]: https://docs.docker.com/compose/
[gitolite]: http://gitolite.com/gitolite/index.html
[klaus]: https://github.com/jonashaag/klaus

[traefik-in-docker]: https://blog.kilian.io/server-setup/
[klaus-autoreload]: https://github.com/jonashaag/klaus/wiki/Autoreloader
[gitolite-hooks]: http://gitolite.com/gitolite/cookbook#v36-variation-repo-specific-hooks

[merveilles]: https://merveilles.town/@s_ol
