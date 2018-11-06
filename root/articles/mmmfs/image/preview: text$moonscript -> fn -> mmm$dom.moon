import img from require 'mmm.dom'

-- look for main content with 'URL to png' type
-- and wrap in an mmm/dom image tag
=> img src: @gett 'URL -> image/png'
