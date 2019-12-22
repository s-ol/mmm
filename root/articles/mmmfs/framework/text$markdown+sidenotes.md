evaluation framework
====================

In the following section, I will collect approaches and reviews of different end-user software systems from current
literature, as well as derive and present my own requirements and guiding principles for the development of a new system.

The *UNIX Philosophy* <mmm-link path="../references/unix"></mmm-link> describes the software design paradigm
pioneered in the creation of the Unix operating system at the AT&T Bell Labs research center in the 1960s. The
concepts are considered quite influental and are still notably applied in the Linux community. Many attempts at
summaries exist, but the following includes the pieces that are especially relevant even today:

> Even though the UNIX system introduces a number of innovative programs and techniques, no single program or idea makes it work well.
> Instead, what makes it effective is the approach to programming, a philosophy of using the computer. Although that philosophy can't be
> written down in a single sentence, at its heart is the idea that the power of a system comes more from the relationships among programs
> than from the programs themselves. Many UNIX programs do quite trivial things in isolation, but, combined with other programs,
> become general and useful tools.

This approach has multiple benefits with regard to end-user programmability: Assembling the system out of simple,
modular pieces means that for any given task a user may want to implement, it is very likely that preexisting parts
of the system can help the user realize a solution. Wherever such a preexisting part exists, it pays off designing it
in such a way that it is easy to integrate for the user later. Assembling the system as a collection of modular,
interacting pieces also enables future growth and customization, since pieces may be swapped out with customized or
alternate software at any time. 

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
