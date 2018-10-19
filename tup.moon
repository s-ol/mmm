package.moonpath = './?.shared.moon;./?.server.moon;' .. package.moonpath
require 'lib.init'
import routes from require 'app'
import opairs from require 'lib.ordered'

for name, { :dest } in opairs routes
  print ": |> ^ HTML #{name}^ moon render.moon #{name} > %o |> dist/#{dest}"
