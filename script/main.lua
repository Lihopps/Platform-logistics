--local routing=require("script.routing")
local migrations=require("script.migrations")
local dispatcher = require("script.dispatcher")
local LPN_gui_manager =require("script.gui.LPN_gui_manager")

local DISPATCH_INTERVAL = settings.global["LPN-dispatcher-update"].value
local MANAGER_GUI_INTERVAL = settings.global["LPN-manager-update"].value


local main={}
local update=false
function main.on_init()
    if not storage.platforms then storage.platforms = {} end
    if not storage.idle_platforms then storage.idle_platforms = {}   end

    if not storage.requests then storage.requests = {}  end
    if not storage.request_nodes then storage.request_nodes = {}  end

    if not storage.supplies then storage.supplies = {}  end
    if not storage.supply_nodes then storage.supply_nodes = {}  end

    if not storage.reservations then storage.reservations = {}  end
    if not storage.request_reservations then storage.request_reservations = {}  end


end

function main.on_configuration_changed(e)
    migrations.on_configuration_changed(e)
    LPN_gui_manager.rebuild()
end

local function on_tick(event)
    if (event.tick % DISPATCH_INTERVAL == 0) then
        dispatcher.update()
        if settings.global["LPN-enable-dispatcher"].value then
            dispatcher.dispatch()
        end
    end

    if update then
        LPN_gui_manager.rebuild()
        update=false
        
    end
    if (event.tick+60) % MANAGER_GUI_INTERVAL == 0 then
        LPN_gui_manager.updateP()
    end
end


main.events={
    [defines.events.on_tick] = on_tick
}

return main
