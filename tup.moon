package.moonpath = './?.shared.moon;./?.server.moon;' .. package.moonpath
require 'lib.init'
import routes from require 'app'

for { :name, :dest } in *routes
  print ": |> ^ HTML #{name}^ moon render.moon #{name} > %o |> dist/#{dest}"
