import define_fileders from require 'mmm.mmmfs'
import div, h1, a, img, br from require 'mmm.dom'

Fileder = define_fileders ...

with Fileder {
      'name: alpha': 'gallery',
      'title: text/plain': "A Gallery of 25 random pictures, come in!",
      'preview: fn -> mmm/dom': => div {
        'the first pic as a little taste:',
        br!,
        img src: @children[1]\get 'preview', 'URL -> image/png'
      }
      'fn -> mmm/dom': =>
        link = (child) -> a {
          href: '#',
          onclick: -> BROWSER\navigate child.path
          img src: child\gett 'preview', 'URL -> image/png'
        }

        content = [link child for child in *@children]
        table.insert content, 1, h1 'gallery index'
        div content

      'slideshow: fn -> mmm/dom': =>
        import ReactiveVar, text, elements from require 'mmm.component'

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
  for i=1,25
    id = 120 + i
    .children[i] = Fileder {
    'name: alpha': "image#{id}"
      'URL -> image/png': "https://picsum.photos/600/600/?image=#{id}"
      'preview: URL -> image/png': "https://picsum.photos/200/200/?image=#{id}"
    }
