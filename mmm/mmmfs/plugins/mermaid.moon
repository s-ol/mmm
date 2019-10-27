assert window and window.mermaid, "mermaid.js not found"

window.mermaid\initialize {
  startOnLoad: false
  fontFamily: 'monospace'
}

id_counter = 1

{
  converts: {
    {
      inp: 'text/mermaid-graph'
      out: 'mmm/dom'
      cost: 1
      transform: (source, fileder, key) =>
        id_counter += 1
        id = "mermaid-#{id_counter}"
        with container = document\createElement 'div'
          cb = (svg) =>
            .innerHTML = svg
            .firstElementChild.style.width = '100%'
            .firstElementChild.style.height = 'auto'

          window\setImmediate (_) ->
            window.mermaid\render id, source, cb, container
    }
  }
}
