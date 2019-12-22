mmmfs
=====

`mmmfs` is a newly developed personal data storage and processing system. It was developed first as a tool for
generating static websites, but has been extended with live interaction and introspection, as well as embedded
editing capabilities as part of this work.

mmmfs has been designed with a focus on data ownership for users. One of the main driving ideas is to unlock data
from external data silos and file formats by making data available uniformly across different storage systems and
formats. Secondly, computation and interactive elements are also integrated in the paradigm, so that mmmfs can be
seemlessly extended and molded to the users needs.

The abstraction of data types is accomplished using two major components, the *Type System and Coercion Engine* and
the *Fileder Unified Data Model* for unified data storage and access.

## the fileder unified data model
The Fileder Model is the underlying unified data storage model.
Like many data storage models it is based fundamentally on the concept of a hierarchical tree-structure.

<mmm-embed path="tree_mainstream">schematic view of an example tree in a mainstream filesystem</mmm-embed>

In common filesystems, as pictured, data can be organized hierarchically into *folders* (or *directories*),
which serve only as containers of *files*, in which data is actually stored.
While *directories* are fully transparent to both system and user (they can be created, browser, listed and viewed by both),
*files* are, from the system perspective, mostly opaque and inert blocks of data.

Some metadata, such as file size and access permissions, is associated with each file,
but notably the type of data is generally not actually stored in the filesystem,
but determined loosely based on multiple heuristics depending on the system and context.
Some notable mechanism are:

- Suffixes in the name are often used to indicate what kind of data a file should contain. However there is no standardization
- over this, and often a suffix is used for multiple incompatible versions of a file-format.
- Many file-formats specify a specific data-pattern either at the very beginning or very end of a given file.
  On unix systems the `libmagic` database and library of these so-called *magic constants* is commonly used to guess
  the file-type based on these fragments of data.
- on UNIX systems, files to be executed are checked by a variety of methods<mmm-link path="../references/linux-exec">
  </mmm-link> in order to determine which format would fit. For example, script files, the "shebang" symbol, `#!`, can
  be used to specify the program that should parse this file in the first line of the file.
 
It should be clear already from this short list that to mainstream operating systems, as well as the applications
running on them, the format of a file is almost completely unknown and at best educated guesses can be made.

Because these various mechanisms are applied at different times by the operating system and applications,
it is possible for files to be labelled as or considered as being in different formats at the same time by different components of the system.
<div class="sidenote" style="margin-top: -5rem;">
The difference between changing a file extension and converting a file between two formats is commonly unclear to users,
see for example <a href="https://askubuntu.com/questions/166602/why-is-it-possible-to-convert-a-file-just-by-renaming-its-extension">
Why is it possible to convert a file just by renaming it?</a>, https://askubuntu.com/q/166602 from 2019-12-18
<!-- https://www.quora.com/What-happens-when-you-rename-a-jpg-to-a-png-file -->
</div>
This leads to confusion about the factual format of data among users, but can also pose a serious security risk:
Under some circumstances it is possible that a file contains maliciously-crafted code and is treated as an executable
by one software component, while a security mechanism meant to detect such code determines the same file to be a
legitimate image<mmm-link path="../references/poc-or-gtfo"></mmm-link> (the file may in fact be valid in both formats).

In mmmfs, the example above might look like this instead:  
<mmm-embed path="tree_mmmfs">schematic view of an example mmmfs tree</mmm-embed>

Superficially, this may look quite similar: there is still only two types of nodes (referred to as *fileders* and *facets*),
and again one of them, the *fileders* are used only to hierarchically organize *facets*.
Unlike *files*, *factes* don't only store a freeform *name*, there is also a dedicated *type* field associated with every *facet*,
that is explicitly designed to be understood and used by the system.

Despite the similarities, the semantics of this system are very different:
In mainstream filesystems, each *file* stands for itself only;
i.e. in a *directory*, no relationship between *files* is assumed by default,
and files are most of the time read or used outside of the context they exist in in the filesystem.

In mmmfs, a *facet* should only ever be considered an aspect of its *fileder*, and never as separate from it.
A *fileder* can contain multiple *facets*, but they are meant to be alternate or equivalent representations of the *fileder* itself.
Though for some uses it is required, software in general does not have to be directly aware of the *facets* existing within a *fileder*,
rather it assumes the presence of content in the representation that it requires, and simple requests it.
The *Type Coercion Engine* (see below) will then attempt to satisfy this request based on the *facets* that are in fact present.

Semantically a *fileder*, like a *directory*, also encompasses all the other *fileders* nested within it (recursively).
Since *fileders* are the primary unit of data to be operated upon, *fileder* nesting emerges as a natural way of structuring complex data,
both for access by the system and applications, as well as the user themself.

## the type system & coercion engine
As mentioned above, *facets* store data alongside its *type*, and when applications require data from a *fileder*,
they specify the *type* (or the list of *types*) that they require the type to be in.

