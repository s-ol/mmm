Lately I've been thinking about note-taking tools.

I use a few different systems for taking notes almost daily:
- multiple paper notebooks and sheets of paper as available
- random freeform text files spread around my (various) PCs
- google keep

I like taking paper notes because it's easy to switch to doodle and sketch and layout everything together.
I also find that it stimulates my thinking a bit more that typing text; I'm not quite sure why that is.

Anyway, I was looking for solutions to replace google keep, mostly because I like to self-host my services.

## file system use cases
- retrieve a file i know exists
  - either file i know 100%
  - or looking for a file based on content, guessing where and how it might be
- show related files to what i am looking for
- allow exploring content

### tags and search don't solve anything
Many proposals in [FileSystemAlternatives][c2-fsalt] and [LimitsOfHierarchies][c2-loh] are to generalize up from Hierarchies to Set Theory.
This in effect means exchanging the any-to-one association between 'containers' (folders/tags) and 'contents' (files) for a any-to-any association.
Files are then no longer identified by their chain of parents, but rather by their belonging and not-belonging to all the existant tags.
Generally the proposal is to query these tag-based filesystems using combinatory logic such as `a AND (b OR NOT(C))` and so on.

My main problem with this approach is that sooner or later you end up with a huge list of tags that is just unmanageable.
It's obvious that this won't scale as the amount of tag increases with the amount of different data,
especially in a collaborative, professional or otherwise networked context.

Since the tags are all stored flatly in a bag of stuff, they also cannot meaningfully express relationships between each other.
This is clearly evident in any software that uses tags as the only option of organizing large amounts of data,
especially when multiple users have access.
Here is an example of a typical list of defined tags for issue tracking on github:

![github tags][github-tags]

As can be seen easily, users are shoehorning more information into the label name string than the label is made to store.
As this extra data is only available to humans interpreting the text, it cannot be used to create good UI:
Instead of seeing a drop-down for *Tech Complexity*, users need to go through the label list.
Even the simplest logical constraints cannot be documented and enforced with this system.

-> need for *dynamically changeable* data schemas

/*
But even organizing and finding files with this paradigm is not a very nice experience; take these UI designs for example:

![set picker from tablizer][tablizer-tagging]
![search dialog from tablizer][tablizer-search]

Granted, it's not particularily fair to take these designs from 2002, but this paradigm is all around us today and the UX hasn't gotten a lot better.
Here's the same set picker functionality as seen on google keep, today:

![labelling UI in google keep][keep-label]

And for the search, they didn't even try. There's just a list

A very thorough proposal for a file system can be found in [*A Novel, Tag-Based File System*][tag-based-fs].

This approach 
*/

### is there more?
- the file system as a note-taking app

[tiddlywiki]: https://tiddlywiki.com/
[tablizer-search]: http://www.reocities.com/tablizer/setscrn1.gif
[tablizer-tagging]: http://www.reocities.com/tablizer/setpicker.gif
[tablizer-src]: http://www.reocities.com/tablizer/sets1.htm
[tag-based-fs]: http://digitalcommons.macalester.edu/cgi/viewcontent.cgi?article=1036&context=mathcs_honors
[finder-column-view]: http://cdn.osxdaily.com/wp-content/uploads/2010/03/set-column-view-size-default-mac-os-x-finder-610x307.jpg
[finder-column-view-src]: http://osxdaily.com/2010/03/25/setting-the-default-column-size-in-mac-os-x-finder-windows/
[finder-list-view]: http://cdn.osxdaily.com/wp-content/uploads/2014/12/messages-attachments-folder-mac-osx.jpg
[finder-list-view-src]: http://osxdaily.com/2014/12/03/access-attachments-messages-mac-os-x/
