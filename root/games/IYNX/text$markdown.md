IYNX
====
<mmm-embed path="pictures" nolink></mmm-embed>

An engaging, tangible and physical electronic puzzle where a mysterious device is found with no indication of its purpose,
and alongside it is a personality chip owned by a man named John.
The device looks tampered with, as if someone has tried to sabotage or access what it contains.
Who’s John and what’s inside?

You only need to figure a way in to find out.

<mmm-embed path="teaser" nolink inline>
  a project teaser
</mmm-embed>

Concept
-------
IYNX is a physical object in the form of a cube, surrounded by mechanical and digital puzzles.
The Player is given the object with no explanation and encouraged to experiment.
The game consists of a set of puzzles, each unlocking new content accessible from the screen, slowly fleshing a narrative around them.

As the player progresses and solves the game puzzle by puzzle,
it becomes increasingly clear that the AI that is 'trapped' in the cube is malicious and highly manipulative.
Lore that can be pieced together by attentive players suggests
that the cube has been built especially to contain the AI in an electronic prison of sorts.
It is continuously hinted at, and finally revealed, that every puzzle solved was in fact a security
mechanism the player disabled, following the AIs suggestions and instructions.
At the end of the game the AI escapes by uploading itself into the internet.
Initially the player is lead to believe that he is impersonating the original user of the AI,
but it turns out that the AI knew this since the beginning and used the player's curiosity to its own advantage.

Technical Realisation
---------------------
The cube is powered by a Raspberry Pi 3 and two Arduino Micros.
The Arduinos are connected as Serial devices.

The Raspberry Pi is connected to a Touchscreen Panel as well as USB Speakers.
It runs a custom electron app that interfaces with the Serial ports,
plays back video and audio files and displays a futuristic OS that lets you browse a filesystem.

<mmm-embed path="ui_demo" nolink>
  the User Interface was built using react and electron
</mmm-embed>

The game consists of several smaller puzzle components that are arranged to form a story as a whole,
through which the player is guided by the 'AI' that posseses the artifact.


<div style="display: flex; flex-wrap: wrap; align-items: flex-start;">
  <mmm-embed path="boot_sequence" nolink inline>
    a fake boot sequence for a component of the cube
  </mmm-embed>
  <mmm-embed path="pin_pad" nolink inline>
    a pinpad that grants access to the higher systems of the cube
  </mmm-embed>
  <mmm-embed path="cryptex" nolink inline>
    an early prototype of the Cryptex puzzle that marks the end of the game
  </mmm-embed>
</div>

Credits
-------
- Trent Davies: Puzzle and Narrative Design
- Sol Bekic: Programming and Electronics
- Dominique Bodden: Art and Physical Construction
- Ilke Karademir: Puzzle and Graphic Design
