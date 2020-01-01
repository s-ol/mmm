# 3. evaluation framework

In this section, I will collect approaches and reviews of different end-user software systems from current literature,
as well as derive and present my own requirements and guiding principles for the development of a new system.

Firstly, I will take a look at a framework for evaluating end-user computing systems from literature, before presenting
three concrete design principles and components for a new system.

3.1 qualities of successful end-user computing
----------------------------------------------

*Ink and Switch* suggest three qualities for tools striving to support
end-user programming<mmm-embed path="../references/inkandswitch" wrap="sidenote"></mmm-embed>:

- *Embodiment*, i.e. reifying central concepts of the programming model as more concrete, tangible objects
  in the digital space (for example through visual representation),
  in order to reduce cognitive load on the user.
- *Living System*, by which they seem to describe the malleability of a system or environment,
  and in particular the ability to make changes at different levels of depth in the system with
  very short feedback loops and a feeling of direct experience.
- *In-place toolchain*, denoting the availability of tools to customize and author the experience,
  as well as a certain accessibility of these tools, granted by a conceptual affinity between the
  use of the tools and general 'passive' use of containing system at large. 

These serve as guiding principles for the design and evaluation of computer systems for end-users, but are by nature
very abstract. The following properties are therefore derived as more concrete proposals based on more specific
constraints: namely the construction of a system for end-users to keep, structure and display personal information and
thoughts.

3.2 modularity
--------------

The *UNIX Philosophy*<mmm-embed path="../references/unix" wrap="sidenote"></mmm-embed> describes the software design
paradigm pioneered in the creation of the Unix operating system at the AT&T Bell Labs research center in the 1960s. The
concepts are considered quite influential and are still notably applied in the Linux community. Many attempts at
summaries exist, but the following includes the pieces that are especially relevant even today:

<mmm-embed path="../references/unix" wrap="marginnote"></mmm-embed>
> Even though the UNIX system introduces a number of innovative programs and techniques, no single program or idea makes
> it work well. Instead, what makes it effective is the approach to programming, a philosophy of using the computer.
> Although that philosophy can't be written down in a single sentence, at its heart is the idea that the power of a
> system comes more from the relationships among programs than from the programs themselves. Many UNIX programs do quite
> trivial things in isolation, but, combined with other programs, become general and useful tools.

This approach has multiple benefits with regard to end-user programmability: Assembling the system out of simple,
modular pieces means that for any given task a user may want to implement, it is very likely that preexisting parts
of the system can help the user realize a solution. Wherever such a preexisting part exists, it pays off designing it
in such a way that it is easy to integrate for the user later. Assembling the system as a collection of modular,
interacting pieces also enables future growth and customization, since pieces may be swapped out with customized or
alternate software at any time.

Settling on a specific modular design model, and reifying other components of a system in terms of it, also corresponds
directly to the concept of *Embodiment* described by Ink & Switch.

3.3 content transclusion
------------------------

The strengths of modular architectures should similarly extend also into the way the system will be used by users.
If users are to store their information and customized behaviour in such an architecture, then powerful tools need to be
present in order to assemble more complex solutions out of such parts. Therefore static content should be able to be
linked to (as envisioned for the *Memex*, see above), but also to be <mmm-embed wrap="marginnote"
path="../references/transclusion">The term <i>transclusion</i> refers to the concept of including content from a
separate document, possibly stored remotely, by reference rather than by duplication. See also
</mmm-embed>*transcluded*,
to facilitate the creation of flexible data formats and interactions, such that e.g. a slideshow slide can include
content in a variety other formats (such as images and text) from anywhere else in the system. Behaviours also should be
able to be transcluded and reused to facilitate the creation of ad-hoc systems and applets based on user needs. For
example a user-created todo list should be able to take advantage of a sketching tool the user already has access to.

By forming the immediately user-visible layer of the system out of the same abstractions that the deeper levels of the
system are made of, the sense of a *Living System* is also improved: skills that are learned at one (lower) level of the
system carry on into further interaction with the system on deeper levels, as does progress in understanding the
system's mechanisms.

While there are drawbacks to cloud-storage of data (as outlined above), the utility of distributed systems is
acknowledged, and the system should therefore be able to include content and behaviours via the network.
This ability should be integrated deeply into the system, so that data can be treated independently of its origin and
storage conditions, with as little caveats as possible. In particular, the interactions of remote data access and
content transclusion should be paid attention to and taken into consideration for a system's design.

3.4 end-user programming
------------------------

In order to provide users full access to their information as well as the computational infrastructure,
users need to be able to finely customize and reorganize the smallest pieces to suit their own purposes,
in other words: be able to program.

While there is an ongoing area of research focusing on the development of new programming paradigms, 
methodologies and tools that are more accessible and cater to the wide
range of end-users<mmm-embed path="../references/subtext" wrap="sidenote"></mmm-embed>,
in order to keep the scope of this work appropriate,
conventional programming languages are used for the time being.
Confidence is placed in the fact that eventually more user-friendly languages will be available and,
given the goal of modularity, should be implementable in a straightforward fashion.
