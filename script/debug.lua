local LPN_gui_manager= require("script.LPN_gui_manager")

local v1_0_4=require("migration.1_0_4")


local debug={}

function debug.network_request_state(network)
    for entity_number,state in pairs(network.building["ptflog-requester"]) do
        for item,_ in pairs(network.building["ptflog-requester"][entity_number].request) do
            local req=network.building["ptflog-requester"][entity_number].request[item]
            local income=network.building["ptflog-requester"][entity_number].incomming[item]
            game.print(item .." request : "..req.."/ incomming : "..income)
        end
    end
end

commands.add_command("lpn_rebuild", nil,
    function(command)
       LPN_gui_manager.rebuild()
       game.print("LOGISTIC PLANET NETWORK : LPN GUI MANAGER REBUILT")
    end)

commands.add_command("lpn_migration", nil,
    function(command) 
       v1_0_4.change()
       --game.print("Simulation changement effectué")
    end)

return debug