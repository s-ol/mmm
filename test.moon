package.moonpath = './?.server.moon;./?/init.server.moon;' .. package.moonpath
require 'mmm.init'
import render from require 'mmm.mmmfs'
import load_fileder from require 'mmm.mmmfs.fs'

-- usage:
-- moon render.moon <output> <fileder_path>
{ output_name, path } = arg

assert output_name, "please specify the output filename as an argument"
assert path, "please specify the path name to build as an argument"

root = load_fileder 'root' .. path
root\mount path

print root
