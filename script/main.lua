local migrations = require("script.migrations")
local network=require("script.network")
local LPN_gui_manager=require("script.LPN_gui_manager")

local v1_0_4=require("migration.1_0_4")

local main={}

function main.on_init()
    if not storage.ptflogchannel then storage.ptflogchannel ={} end
    if not storage.ptflogchannel["DEFAULT"] then network.create_channel("DEFAULT") end
    if not storage.ptflogtracker then storage.ptflogtracker ={} end
    if not storage.ptflogmessenger then storage.ptflogmessenger ={} end
    if not storage.ptflogfilter then storage.ptflogfilter ={} end
end

function main.on_configuration_changed(e)
    migrations.on_configuration_changed(e)
    network.check_network()
    LPN_gui_manager.rebuild()
end

main.events={

}

return main
