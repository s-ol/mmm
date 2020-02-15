# 2&emsp;drawbacks of current systems

The project that this thesis accompanies was created out of frustration with the computing systems that are currently
popular and widely available to end-users. The following sections document and exemplify the perceived shortcomings that
these systems exhibit, as attributed to specific concepts or paradigms that the systems seem to be designed around. 

2.1&emsp;application-centric design
-----------------------------------

The majority of users interact with modern computing systems in the form of smartphones, laptops or desktop PCs,
using the mainstream operating systems Apple iOS and Mac&nbsp;OS&nbsp;X, Microsoft&nbsp;Windows or Android.

<mmm-embed path="app-types" wrap="marginnote"></mmm-embed>
All of these operating systems share the concept of *Applications* (or *Apps*) as one of the core pieces of their
interaction model. The functionality and capabilities of digital devices are bundled, marketed, sold and distributed
as applications. This focus on applications as the primary unit of systems can be seen as the root cause of multiple
problems.

For one, since applications are produced by private companies on the software market,
developers compete on features integrated into their applications. To stay relevant, monolithic software or software
suites tend to accrete features rather then modularize and delegate to other software<mmm-embed wrap="sidenote"
path="../references/appliances"></mmm-embed>. This makes many software packages more complex and unintuitive than
they need to be, and also cripples interoperability between applications and data formats.

Because (private) software developers are incentivized to keep customers, they make use of network effects to keep
customers locked-in. This often means re-implementing services and functionality that is already available to users,
and integrating it directly in other applications or as a new product by the same organization.
While this strategy helps big software companies retain customers, it harms users, who have to navigate a complex
landscape of multiple incompatible, overlapping, and competing software ecosystems.
Data of the same kind, a rich-text document, for example, can be shared easily within the software systems of a certain
manufacturer and with other users of the same, but sharing with users of a competing system, even if it has almost the
same capabilities, can often be problematic<mmm-embed path="../references/lock-in" wrap="sidenote"></mmm-embed>.

Another issue is that due to the technical challenges of development in this paradigm, applications are designed and
developed by experts in application development, rather than experts in the domain of the tool. While developers may
solicit feedback, advice, and ideas from domain experts, communication is a barrier. Additionally, domain experts are
generally unfamiliar with the technical possibilities, and may therefore not be able to express feedback that would lead
to more significant advances.
<mmm-embed path="creative" wrap="marginnote"></mmm-embed>
As a result, creative use of computer technology is limited to programmers, since applications constrain their users to
the paths and abilities that the developers anticipated and deemed useful.

The application-centric computing metaphor treats applications as black boxes and provides no means to understand,
customize or modify the behavior of apps, intentionally obscuring the inner-workings of applications and
completely cutting users off from this type of ownership over their technology. While the trend seems to be to further
hide the way desktop operating systems work<mmm-embed path="../references/osx-files" wrap="sidenote"></mmm-embed>,
mobile systems like Apple's *iOS* were designed as such *walled gardens* from the start.

2.2&emsp;cloud computing
------------------------

*Web Apps* often offer similar functionality to other applications but are subject to additional limitations:
In most cases, they are only accessible or functional in the presence of a stable internet connection,
and they have very limited access to the resources of the physical computer they are running on.
For example, they usually cannot interact directly with the file system, hardware peripherals or other applications,
other than through a standardized set of interactions (e.g. selecting a file via a visual menu, capturing audio and
video from a webcam, opening another website).

Cloud software, as well as subscription-model software with online-verification mechanisms, are additionally subject
to license changes, updates modifying, restricting or simply removing past functionality, etc. Additionally, many cloud
software solutions and ecosystems store the users' data in the cloud, often across national borders, where legal and
privacy concerns are intransparently handled by the companies. If a company, for any reason, is unable or unwilling to
continue servicing a customer, the user's data may be irrecoverably lost (or access prevented). This can have serious
consequences<mmm-embed path="../references/adobe" wrap="sidenote"></mmm-embed>, especially for professional users, for
whom an inability to access their tools or their cloud-stored data can pose an existential threat.

