The system described in the thesis and subject to the following blog posts was partially pre-existing to the work
done as part of the thesis and thesis project. The `mmmfs` system was originally developed as the software for my
personal website, with development beginning around May 2018. In this phase of development the website and system
changed shape drastically multiple times.  In the following paragraphs I will describe the state of the project at
the last revision prior to the beginning of the thesis project, as it existed before the 7th of October 2019.
All developments since this revision have been tracked in the following project log entries, and are to be considered
the practical contributions to the thesis project.

In this revision, the system existed as a tool to produce a static website representing the contents of the `mmmfs`
system in browsable HTML format. The tool had to be run manually after changes, or using a build tool like [`tup`][tup].
A primitive *Inspector* tab was present in the HTML output and allowed viewing the raw `mmmfs` contents, but all editing
of content had to be done with external tools and in the external file-system. To see changes in the browser, a
compilation phase had to be triggered and completed, and consecutively the page reloaded in the browser. There was no
server-side component that could convert content or store changes for clients. The tool could only accept content from
the filesystem, not from zip archives or SQLite databases. The conversion algorithm used was more naive and was not
able to track cost values, which meant that some more advanced conversions couldn't be implemented.

There was already an example implementation of a simple slideshow present, but due to the lack of editing capabilities
there was no pinwall examle. There was also no support for side- or marginnotes, or academic referencing and citations.
There also was no support for [`mermaid`][mermaid] diagrams or JSON-encoded data, and there was no plugin interface.
The HTML template, CSS styling and JS runtime were all built and tracked outside of the `mmmfs` system itself.
There was no unit tests for any of the project.

[tup]: http://gittup.org/tup/
[mermaid]: https://mermaidjs.github.io/
