#  Why I'm running a personal URL shortening service
This blog you are reading at the moment is currently running it's third reincarnation.
Originally, it was a Jekyll blog hosted on github pages,
before I moved to my own web platform.
That platform is currently undergoing its second big rewrite.

Even while still running on github pages,
the blog moved from https://s0lll0s.github.io, to https://s0lll0s.me and finally to https://s-ol.nu.
Once arrived at https://s-ol.nu, I had to move the blog posts to a different route (`/blog` vs just living in the root)
at some point, to make space for other routes.
Then with my custom platform everything changed again,
since now my main system is actually located at https://mmm.s-ol.nu.

As you might imagine, at every change all the old URLs stop working.
Noone likes finding dead links, but if you post links on social media
it is often extremely unwieldy or impossible to update all the posts.

If you run your own website or blog ([maybe][sir] you [should][indie]?),
your site may have gone throug similar transitions,
or maybe it is about to go through one -
or perhaps you are deferring making a change because you worry about this?

To partially solve this issue, I built a tiny URL redirection service, [redirectly][redirectly].
It works much the same as those URL shortening services you may have used before (bit.ly, tinyurl etc.),
except that I manually specify the shortened URLs in a file (in the git repo).

Nowadays, when I post a link to some content on my website (such as this blog post),
I first allocate a new `slug` (shortlink) and set it up in `redirectly`.
Then I use the shortened link, such as https://s-ol.nu/why-redirectly in this case,
instead of directly linking to the content.

This way, whenever I make changes to my content's adressing scheme,
I simply change the URL location, and any old links that are floating around remain functional.
Should I ever change to another domain, I will consider simply leaving the redirection service running on this domain anyhow,
to keep old links alive. At least for a few years :)

Of course all of this doesn't work when visitors of my page navigate around by themselves,
and then share the URL from their address bar.
This could be solved by using the JS [history API][history] by overriding the displayed URL with the permalink whenever one exists,
but I haven't tried implementing this type of bi-directional querying yet.

I am also aware that running Clojure (and therefore a JVM) is not necessarily
the best choice for a service that is so light,
but I wrote `redirectly` as a little experiment while learning Clojure,
and it is such a simple project that if it ever bugs me I can just throw it out and implement it in something else.

[sir]: https://drewdevault.com/make-a-blog
[indie]: https://indieweb.org/why

[redirectly]: https://s-ol.nu/redirectly/src
[history]: https://developer.mozilla.org/en-US/docs/Web/API/History_API