2.3&emsp;inert data (and data formats)
--------------------------------------

Cragg coins the term "inert data"<mmm-embed path="../references/super-powers" wrap="sidenote"></mmm-embed> for the data
created and left behind by apps and applications in the computing model that is currently prevalent: Most data today
is either intrinsically linked to one specific application, that controls and limits access to the actual information,
or, even worse, stored in the cloud where users have no direct access at all. In the latter case, users depend solely on
online tools that require a stable network connection and a modern browser and could be modified, removed, or otherwise
negatively impacted at any moment.

Aside from being inaccessible to users, the resulting complex proprietary formats are also opaque and useless to other
applications and the operating system, which often is a huge missed opportunity: 
The .docx format, for example, commonly used for storing mostly textual data enriched with images and on occasion videos,
is in fact a type of archive that can contain many virtual files internally, such as the various media files contained
within. However this is completely unknown to the user and operating system, and so users are unable to access the
contents in this way. As a result, editing an image contained in a word document is far from a trivial task: first the
document has to be opened in a word processing application, then the image has to be exported from it and saved in its
own, temporary file. This file can then be edited and saved back to disk. Once updated, the image may be reimported
into the .docx document. If the word-processing application supports this, the old image may be replaced directly,
otherwise, the user may have to remove the old image, insert the new one, and carefully ensure that the positioning in
the document remains intact.

2.4&emsp;disjointed filesystems
-------------------------------

The filesystems and file models used on modern computing devices generally operate on the assumption that every
individual file stands for itself. Grouping of files in folders is allowed as a convenience for users, but most
applications only ever concern themselves with a single file at a time, independent of the context the file is stored
in.

Data rarely really fits this concept of individual files very well, and even when it does, it is rarely exposed to
the user that way: The 'Contacts' app on a mobile phone, for example, does not store each contact's information in a
separate 'file' (as the word may suggest initially), but rather keeps all information in a single database file,
which is hidden away from the user. Consequently, access to the information contained in the database is only enabled
through the contacts application's graphical interface, and not through other applications that generically operate on
files.

Another example illustrates how a more powerful file (organization) system could render such formats and applications
obsolete: Given the simple task of collecting and arranging a mixed collection of images, videos, and texts to
brainstorm, many might be tempted to open an application like *Microsoft Word* or *Adobe Photoshop* and create a new
document there. Both *Photoshop* files and *Word* documents are capable of containing texts and images, but when such
content is copied into them from external sources, such as other files on the same computer, or quotes and links from
the internet, these relationships are irrevocably lost. As illustrated above, additionally, it becomes a lot harder to
edit the content once it is aggregated. To choose an application for this task is a hard trade-off to make, because in
applications primarily designed for word processing, arranging content visually is hard to do, and image editing and
video embedding options are limited, while tools better suited to these tasks lack nuance when working with text.

To avoid facing this dilemma, a more sensible system could leave the task of positioning and aggregating content of
different types to one software component, while multiple different software components could be responsible for editing
the individual pieces of content so that the most appropriate one can be chosen for each element. While creating the
technological interface between these components is certainly a challenge, the resulting system would greatly benefit
from the exponentially-growing capabilities resulting from the modular reuse of components across many contexts: A rich
text editor component could be used for example not just in a mixed media collection as proposed above, but also for
an email editor or the input fields in a browser.

<div style="height: 2rem;"></div>

To summarize, for various reasons, the metaphors and driving concepts of computing interfaces today prevent users from
deeply understanding the software they use and the data they own, from customizing and improving their experience and
interactions, and from properly owning, contextualizing and connecting their data.

Interestingly, these deficits do not appear throughout the history of today's computing systems but are based in rather
recent developments in the field. In fact, the most influential systems in the past aspired to the polar opposites, as I
will show in the next section.

<!--
Chiusano blames these issues on the metaphor of the *machine*, and likens apps and applications to appliances.
According to him, what should really be provided are *tools*:
composable pieces of software that naturally lend themselves to, or outrightly call for,
integration into the users' other systems and customization,
rather than lure into the walled-gardens of corporate ecosystems using network-effects.
-->
