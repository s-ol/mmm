I added another driver/store that loads files straight from disk \[[`86bbe80`][86bbe80]\],
and made the server load the fileder tree when it receives a request for content, rather than loading the whole tree up front.
This means that I can work on the content again and see changes in the browser without restarting the server every time  \[[`97bc4a0`][97bc4a0]\],
This feature should be made unnecessary by the in-page editing feature, but until then it's important for my workflow.

I also started cleaning up the mmmfs article a bit, and integrating this project log in a way that will make it available online soon5f78953becd422126a528b2c31dd611cb0b29ef6

[86bbe80]: https://git.s-ol.nu/mmm/commit/86bbe805a7ec49a8b891412713ea43d6e46d0d73/
[97bc4a0]: https://git.s-ol.nu/mmm/commit/97bc4a0d8d866026905eac6f0ba08b75f166219a/
