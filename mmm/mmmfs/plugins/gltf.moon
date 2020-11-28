dom = require 'mmm.dom'

{
  converts: {
    {
      inp: 'URL -> model/gltf-binary'
      out: 'mmm/dom'
      cost: 1
      transform: (href) =>
        dom['model-viewer'] {
          src: href
          'auto-rotate': true
          'camera-controls': true
          'camera-orbit': "548.2deg 117deg 282.4m"
        }
    }
  }

  scripts: [[
    <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js"></script>
    <script nomodule src="https://unpkg.com/@google/model-viewer/dist/model-viewer-legacy.js"></script>
  ]]
}
