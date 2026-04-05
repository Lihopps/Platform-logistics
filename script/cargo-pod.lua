local reservation_manager = require("script.reservation_manager")
local util = require("script.util")

local function on_cargo_pod_finished_descending(e)
    local cargo_pod = e.cargo_pod
    if cargo_pod and cargo_pod.valid then
        local cargo_pod_inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
        if cargo_pod_inventory and cargo_pod_inventory.valid then
            local destination = cargo_pod.cargo_pod_destination
            if destination then
                if destination.type == defines.cargo_destination.station then
                    if destination.station.name == "ptflog-requester" then
                        local contents = cargo_pod_inventory.get_contents()
                        if next(contents) then
                            for i = 1, #contents do
                                local res = storage.request_reservations[destination.station.unit_number]
                                if not res then goto continue end
                                res = res[contents[i].name .. "_" .. contents[i].quality]
                                if not res then goto continue end
                                local inv = destination.station.get_inventory(defines.inventory.cargo_landing_pad_main)
                                local num = inv.insert({ name = contents[i].name, quality = contents[i].quality, count =
                                contents[i].count })
                                cargo_pod_inventory.remove({ name = contents[i].name, quality = contents[i].quality, count =
                                num })
                                reservation_manager.release_request_supply(destination,
                                    contents[i].name .. "_" .. contents[i].quality, num)
                                ::continue::
                            end
                        end
                    elseif destination.station.name == "space-platform-hub" then
                        local platform = storage.platforms[destination.station.unit_number]
                        if platform then
                            if not platform.mission then return end
                            local mission_index = platform.mission_index
                            local etape = platform.mission[mission_index]
                            if etape then
                                for _, station in pairs(etape[next(etape)]) do
                                    local contents = cargo_pod_inventory.get_contents()
                                    if next(contents) and station.item then
                                        for i = 1, #contents do
                                            if station.item[contents[i].name .. "_" .. contents[i].quality] then
                                                local res = storage.reservations[station.station.id]
                                                if not res then goto continue2 end
                                                res = res[contents[i].name .. "_" .. contents[i].quality]
                                                if not res then goto continue2 end

                                                local inv = destination.station.get_inventory(defines.inventory
                                                .cargo_landing_pad_main)
                                                local num = inv.insert({ name = contents[i].name, quality = contents[i]
                                                .quality, count = contents[i].count })
                                                cargo_pod_inventory.remove({ name = contents[i].name, quality = contents[i]
                                                .quality, count = num })
                                                reservation_manager.release_supply(station,
                                                    contents[i].name .. "_" .. contents[i].quality, num)
                                            end
                                            ::continue2::
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


local cargo = {}

cargo.events = {
    [defines.events.on_cargo_pod_finished_descending] = on_cargo_pod_finished_descending,
    --[defines.events.on_cargo_pod_finished_ascending] = on_cargo_pod_finished_ascending,
}


return cargo
