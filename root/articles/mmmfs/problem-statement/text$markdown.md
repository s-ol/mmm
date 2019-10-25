# motivation

The state of sof
According to some researchers in the field of Human-Computer-Interaction, the state of computing is rather dire.

It seems that a huge majority of daily computer users have silently accepted
that real control over their most important everyday tool will be forever out of reach,
and surrendered it to the relatively small group of 'programmers' curating their experience.

- Applications are bad
- Services are worse


[Cragg 2016]
D. Cragg coins the term "inert data" for the data created, and left behind, by apps and applications in the computing model that is currently prevalent:
Most data today is either intrinsically linked to one specific application, that controls and limits access to the actual information,
or even worse, stored in the cloud where users have no direct access at all and depend soley on online tools that require a stable network connection
and a modern browser, and that could be modified, removed or otherwise negatively impacted at any moment.

Chiusano blames these issues on the metaphor of the *machine*, and likens apps and applications to appliances.
According to him, what should really be provided are *tools*:
composable pieces of software that naturally lend themselves to, or outrightly call for,
integration into the users' other systems and customization,
rather than lure into the walled-gardens of corporate ecosystems using network-effects.
 
Services like this are 

not even directly accessible to end-users anymore
Data is inert ko[Cragg 2016]

Key points:
- data ownership  
  data needs to be freely accessible (without depending on a 3rd party) and unconditionally accessible
- data compatibility  
  data needs to be usable outside the context of it's past use (in the worst case)
- functionality  
  user needs many, complex needs met


Today, computer users are losing more and more control over their data. Between web and cloud
applications holding customer data hostage for providing the services, unappealing and limited mobile file
browsing experiences and the non-interoperable, proprietary file formats holding on to their own data has
become infeasible for many users. mmmfs is an attempt at rethinking file-systems and the computer user
experience to give control back to and empower users.

mmmfs tries to provide a filesystem that is powerful enough to let you use it as your canvas for thinking,
and working at the computer.  mmmfs is made for more than just storing information. Files in mmmfs can interact
and morph to create complex behaviours.

Let us take as an example the simple task of collecting and arranging a mixed collection of images, videos
and texts in order to brainstorm. To create an assemblage of pictures and text, many might be tempted to open an
Application like Microsoft Word or Adobe Photoshop and create a new document there. Both photoshop files and
word documents are capable of containing texts and images, but when the files are saved, direct access to the
contained data is lost. It is for example a non-trivial and unenjoyable task to edit an image file contained
in a word document in another application and have the changes apply to the document. In the same way,
text contained in a photoshop document cannot be edited in a text editor of your choice.
