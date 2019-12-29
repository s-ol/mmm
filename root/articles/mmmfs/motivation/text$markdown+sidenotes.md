motivation
==========

application-centric design
--------------------------

The majority of users interact with modern computing systems in the form of smartphones, laptops or desktop PCs,
using the mainstream operating systems Apple iOS and Mac OS X, Microsoft Windows or Android.

All of these operating systems share the concept of *Applications* (or *Apps*) as one of the core pieces of their
interaction model. Functionality and capabilities of the digital devices are bundled in, marketed, sold and distributed
as applications.

<!-- native vs other vs new ?? -->
<!-- limitations not mentioned yet -->
In addition, a lot of functionality is nowadays delivered in the form of *Web Apps* or *Cloud Services*, which share the 
limitations of native applications in addition to more specific issues that will be discussed in a separate section
below.

This focus on applications as the primary unit of systems can be seen as the root cause of multiple problems.

<!--                                                                           rephrase vvv -->
For one, since applications are the products companies produce, and software represents a market of users,
developers compete on features integrated into their applications. To stay relevant, monlithic software or software
suites tend to accrete features rather then modularise and delegate to other software<mmm-embed wrap="sidenote"
path="../references/appliances"></mmm-embed>. This makes many software packages more complex and unintuitive than
they need to be, and also cripples interoperability between applications and data formats.

Because applications are incentivised to keep customers, they make use of network effects to keep customers locked-in.
This often means re-implementing services and functionality that is already available to users,
and integrating it directly in other applications or as a new product by the same organisation.
While this strategy helps big software companies retain customers, it harms the users, who have to navigate a complex
landscape of multiple incompatible, overlapping and competing software ecosystems.
Data of the same kind, a rich-text document for example, can be shared easily within the software systems of a certain
manufacturer, and with other users of the same, but sharing with users of a competing system, even if it has almost the
exact same capabilities, can often be problematic.

Another issue is that due to the technical challenges of building tools in this system, applications are designed and
developed by experts in application development, rather than experts in the domain of the tool. While developers may
solicit feedback, advice and ideas from domain experts, communication is a barrier. Additionally, domain experts are
generally unfamiliar with the technical possibilities, and may therefore not be able to express feedback that would lead
to more significant advances.
<mmm-embed path="creative" wrap="marginnote"></mmm-embed>
As a result, creative use of computer technology is limited to programmers, since applications constrain their users to
the paths and abilities that the developers anticipated and deemed useful.

The application-centric computing metaphor treats applications as black boxes, and provides no means to understand,
customize or modify the behaviour of apps, intentionally obscuring the inner-workings of applications and
completely cutting users off from this type of ownership over their technology. While the trend seems to be to further
hide the way desktop operating systems work<mmm-embed path="../references/osx-files" wrap="sidenote"></mmm-embed>,
mobile systems like Apple's *iOS* already started out as such so-called *walled gardens*.

cloud computing
---------------

*Web Apps* often offer similar functionality to other applications, but are subject to additional limitations:
In most cases, they are only accessible or functional in the presence of a stable internet connection,
and they have very limited access to the resources of the physical computer they are running on.
For example, they usually cannot interact directly with the file system, hardware peripherals or other applications,
other than through a standardized set of interactions (e.g. selecting a file via a visual menu, capturing audio and
video from a webcam, opening another website).

Cloud software, as well as subscription-model software with online-verification mechanisms, are additionally subject
to license changes, updates modifiying, restricting or simply removing past functionality etc. Additionally, many cloud
software solutions and ecosystems store the users' data in the cloud, often across national borders, where legal and
privacy concerns are intransparently handled by the companies. If a company, for any reason, is unable or unwanting to
continue servicing a customer, the users data may be irrecoverably lost (or access prevented). This can have serious
consequences<mmm-embed path="../references/adobe" wrap="sidenote"></mmm-embed>, especially for professional users, for
whom an inability to access their tools or their cloud-stored data can pose an existential threat.

inert data (formats)
--------------------

Cragg coins the term "inert data"<mmm-embed path="../references/super-powers" wrap="sidenote"></mmm-embed> for the data
created, and left behind, by apps and applications in the computing model that is currently prevalent: Most data today
is either intrinsically linked to one specific application, that controls and limits access to the actual information,
or even worse, stored in the cloud where users have no direct access at all and depend soley on online tools that
require a stable network connection and a modern browser, and that could be modified, removed or otherwise negatively
impacted at any moment.

Aside from being inaccesible to users, the resulting complex proprietary formats are also opaque and useless to other
applications and the operating system, which often is a huge missed opportunity: 
The .docx format for example, commonly used for storing mostly textual data enriched with images and on occasion videos,
is in fact a type of archive that can contain many virtual files internally, such as the various media files contained
within. However this is completely unknown to the user and operating system, and so users are unable to access the
contents in this way. As a result, editing an image contained in a word document is far from a trivial task: first the
document has to be opened in a word processing application, then the image has to be exported from it and saved in its
own, temporary file. This file can then be edited and saved back to disk. Once updated, the image may be reimported
into the .docx document. If the word-processing application supports this, the old image may be replaced directly,
otherwise the user may have to remove the old image, insert the new one and carefully ensure that the positioning in
the document remains intact.

disjointed filesystems
----------------------

The filesystems and file models used on modern computing devices generally operate on the assumption that every
individual file stands for itself. Grouping of files in folders is allowed as a convenience for users, but most
applications only ever concern themselves with a single file at a time, independent of the context the file is stored in
in the filesystem.

Data rarely really fits this metaphora of individual files very well, and even when it does, it is rarely exposed to
the user that way: The 'Contacts' app on a mobile phone for example does not store each contacts's information in a
separate 'file' (as the metaphora may suggest initially), but rather keeps all information in a single database file,
which is hidden away from the user. Consequently, access to the information contained in the database is only enabled
through the contacts application's graphical interface, and not through other applications that generically operate on
files.

Another example illustrates how a more powerful file (organisation) system could render such formats and applications
obsolete: Given the simple task of collecting and arranging a mixed collection of images, videos and texts in order to
brainstorm, many might be tempted to open an application like *Microsoft Word* or *Adobe Photoshop* and create a new
document there. Both *Photoshop* files and *Word* documents are capable of containing texts and images, but when such
content is copied into them from external sources, such as other files on the same computer, or quotes and links from
the internet, these relationships are irrevocably lost. As illustrated above, additionally, it becomes a lot harder to
edit the content once it is aggregated as well. To choose an application for this task is a trade-off, because in
applications primarily designed for word processing, arranging content visually is harder and image editing and video
embedding options are limited, while tools better suited to these tasks lack nuance when working with text.

Rather than face this dilemma, a more sensible system could leave the task of positioning and aggregating content of
different types to one software component, while multiple different software components can be responsible for editing
the individual pieces of content, so that the most appropriate one can be chosen for each element.

<div style="height: 2rem;"></div>

To summarize, for various reasons, the metaphors and interfaces of computing interfaces today prevent users from deeply
understanding the software they use and the data they own, from customizing and improving their experience and
interactions, and from properly owning, contextualising and connecting their data.

Interestingly, these deficits do not appear throughout the history of todays computing systems, but are based in rather
recent developments in the field. In fact the most influental systems in the past aspired to the polar opposites, as i
will show in the next section.

<!--
Chiusano blames these issues on the metaphor of the *machine*, and likens apps and applications to appliances.
According to him, what should really be provided are *tools*:
composable pieces of software that naturally lend themselves to, or outrightly call for,
integration into the users' other systems and customization,
rather than lure into the walled-gardens of corporate ecosystems using network-effects.
-->
