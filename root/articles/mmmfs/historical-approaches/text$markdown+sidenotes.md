# 2. historical approaches

Two of the earliest holistic computing systems, the Xerox Alto and Xerox Star, both developed at Xerox PARC and
introduced in the 70s and early 80s, pioneered not only graphical user-interfaces, but also the "Desktop Metaphor".
The desktop metaphor presents information as stored in "Documents" that can be organized in folders and on the
"Desktop". It invokes a strong analogy to physical tools. One of the differences between the Xerox Star system and
other systems at the time, as well as the systems we use currently, is that the type of data a file represents is
directly known to the system.

In a retrospective analysis of the Xerox Star's impact on the computer
industry, the desktop metaphor is described as
follows:

<mmm-embed path="../references/xerox-star" wrap="marginnote"></mmm-embed>
> In a Desktop metaphor system, users deal mainly with data files, oblivious to the existence of programs.
> They do not "invoke a text editor", they "open a document".
> The system knows the type of each file and notifies the relevant application program when one is opened.
>
> The disadvantage of assigning data files to applications is that users sometimes want to operate on a file with a
> program other than its "assigned" application. \[...\]
> Star's designers feel that, for its audience, the advantages of allowing users to forget about programs outweighs
> this disadvantage.

Other systems at the time lacked any knowledge of the type of files, and while mainstream operating systems of today
have retro-fit the ability to associate and memorize the preferred applications to use for a given file based on it's
name suffix, the intention of making applications a secondary, technical detail of working with the computer has
surely been lost.

Another design detail of the Star system is the concept of "properties" that are stored for "objects" throughout the
system (the objects being anything from files to characters or paragraphs). These typed pieces of information are
labelled with a name and persistently stored, providing a mechanism to store metadata such as user preference for
ordering or the default view mode of a folder for example.

<mmm-embed path="star-graph" facet="note" wrap="marginnote" style="margin-top: 1rem;"></mmm-embed>
<mmm-embed path="star-graph" nolink></mmm-embed>

The earliest indirect influence for the Xerox Alto and many other systems of its time, was the *Memex*.
The *Memex* is a hypothetical device and system for knowledge management. Proposed by Vannevar Bush in 1945<mmm-embed
path="../references/memex" wrap="sidenote"></mmm-embed>, the concept predates much of the technology that later was used
to implement many parts of the vision.

<!--
While the article extrapolates from existing technology at the time, describing at times
very concrete machinery based on microfilm and mechanical contraptions, many of the conceptual predictions became
true or inspired  ....
-->

One of the most innovative elements of Bush's predictions is the idea of technologically cross-referenced and
connected information, which would later be known and created as *hypertext*. While hypertext powers the majority of
today's internet, many of the advantages that Bush imagined have not carried over into the personal use of computers.
There are very few tools for creating personal, highly-interconnected knowledge bases, even though it is technologically
feasible and a proven concept (exemplified for example by the massively successful online encyclopedia
*Wikipedia*<mmm-embed path="../references/wikipedia" wrap="sidenote"></mmm-embed>).

While there are little such tools available today, one of the systems that could be said to have come closest to a
practical implementation of a Memex-inspired system for personal use might be Apple's *HyperCard*.

In a live demonstration<mmm-embed path="../references/hypercard" wrap="sidenote"></mmm-embed>, the creators of the
software showcase a system of stacks of cards that together implement, amongst others, a calendar (with yearly and
weekly views), a list of digital business cards for storing phone numbers and addresses, and a todo list. However these
stacks of cards are not just usable by themselves, it is also demonstrated how stacks can link to each other in
meaningful ways, such as jumping to the card corresponding to a specific day from the yearly calendar view, or
automatically looking up the card corresponding to a person's first name from a mention of the name in the text on a
different card.

Alongside Spreadsheets, *HyperCard* remains one of the most successful implementations of end-user programming, even
today. While its technical abilities have been long matched and surpassed by other software (such as the ubiquitous
*Hypertext Markup Language*, HTML and the associated programming language *JavaScript*), these technical successors have
failed the legacy of *HyperCard* as an end-user tool: While it is easier than ever to publish content on the web
(through various social media and microblogging services), the benefits of hypermedia as a customizable medium for
personal management have nearly vanished. End-users do not create hypertext anymore.
