I'm giving a workshop next weekend, and I had to create the slides for that.
Since one of the aspirations of `mmmfs` is to be easily adaptable to any kind of data organization and -presentation task,
that was a good opportunity to try and implement a simple slideshow system.

I started by creating a new fileder to hold the slideshow, [`/articles/xy-workshop`](/articles/xy-workshop/).
In the main facet, I created a MoonScript file.
Since the facet needs to access its children (the individual slides), I also used the `fn ->` type,
that injects the current fileder into the script.

`text/moonscript -> fn -> mmm/dom`

    import ReactiveVar, tohtml, fromhtml, text, elements from require 'mmm.component'
    import article, button, div, span from elements

    =>
      index = ReactiveVar 1
      slide = index\map (index) -> @children[index]

      local view
      view = div {
        style: ... -- styling ommited here

        div {
          style: ... -- styling omitted here

          slide\map => @get 'mmm/dom'
        }
      }
      
      local left, right
      if MODE == 'CLIENT'
        left = (_, e) ->
          e\preventDefault!
          index\transform (a) -> math.max 1, a - 1

        right = (_, e) ->
          e\preventDefault!
          index\transform (a) -> math.min #@children, a + 1

      tohtml with article!
        \append div {
          button '<', onclick: left
          ' '
          span index\map (t) -> text t
          ' '
          button '>', onclick: right
        }
        \append view

I used the `mmm.component` library that lets me create reactive UIs.
First I declare the reactive variable `index`, the current slide number.
Then I derive the `slide` reactive variable, that is defined to be the child with index `index` -
since these are `ReactiveVar`s, whenever `index` changes, `slide` will automatically load the current slide fileder.

Then I create the main slide view, which consists mainly of two containers and some styling.
Inside, I derive another reactivevar from `slide`: whenever a new `slide` is selected,
this piece of code will request the main content in `mmm/dom` format and replace the current view content with that.

Lastly I construct a little navigation UI, consisting of the left and right buttons.
When one of them is clicked, it modifies the `index` variable, making sure to stay in the range of existing slides.
The rest of the UI then reactively updates accordingly.

Lastly I added keyboard controls for cycling through the slides, as well as a button to enter fullscreen mode.
You can find the extended code for that in the commit [`ca24ef1`][ca24ef1],
but it is not a lot either: with the additions the file is 70 lines long.

With this done, it is just a matter of creating children-fileders and placing whichever content I want in them,
they behave just like any other page of the system now.

[ca24ef1]: https://git.s-ol.nu/mmm/blob/ca24ef108dbb11860e719711e4e7fbd6323aee0e/root/articles/xy-workshop/text%24moonscript%20-%3E%20fn%20-%3E%20mmm%24dom.moon
