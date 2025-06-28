lihop_debug=false

if lihop_debug then
    for name, prototype in pairs(data.raw["space-connection"]) do
        prototype.length = 2000
    end
end


require("prototypes.entity.ptflog-provider")
require("prototypes.entity.ptflog-requester")
require("prototypes.technology")
require("prototypes.utility-sprite")
require("prototypes.tipsandtrick")

table.insert(data.raw["space-platform-hub"]["space-platform-hub"].flags,"get-by-unit-number")

