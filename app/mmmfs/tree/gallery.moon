import div, h1, a, img, br from require 'lib.dom'

children = for i=1,100
  id = math.floor math.random! * 200
  Fileder {
    'name: alpha': "image#{id}"
    'URL -> image/png': "https://picsum.photos/600/600/?image=#{id}"
    'preview: URL -> image/png': "https://picsum.photos/200/200/?image=#{id}"
  }

props = {
  'name: alpha': 'gallery',
  'title: text/plain': "A Gallery of 100 random pictures, come in!",
  'preview: moon -> mmm/dom': => div {
    'the first pic as a little taste:',
    br!,
    img src: @children[1]\get 'preview', 'URL -> image/png'
  }
  'moon -> mmm/dom': =>
    link = (child) -> a {
      href: '#',
      onclick: -> BROWSER\navigate { 'gallery', (child\get 'name', 'alpha'), nil },
      img src: child\gett 'preview', 'URL -> image/png'
    }

    content = [link child for child in *@children]
    table.insert content, 1, h1 'gallery index'
    div content

  'slideshow: moon -> mmm/dom': =>
    import ReactiveVar, text, elements from require 'lib.component'

    index = ReactiveVar 1

    prev = (i) -> math.max 1, i - 1
    next = (i) -> math.min #@children, i + 1

    e = elements
    e.div {
      e.div {
        e.a 'prev', href: '#', onclick: -> index\transform prev
        index\map (i) -> text " image ##{i} "
        e.a 'next', href: '#', onclick: -> index\transform next
      },
      index\map (i) -> img src: @children[i]\gett nil, 'URL -> image/png'
    }
}

Fileder props, children
