Two of the earliest wholistic computing systems, the Xerox Alto and Xerox Star, both developed at Xerox PARC and introduced in the 70s and early 80s, pioneered not only graphical user-interfaces, but also the "Desktop Metaphor".
The desktop metaphor presents information as stored in "Documents" that can be organized in folders and on the "Desktop". It invokes a strong analogy to physical tools.
One of the differences between the Xerox Star system and other systems at the time, as well as the systems we use currently, is that the type of data a file represents is directly known to the system.

<div class="sidenote"><mmm-embed raw path="../references/xerox-star"></mmm-embed></div>

> In a Desktop metaphor system, users deal mainly with data files, oblivious to the existence of programs.
> They do not "invoke a text editor", they "open a document".
> The system knows the type of each file and notifies the relevant application program when one is opened.
>
> The disadvantage of assigning data files to applications is that users sometimes want to operate on a file with a program other than
its "assigned" application. \[...\]
> Star's designers feel that, for its audience, the advantages of allowing users to forget
about programs outweighs this disadvantage.

Other systems at the time lacked any knowledge of the type of files,
and while mainstream operating systems of today have retro-fit the ability to associate and memorize the preferred applications to use for a given file based on it's name suffix, the intention of making applications a secondary, technical detail of working with the computer has surely been lost.

Another design detail of the Star system is the concept of "properties" that are stored for "objects" throughout the system (the objects being anything from files to characters or paragraphs).
These typed pieces of information are labelled with a name and persistently stored, providing a mechanism to store metadata such as user preference for ordering or defaut view of a folder for example.

***

Fig. 8 - Star Retrospective

The earliest indirect influence for the Xerox Alto and many other systems of its time,
was the *Memex*. The *Memex* is a hypothetical device and system for knowledge management.
Proposed by Vannevar Bush in 1945, the concept predates much of the technology that later was used to implement many parts of the vision. In essence, the concept of hypertext was invented.

***

One of the systems that could be said to have come closest to a practical implementation of the Memex might be Apple's *Hypercard*.

https://archive.org/details/CC501_hypercard

"So I can have the information in these stacks tied together in a way that makes sense"

In a demonstration video, the creators of the software showcase a system of stacks of cards that together implement, amongst others, a calendar (with yearly and weekly views), a list of digital business cards for storing phone numbers and addresses, and a todo list.
However these stacks of cards are not just usable by themselves, it is also demonstrated how stacks can link to each other in meaningful ways, such as jumping to the card corresponding to a specific day from the yearly calendar view, or automatically looking up the card corresponding to a person's first name from a mention of the name in the text on a different card.

Alongside Spreadsheets, *Hypercard* remains one of the most successful implementations of end-user programming, even today.
While it's technical abilities have been long matched and passed by other software (such as the ubiquitous HTML hypertext markup language), these technical successors have failed the legacy of *Hypercard* as an end-user tool:
while it is easier than ever to publish content on the web (through various social media and microblogging services), the benefits of hypermedia as a customizable medium for personal management have nearly vanished.
End-users do not create hypertext anymore.

The *UNIX Philosophy* <mmm-link path="../references/unix"></mmm-link>
describes the software design paradigm pioneered in the creation of the Unix operating system at the AT&T Bell Labs
research center in the 1960s. The concepts are considered quite influental and are still notably applied in the Linux community.
Many attempts at summaries exist, but the following includes the pieces that are especially relevant even today:

> Even though the UNIX system introduces a number of innovative programs and techniques, no single program or idea makes it work well.
> Instead, what makes it effective is the approach to programming, a philosophy of using the computer. Although that philosophy can't be
> written down in a single sentence, at its heart is the idea that the power of a system comes more from the relationships among programs
> than from the programs themselves. Many UNIX programs do quite trivial things in isolation, but, combined with other programs,
> become general and useful tools.

This approach has multiple benefits with regard to end-user programmability:
Assembling the system out of simple, modular pieces means that for any given task a user may want to implement,
it is very likely that preexisting parts of the system can help the user realize a solution.
Wherever such a preexisting part exists, it pays off designing it in such a way that it is easy to integrate for the user later.
Assembling the system as a collection of modular, interacting pieces also enables future growth and customization,
since pieces may be swapped out with customized or alternate software at any time. 

***

Based on this, a modern data storage and processing ecosystem should enable transclusion of both content and behaviours
between contexts.
Content should be able to be transcluded and referenced to facilitate the creation of flexible data formats and interactions,
such that e.g. a slideshow slide can include content in a variety other formats (such as images and text) from anywhere else in the system.
Behaviours should be able to be transcluded and reused to facilitate the creation of ad-hoc sytems and applets based on user needs.
For example a user-created todo list should be able to take advantage of a sketching tool the user already has access to.

The system should enable the quick creation of ad-hoc software.

While there are drawbacks to cloud-storage of data (as outlined above), the utility of distributed systems is acknowledged,
and the system should therefore be able to include content and behaviours via the network.
This ability should be integrated deeply into the system,
so that data can be treated independently of its origin and storage conditions, with as little caveats as possible.

The system needs to be browsable and understandable by users.

In order to provide users full access to their information as well as the computational infrastructure,
users need to be able to finely customize and reorganize the smallest pieces to suit their own purposes,
in other words: be able to program.

While there is an ongoing area of research focusing on the development of new programming paradigms, 
methodologies and tools that are more accessible and cater to the wide
range of end-users<mmm-link path="../references/subtext"></mmm-link>,
in order to keep the scope of this work appropriate,
conventional programming languages are used for the time being.
Confidence is placed in the fact that eventually more user-friendly languages will be available and,
given the goal of modularity, should be implementable in a straightforward fashion.

*Ink and Switch* suggest three qualities for tools striving to support
end-user programming<mmm-link path="../references/inkandswitch"></mmm-link>:

- "Embodiment", i.e. reifying central concepts of the programming model as more concrete, tangible objects
  in the digital space (for example through visual representation),
  in order to reduce cognitive load on the user.
- "Living System", by which they seem to describe the malleability of a system or environment,
  and in particular the ability to make changes at different levels of depth in the system with
  very short feedback loops and a feeling of direct experience.
- "In-place toolchain", denoting the availability of tools to customize and author the experience,
  as well as a certain accesibility of these tools, granted by a conceptual affinity between the
  use of the tools and general 'passive' use of containing system at large. 
