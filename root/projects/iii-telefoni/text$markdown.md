<mmm-embed path="boxes" nolink></mmm-embed>
tre telefoni
============

*Tre Telefoni* is an installation piece and experimental cooperative game that seeks to unite three strangers by
tasking them with getting to know each other despite complications.

It consists of three wall-mounted telephone boxes set up out of earshot from each other.
When a player is ready on each of the stations, the phones become active and the three players are connected to each other.
However their communication is complicated by the unconventional nature of the phone system they are using:
Each phone is set up to only relay sound from its microphone to the next station in turn:

- player A's speech is transmitted only to player B,
- player B's speech is only transmitted to player C, and
- player C's speech is only transmitted to player A.

<mmm-embed path="heads" nolink></mmm-embed>

The players have to try to figure out a way to communicate to each other despite not being able to directly respond to each other in order to find out each other's identities.
If they succeed, they can optionally try to arrange a meeting point on the grounds of the showcase to debrief and reflect on their experience.

Though *Tre Telefoni* has been designed as an installation piece as described above,
a [web-based rototype][proto] is also available to playtest the premise itself.

artist statement
----------------
*Tre telefoni* seeks to challenge our notion of *conversation* by letting us experience a mode of communication designed for use by digital agents.

Conversation traditionally presumes bidirectionality and a way for its subjects to respond directly to each other.
However we are not the only agents conversing: digital devices all around us are also steadily communicating, and while these digital conversations borrow human communication as a metaphor, they mostly take very different forms than our human conversations.
The 'ring topology' (also called 'daisy chaining') is one of the many *network topologies* that digital devices use to communicate.
In a 'ring network topology' each member of the network only talks to its successor, and all members need to collaborate in order to pass messages around.

technical realisation
---------------------
Each station is powered by a single-board computer (Raspberry Pi) connected to
- a USB headset (remade into a telephone handle)
- an ethernet switch shared by all stations to network them together
- a small speaker for the ringing sound

The physical realisation of the station enclosures and telephone handles are currently a work in progress.
The software exists as a protoype version that can be accessed at [iii-telefoni.s-ol.nu][proto]
and playtested for example on mobile phones (compatibility with iOS devices may vary).

[proto]: //iii-telefoni.s-ol.nu
