if MODE == 'CLIENT' then
  return { }
end
local posix = require('posix')
return {
  {
    inp = 'text/x-scss',
    out = 'text/css',
    cost = 1,
    transform = function(self, content)
      local r0, w0 = posix.pipe()
      local r1, w1 = posix.pipe()
      local r2, w2 = posix.pipe()
      local pid = assert(posix.fork())
      if pid == 0 then
        posix.close(w0)
        posix.close(r1)
        posix.close(r2)
        posix.dup2(r0, posix.fileno(io.stdin))
        posix.dup2(w1, posix.fileno(io.stdout))
        posix.dup2(w2, posix.fileno(io.stderr))
        posix.close(r0)
        posix.close(w1)
        posix.close(w2)
        local err = assert(posix.execp('sassc', '-s'))
        posix._exit(err)
        return 
      else
        posix.close(r0)
        posix.close(w1)
        posix.close(w2)
        posix.write(w0, content)
        posix.close(w0)
        local _, status
        _, _, status = posix.wait(pid)
        local out
        if status == 0 then
          out = r1
        else
          out = r2
        end
        out = assert(posix.fdopen(out, 'r'))
        out = out:read('a')
        posix.close(r1)
        posix.close(r2)
        if status == 0 then
          return out
        else
          return error(out)
        end
      end
    end
  }
}