In the current iteration of the type system, types are simple strings of text and loosely based on MIME-types [TOOD: quote RFC?].
MIME types consist of a major- and minor category, and optionally a 'suffix'.
Here are some common MIME-types that are also used in mmmfs:

- `text/html` and `text/html+frag` (mmmfs only)
- `text/javascript`
- `image/png`
- `image/jpeg`

While these types allow some amount of specifity, they fall short of describing their content especially in cases where formats overlap:
Source code is often distributed in `.tar.gz` archive files (directory-trees that are first bundled into an `application/x-tar` archive,
and then compressed into an `application/gzip` archive).
Using either of these two types is either incorrect or insufficient information to properly treat and extract the contained data.

To mitigate this problem, mmmfs *types* can be nested. This is denoted in mmmfs *type* strings using the `->` symbol, e.g. the mmmfs-types
`application/gzip -> application/tar -> dirtree` and `URL -> image/jpeg` describe a tar-gz-compressed directory tree and the URL linking to a JPEG-picture respectively.

Depending on the outer type this nesting can mean different things:
for URLs the nested type is expected to be found after fetching the URL with HTTP,
compression formats are expected to contain contents of the nested types,
and executable formats are expected to output data of the nested type.

It is a lot more important to be able to accurately describe the type of a *facet* in mmmfs than in mainstream operating systems,
because while in the latter types are mostly used only associate an application that will then prompt the user about further steps,
mmmfs uses the *type* to automatically find one or more programs to execute to convert or transform the data stored in a *facet*
into the *type* required by the application.

This process of *type coercion* uses a database of known *converts*, that can be applied to data.
Every *convert* consists of a description of the input *types* that it can accept, the output *type* it would produce for a given input type,
as well as the code for actually converting a given piece of data.
Simple *converts* may simply consist of a fixed in and output type,
such as for example this *convert* for rendering Markdown-encoded text to a HTML hypertext fragment:

    {
      inp: 'text/markdown'
      out: 'text/html+frag'
      transform: (value, ...) ->
        -- implementation stripped for brevity
    }

Other *converts* on the other hand may accept a wide range of input types:

    {
      inp: 'URL -> image/.*'
      out: 'text/html+frag'
      transform: (url) -> img src: url
    }

This convert uses a Lua Pattern to specify that it can accept an URL to any type of image,
and convert it to an HTML fragment.

By using the pattern substitution syntax provided by the Lua `string.gsub` function,
converts can also make the type they return depend on the input type, as is required often when nested types are unpacked:

    {
      inp: 'application/gzip -> (.*)'
      out: '%1'
      transform: (data) ->
        -- implementation stripped for brevity
    }

This *convert* accepts an `application/gzip` *type* wrapping any other *type*, and captures that nested type in a pattern group.
It then uses the substituion syntax to specify that nested type as the output of the conversion.
For an input *type* of `application/gzip -> image/png` this *convert* would therefore generate the type `image/png`. 

To further demonstrate the flexibility using this approach, consider this last example:

    {
      inp: 'text/moonscript -> (.*)'
      out: 'text/lua -> %1'
      transform: (code) -> moonscript.to_lua code
    }

This *convert* transpiles MoonScript source-code into Lua source-code, while keeping the nested type
(in this case the result expected when executing either script) the same.

In addition to the attributes shown above, every *convert* is also rated with a *cost* value.
The cost value is meant to roughly estimate both the cost (in terms of computing power) of the conversion,
as well as the accuracy or immediacy of the conversion.
For example, resizing an image to a lower size should have a high cost, because the process is computationally expensive,
but also because a smaller image represents the original image to a lesser degree.
Similarily, an URL to a piece of content is a less immediate representation than the content itself,
so the cost of a *convert* that simply generates the URL to a piece of data should be high even if the process is very cheap to compute.

Cost is defined in this way to make sure that the result of a type-coercion operation reflects the content that was present as accurately as possible.
It is also important to prevent some nonsensical results from occuring, such as displaying a link to content instead of the content itself because
the link requires less steps to create than completely converting the content does.

Type coercion is implemented using a general pathfinding algorithm, similar to A\*.
First, the set of given *types* is found by selecting all *facets* of the *fileder* that match the *name* given in the query.
The set of given *types* is marked in green in the following example graph.

From there the algorithm recursively checks whether it can reach other types by applying all matching *converts* to the type
that is cheapest to reach, excluding any types that have already been exhaustively-searched in this way.
All types it finds, that have not yet been inserted into the set of given types are then added to the set,
so that they may be searched as well.

The algorithm doesn't stop immediately after reaching a type from the result set,
it continues search until it either completely exhausts the result space,
or until all non-exhaustively searched paths are already higher than the maximum allowed path.
This ensures that the optimal path is found, even if a more expensive path is found more quickly initially.

<mmm-embed path="type_coercion_graph">excerpt of the graph of conversion paths from two starting facets to mmm/dom</mmm-embed>
