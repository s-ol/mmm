There was a longer break in development of the projects as I have been focusing on the thesis,
where progress is not represented accurately in the repository.

There was also some progress on featurse that haven't been tidied up and committed yet,
such as drag'n'drop / direct file upload. Those features will probably get their own post sometime soon.

Today I spent some time to implement one of the example use-cases that will be part of the theoretical text as well,
[the 'pinwall' demo][pinwall] \[[`5ec1fe2`][5ec1fe2]\].

The Pinwall example renders all its children as resizeable and movable boxes that can be freely positioned on a canvas:

<mmm-embed nolink path="demo"></mmm-embed>

Any changes to the box positions and sizes are saved persistently as a `pinwall_info` facet on each child.
For example the size and coordinates of the image can be found at [`image/pinwall_info: text/json`][info].

Rendering the children themselves is pretty easy:

```moon
import article, div from require 'mmm.dom'
import convert from require 'mmm.mmmfs.conversion'

update_info = (fileder, x, y, w, h) ->
  info = (fileder\get 'pinwall_info: table') or x: 100, y: 100, w: 300, h: 300
  info.x = x if x
  info.y = y if y
  info.w = w if w
  info.h = h if h

  json = convert 'table', 'text/json', info, fileder, 'pinwall_info'
  fileder\set 'pinwall_info: text/json', json
  
=>
  observe = ... -- (ommited - calls `update_info` when child is resized)

  children = for child in *@children
      info = (child\get 'pinwall_info: table') or x: 100, y: 100, w: 300, h: 300
      wrapper = div {
        style:
          position: 'absolute'
          -- (more styling omitted here)

          left: "#{info.x}px"
          top: "#{info.y}px"
          width: "#{info.w}px"
          height: "#{info.h}px"

        -- handle for moving the child
        div {
          style:
            -- (styling omitted here)

          onmousedown: ... -- (omitted)
        }

        -- child content
        div {
          style:
            width: '100%'
            height: '100%'
            background: 'var(--white)'

          (child\gett 'mmm/dom')
        }
      }
      
      observe wrapper, child

      wrapper

  children.style = {
    width: '1000px'
    height: '500px'
  }
  
  children.onmouseup = ... -- (omitted)
  children.onmousemove = ... -- (omitted)
  children.onmouseleave = ... -- (omitted)
  
  article children
```

[The rest of the code][source] is just about catching the events when the mouse is clicked/release/moved and when a child is resized,
and then calling `update_info` as appropriate.

[info]: /articles/mmmfs/examples/pinwall/image/pinwall_info:%20text/html+interactive
[pinwall]: /articles/mmmfs/examples/pinwall/
[source]: https://git.s-ol.nu/mmm/blob/5ec1fe2fc943ad4123fac138de70d4152e8b341d/root/articles/mmmfs/examples/pinwall/text%24moonscript%20-%3E%20fn%20-%3E%20mmm%24dom.moon
[5ec1fe2]: https://git.s-ol.nu/mmm/blob/5ec1fe2fc943ad4123fac138de70d4152e8b341d/
