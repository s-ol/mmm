# motivation

The majority of users interacts with modern computing systems in the form of smartphones, laptops or desktop PCs,
using the mainstream operating systems Apple iOS and Mac OS X, Microsoft Windows or Android.

All of these operating systems share the concept of *Applications* (or *Apps*) as one of the core pieces of their interaction model.
Functionality and capabilities of the digital devices are bundled in, marketed, sold and distributed as *Applications*.

In addition, a lot of functionality is nowadays delivered in the form of *Web Apps*, which are used inside a *Browser* (which is an *Application* itself).
*Web Apps* often offer similar functionality to other *Applications*, but are subject to some limitations:
In most cases, they are only accessible or functional in the presence of a stable internet connection,
and they have very limited access to the resources of the physical computer they are running on.
For example, they usually cannot interact directly with the file system, hardware peripherals or other applications,
other than through a standardized set of interactions (e.g. selecting a file via a visual menu, capturing audio and video from a webcam, opening another website).

On the two Desktop Operating Systems (Mac OS X and Windows), file management and the concepts of *Documents* are still central
elements of interactions with the system. The two prevalent smartphone systems deemphasize this concept by only allowing access to the 
data actually stored on the device through an app itself.

This focus on *Applications* as the primary unit of systems can be seen as the root cause of multiple problems:
Because applications are the products companies produce, and software represents a market of users,
developers compete on features integrated into their applications.

However this lack of control over data access is not the only problem the application-centric approach induces:
A consequence of this is that interoperability between applications and data formats is rare.
To stay relevant, monlithic software or software suites are designed to 
As a result applications tend to accrete features rather then modularise and delegate to other software [P Chiusano].
Because applications are incentivised to keep customers, they make use of network effects to keep customers locked-in.
This often means re-implementing services and functinality that is already available
and integrating it directly in other applications produced by the same organisation.

This leads to massively complex file formats,
such as for example the .docx format commonly used for storing mostly
textual data enriched with images and videos on occasion.
The docx format is in fact an archive that can contain many virtual files internally,
such as the images and videos referenced before.
However this is completely unknown to the operating system,
and so users are unable to access the contents in this way.
As a result, editing an image contained in a word document is far from a trivial task:
first the document has to be opened in a word processing application,
then the image has to be exported from it and saved in its own, temporary file.
This file can then be edited and saved back to disk.
Once updated, the image may be reimported into the .docx document.
If the word-processing application supports this,
the old image may be replaced directly, otherwise the user may have to remove the old image,
insert the new one and carefully ensure that the positioning in the document remains intact.

https://www.theverge.com/2019/10/7/20904030/adobe-venezuela-photoshop-behance-us-sanctions


The application-centric computing paradigm common today is harmful to users,
because it leaves behind "intert" data as D. Cragg calls it:

[Cragg 2016]
D. Cragg coins the term "inert data" for the data created, and left behind, by apps and applications in the computing model that is currently prevalent:
Most data today is either intrinsically linked to one specific application, that controls and limits access to the actual information,
or even worse, stored in the cloud where users have no direct access at all and depend soley on online tools that require a stable network connection
and a modern browser, and that could be modified, removed or otherwise negatively impacted at any moment.

This issue is worsened by the fact that the a lot of software we use today is deployed through the cloud computing and SaaS paradigms,
which are far less reliable than earlier means of distributing software:
Software that runs in the cloud is subject to outages due to network problems,
pricing or availability changes etc. at the whim of the company providing it, as well as ISPs involved in the distribution.
Cloud software, as well as subscription-model software with online-verification mechanisms are additionally subject
to license changes, updates modifiying, restricting or simply removing past functionality etc.
Additionally, many cloud software solutions and ecosystems store the users' data in the cloud,
where they are subject to foreign laws and privacy concerns are intransparently handled by the companies.
Should the company, for any reason, be unable or unwanting to continue servicing a customer,
the data may be irrecoverably lost (or access prevented).

Data rarely really fits the metaphora of files very well,
and even when it does it is rarely exposed to the user that way:
The 'Contacts' app on a mobile phone or laptop for example does not store each contacts's information
in a separate 'file' (as the metaphora may have initially suggested),
but rather keeps this database hidden away from the user.
Consequently, access to the information contained in the database is only enabled through the contacts applications GUI.

--

According to some researchers in the field of Human-Computer-Interaction, the state of computing is rather dire.

It seems that a huge majority of daily computer users have silently accepted
that real control over their most important everyday tool will be forever out of reach,
and surrendered it to the relatively small group of 'programmers' curating their experience.

- Applications are bad
- Services are worse


Chiusano blames these issues on the metaphor of the *machine*, and likens apps and applications to appliances.
According to him, what should really be provided are *tools*:
composable pieces of software that naturally lend themselves to, or outrightly call for,
integration into the users' other systems and customization,
rather than lure into the walled-gardens of corporate ecosystems using network-effects.
 
Data is inert [Cragg 2016]

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

Creative use of computer technology is limited to programmers, since applications constrain their users to the
paths and abilities that the developers anticipated and deemed useful.
Note that 'creative' here does not only encompass 'artistic': this applies to any field and means
that innovative use of technology is unlikely to happen as a result of practice by domain experts.
