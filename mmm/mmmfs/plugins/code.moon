import pre from require 'mmm.dom'
import languages from require 'mmm.highlighting'

-- syntax-highlighted code
{
  converts: {
    {
      inp: 'text/([^ ]*).*'
      out: 'mmm/dom'
      cost: 5
      transform: (val) =>
        lang = @from\match @convert.inp
        pre languages[lang] val
    }
  }
}
