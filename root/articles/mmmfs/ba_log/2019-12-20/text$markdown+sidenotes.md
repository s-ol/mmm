In the last three days I have been working extensively on support for sidenotes and academic referencing,
inspired by Edward Tufte's style of publishing (as seen in *Beatiful Evidence* and documented in [tufte-css][tufte-css].

To this end margin-notes have been implemented in the CSS styling of the page using two classes, `sidenote` and
`sidenote-container`, which are to be applied to individual sidenotes and the containing document respectively.
Sidenotes are then pulled out of their surrounding context using `position: absolute` and placed in a margin that is
left free by `sidenote-container`.

Inside of markdown files, sidenotes can then be added simply using basic HTML, like so:

```md
<div class="sidenote">additional information to be found on the margin</div>
An example paragraph of text, describing something.
```

Which will render like this:

> <div class="sidenote">additional information to be found on the margin</div>
> An example paragraph of text, describing something.

Additionally, conversions from `text/bibtex`, a reference specification format, to `mmm/dom` have been added, that
create citations using the metadata available in the BibTeX file.

For example the following BibTeX is rendered like this:

<mmm-embed nolink path="../../references/inkandswitch" facet="markdown"></mmm-embed>

> <mmm-embed raw path="../../references/inkandswitch"></mmm-embed>

I also added a special override that links to 
BibTeX files by placing the citation in a sidenote, and adding a footnote indicator in-text.

There is also a handy convert that turns ACM Digital Library links into URLs that directly return the BibTeX file,
which allows me to cite the links directly without manually adding the BibTeX information to my document.

All of this is implemented in the `cites` plug-in: [`cites.moon`][cites.moon].

[cites.moon]: https://git.s-ol.nu/mmm/blob/ba/mmm/mmmfs/plugins/cites.moon
[tufte-css]: https://edwardtufte.github.io/tufte-css/
