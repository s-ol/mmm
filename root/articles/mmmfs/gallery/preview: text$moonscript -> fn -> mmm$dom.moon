import div, img, br from require 'mmm.dom'

=> div {
  'the first pic as a little taste:',
  br!,
  img src: @children[1]\get 'preview', 'URL -> image/png'
}
    }

--  for i=1,25
--    id = 120 + i
--    .children[i] = Fileder {
--    'name: alpha': "image#{id}"
--      'URL -> image/png': "https://picsum.photos/600/600/?image=#{id}"
--      'preview: URL -> image/png': "https://picsum.photos/200/200/?image=#{id}"
--    }
