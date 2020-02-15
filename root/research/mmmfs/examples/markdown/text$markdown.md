This is a markdown document rendered using [marked][marked] on the client, and [discount][discount] on the server.
All Markdown features are supported, for example there is support for lists...

- a list of things
- (two things)

...and syntax-highlighted code tags:

```
print "Hello World"
```

Since Markdown supports inline HTML, mmmfs shorthands can also be used to embed and reference content from elsewhere in
the system. For example, the title of this fileder can be embedded using
`<mmm-embed facet="title"></mmm-embed>`:

<mmm-embed facet="title"></mmm-embed>

[marked]: https://marked.js.org/
[discount]: https://luarocks.org/modules/craigb/discount
