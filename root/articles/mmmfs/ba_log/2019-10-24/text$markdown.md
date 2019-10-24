While writing some of the main section of the thesis today,
I felt the need to illustrate some subject matter with a diagram depicting a folder structure.
Knowing of some similar tools that generate SVG diagrams from textual descriptions,
some quick research turned up [mermaid JS][mermaid].

I tried it in their online live editor first to verify that it would indeed do what I needed it to,
and then added it to the set of supported types in mmm (on the clientside only) \[[`2ff6f90`][2ff6f90]\].
This was pretty easy in the end, all it took was adding mermaid.js to the interactive version's resources (in `build/server.moon`)
and then definig the `convert` (and thereby implicitly defining the corresponding type, `text/mermaid-graph`):

    {
      inp: 'text/mermaid-graph'
      out: 'mmm/dom'
      cost: 1
      transform: (source) =>
        with container = document\createElement 'div'
          cb = (svg, two) =>
            .innerHTML = svg
          window.mermaid\render "mermaid-#{id_counter}", source, cb
    }
    
The code is quite short, since all it needs to do is create a container element,
then tell mermaid.js to render the textual definition.
Once mermaid.js is done, the rendered content is added in the container element.

Here is one of the two diagrams that I implemented the feature for,
you can also follow the link through to the source and view the textual representation using the 'inspect' button.

<mmm-embed path="/articles/mmmfs/mmmfs/mainstream_fs"></mmm-embed>

[mermaid]: https://mermaidjs.github.io/mermaid-live-editor/
[2ff6f90]: https://git.s-ol.nu/mmm/commit/2ff6f906c498c1b742dd8437a09c97ebe29a652a/
