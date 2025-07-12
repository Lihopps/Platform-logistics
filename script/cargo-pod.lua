local network_class=require("script.network")
local LPN_gui_manager=require("script.LPN_gui_manager")

local function on_cargo_pod_finished_descending(e)
    local cargo_pod = e.cargo_pod
    if cargo_pod and cargo_pod.valid then
        local cargo_pod_inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
        if cargo_pod_inventory and cargo_pod_inventory.valid then
            local contents = cargo_pod_inventory.get_contents()
            if next(contents) then
                local destination = cargo_pod.cargo_pod_destination
                if destination then
                    if destination.type == defines.cargo_destination.station then
                        if destination.station.name == "ptflog-requester" then
                            local channel = storage.ptflogtracker[destination.station.unit_number]
                            if channel then
                                for i = 1, #contents do
                                    if storage.ptflogchannel[channel].building["ptflog-requester"][destination.station.unit_number].incomming[contents[i].name .. "_" .. contents[i].quality] then
                                        local destination_inventory=destination.station.get_inventory(defines.inventory.cargo_landing_pad_main)
                                        if destination_inventory and destination_inventory.valid then
                                            local inserted=destination_inventory.insert(contents[i])
                                            if inserted then
                                                cargo_pod_inventory.remove({name=contents[i].name,count=inserted,quality=contents[i].quality})
                                            end
                                        end
                                        local platform=cargo_pod.cargo_pod_origin.unit_number
                                        network_class.update_incomming(storage.ptflogchannel[channel],destination.station.unit_number,contents[i].name,contents[i].quality,-contents[i].count)
                                        network_class.update_incomming_platform(storage.ptflogchannel[channel],destination.station.unit_number,contents[i].name,contents[i].quality,platform)
                                        LPN_gui_manager.update_manager__gen_gui()
                                    end
                                end
                            end
                        elseif destination.station.name == "space-platform-hub" then
                            -- il va sur platform liée a un channel
                            local silo = cargo_pod.cargo_pod_origin
                            local channel = storage.ptflogtracker["S" .. destination.station.surface.index]
                            if silo and silo.valid then
                                local surface_origin = silo.surface
                                local providers = surface_origin.find_entities_filtered { name = "ptflog-provider" }
                                if providers then
                                    for _, provider in ipairs(providers) do
                                        if storage.ptflogtracker[provider.unit_number] == channel then
                                            for i = 1, #contents do
                                                if storage.ptflogchannel[channel].building["ptflog-provider"][provider.unit_number].reserved[contents[i].name .. "_" .. contents[i].quality] then
                                                    network_class.update_reserved(storage.ptflogchannel[channel],provider.unit_number,contents[i].name,contents[i].quality,-contents[i].count)
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
    end
end

local function on_cargo_pod_finished_ascending(e)

end

local function on_space_platform_changed_state(e)
    local platform=e.platform
    if platform and platform.valid then
        if platform.surface then
            if storage.ptflogtracker["S"..platform.surface.index] and storage.ptflogtracker["S"..platform.surface.index]~="NONE" then
                if platform.state==defines.space_platform_state.waiting_at_station then
                    local schedule=platform.schedule
                    if schedule then
                        if #schedule.records==1 then
                            network_class.set_platform_unloading(platform,schedule.records[1].station)
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
    [defines.events.on_cargo_pod_finished_ascending] = on_cargo_pod_finished_ascending,
    [defines.events.on_space_platform_changed_state] = on_space_platform_changed_state,
}


return cargo
