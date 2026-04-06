--local LPN_gui_manager = require("script.gui.LPN_gui_manager")
local reservation_manager = require("script.reservation_manager")

local v1_0_4 = require("migration.1_0_4")


local debug = {}


commands.add_command("lpn_rebuild", nil,
    function(command)
        remote.call("LPN_remote","rebuild")
        game.print("LOGISTIC PLANET NETWORK : LPN GUI MANAGER REBUILT")
    end)

commands.add_command("lpn_migration", nil,
    function(command)
        v1_0_4.change()
        --game.print("Simulation changement effectué")
    end)

commands.add_command("lpn_reset", nil,
    function(command)
        debug.reset(true)
    end)

commands.add_command("lpn_clear", nil,
    function(command)
        debug.control_system(true)
    end)

function debug.reset(print)
    if print then game.print("LOGISTIC PLANET NETWORK : Start complete reset") end
    storage.idle_platforms = {}
    storage.requests = {}
    storage.supplies = {}
    storage.reservations = {}
    storage.request_reservations = {}
    for id, platform in pairs(storage.platforms) do
        platform.entity.get_schedule().clear_records()
        platform.mission = nil
        plaform.mission_index = 1
    end
    if print then game.print("LOGISTIC PLANET NETWORK : End complete reset") end
end

--controls that all item requested by both provider and requester has platform => release reservations
function debug.control_system(print)
    if print then game.print("LOGISTIC PLANET NETWORK : Start complete reset") end
    local items_data = {}
    for id, items in pairs(storage.reservations) do
        for itemqal, amount in pairs(items) do
            if not items_data[itemqal] then items_data[itemqal] = {} end
            items_data[itemqal]["prov"] = (items_data[itemqal]["prov"] or 0) + amount
        end
    end
    for id, items in pairs(storage.request_reservations) do
        for itemqal, amount in pairs(items) do
            if not items_data[itemqal] then items_data[itemqal] = {} end
            items_data[itemqal]["req"] = (items_data[itemqal]["req"] or 0) + amount
        end
    end

    for itemqal, data in pairs(items_data) do
        local item_transported = false
        if data["req"] == data["prov"] and data["req"] > 0 then -- request avec la meme quantité par prov et req => donc on verifie que c'est bien pris en charge par une platform
            for id, platform in pairs(storage.platforms) do
                if platform.mission and next(platform.mission) then
                    for index, surface_data in pairs(platform.mission) do
                        for surface_index, surface_station in pairs(surface_data) do
                            for index_station, station in ipairs(surface_station) do
                                if station.item then
                                    if station.item[itemqal] then
                                        item_transported = true
                                        goto continue
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not item_transported then
                --on release tout
                for id, items in pairs(storage.reservations) do
                    reservation_manager.release_supply({ station = { id = id } }, itemqal, data["prov"])
                end
                for id, items in pairs(storage.request_reservations) do
                    reservation_manager.release_request_supply({ station = { id = id } }, itemqal, data["prov"])
                end
            end
        end

        ::continue::
    end
    if print then game.print("LOGISTIC PLANET NETWORK : End complete reset") end
end

return debug
