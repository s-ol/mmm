if MODE == 'CLIENT'
  return {}

posix = require 'posix'

{
  {
    inp: 'text/x-scss'
    out: 'text/css'
    cost: 1
    transform: (content) =>
      r0, w0 = posix.pipe!
      r1, w1 = posix.pipe!
      r2, w2 = posix.pipe!

      pid = assert posix.fork!
      if pid == 0
        posix.close w0
        posix.close r1
        posix.close r2

        posix.dup2 r0, posix.fileno io.stdin
        posix.dup2 w1, posix.fileno io.stdout
        posix.dup2 w2, posix.fileno io.stderr

        posix.close r0
        posix.close w1
        posix.close w2

        err = assert posix.execp 'sassc', '-s'
        posix._exit err
        return
      else
        posix.close r0
        posix.close w1
        posix.close w2

        posix.write w0, content
        posix.close w0

        _, _, status = posix.wait pid

        out = if status == 0 then r1 else r2
        out = assert posix.fdopen out, 'r'
        out = out\read 'a'

        posix.close r1
        posix.close r2

        if status == 0
          out
        else
          error out
  }
}
