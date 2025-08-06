local network_class = require("script.network")
local LPN_gui_manager = require("script.LPN_gui_manager")
local util = require("script.util")


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
                                    if util.check(channel, destination.station, contents[i], "requester") then
                                        if storage.ptflogchannel[channel].building["ptflog-requester"][destination.station.unit_number].incomming[contents[i].name .. "_" .. contents[i].quality] then
                                            local destination_inventory = destination.station.get_inventory(defines
                                            .inventory.cargo_landing_pad_main)
                                            if destination_inventory and destination_inventory.valid then
                                                local inserted = destination_inventory.insert(contents[i])
                                                if inserted then
                                                    if inserted > 0 then
                                                        cargo_pod_inventory.remove({ name = contents[i].name, count =
                                                        inserted, quality = contents[i].quality })
                                                    end
                                                end
                                            end
                                            local platform = cargo_pod.cargo_pod_origin.unit_number
                                            network_class.update_incomming(storage.ptflogchannel[channel],
                                                destination.station.unit_number, contents[i].name, contents[i].quality,
                                                -contents[i].count)
                                            network_class.update_incomming_platform(storage.ptflogchannel[channel],
                                                destination.station.unit_number, contents[i].name, contents[i].quality,
                                                platform)
                                            --LPN_gui_manager.update_manager__gen_gui()
                                        end
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
                                                if util.check(channel, provider, contents[i], "provider") then
                                                    if storage.ptflogchannel[channel].building["ptflog-provider"][provider.unit_number].reserved[contents[i].name .. "_" .. contents[i].quality] then
                                                        network_class.update_reserved(storage.ptflogchannel[channel],
                                                            provider.unit_number, contents[i].name, contents[i].quality,
                                                            -contents[i].count)
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
end

local function redirection(cargo_pod, surface, network)
    local entity_list = { "ptflog-requester" }
    if network == "NONE" then
        table.insert(entity_list, "cargo-landing-pad")
        network = nil
    end
    local entities = surface.find_entities_filtered { name = entity_list, force = cargo_pod.force }
    local possible_dest = {
        with_request = {},
        without = {}
    }

    --on selectionne l'item en plus grand nombre
    local item=nil
    local cargo_pod_inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if cargo_pod_inventory and cargo_pod_inventory.valid then
        local contents = cargo_pod_inventory.get_contents()
        if next(contents) then
            table.sort(contents,function (left,right)
                return left.count>right.count
            end)
            item={name=contents[1].name,quality=contents[1].quality,count=contents[1].count}
        end
    end

    if item==nil then return end

    --on classe les possible destination
    
    for _, entity in pairs(entities) do
        local delivered_quantity=0
        if entity and entity.valid then
            if entity.unit_number then
                if storage.ptflogtracker[entity.unit_number] == network then
                    local logistic=entity.get_logistic_point()
                    logistic=logistic[1]
                    for _,itemqual in pairs(logistic.targeted_items_deliver) do
                        if itemqual.name==item.name and itemqual.quality==item.quality then
                            if cargo_pod.cargo_pod_destination.station==entity then
                                delivered_quantity=itemqual.count-item.count
                            else
                                delivered_quantity=itemqual.count
                            end
                            break
                        end
                    end
                    local entity_inventory = entity.get_inventory(defines.inventory.cargo_landing_pad_main)
                    if entity_inventory then
                        local sections = entity.get_logistic_sections()
                        if sections then
                            sections = sections.sections
                            local requested=false
                            for _, section in pairs(sections) do
                                if section.active then
                                    local finded = string.find(section.group, "[virtual-signal=signal-no-entry]", 1, true)
                                    if not finded then
                                        local filters = section.filters
                                        for _, filter in pairs(filters) do
                                            if filter and next(filter) then
                                                if filter.value.name==item.name and filter.value.quality==item.quality then
                                                    local stock = entity_inventory.get_item_count({
                                                        name = filter.value.name,
                                                        quality = filter.value.quality
                                                    })
                                                    local total=filter.min-stock-delivered_quantity--((filter.min-stock-delivered_quantity)>0 and filter.min-stock-delivered_quantity) or 0
                                                    table.insert(possible_dest.with_request,{entity,total,delivered_quantity})
                                                    requested=true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if not requested then
                                table.insert(possible_dest.without,entity)                   
                            end
                        end
                    end
                end
            end
        end
    end

    --on selection "la meilleur"
    local final_dest=nil
    if #possible_dest.with_request==1 then
        final_dest=possible_dest.with_request[1][1]
    elseif #possible_dest.with_request>1 then
        table.sort(possible_dest.with_request,function (left,right)
            return left[2]>right[2]
        end)
        final_dest=possible_dest.with_request[1][1]
    end

    if not final_dest then
        if #possible_dest.without>0 then
            final_dest=possible_dest.without[math.random(#possible_dest.without)]
        end
    end
    if final_dest then
        cargo_pod.cargo_pod_destination = { type = defines.cargo_destination.station, station = final_dest }
        --game.print(cargo_pod.cargo_pod_destination.station.unit_number)
    end
end

local function on_cargo_pod_finished_ascending(e)
    local cargo_pod = e.cargo_pod
    if cargo_pod and cargo_pod.valid then
        local origin = cargo_pod.cargo_pod_origin
        local destination = cargo_pod.cargo_pod_destination
        if origin and origin.valid and destination then
            if origin.name == "space-platform-hub" and destination.type == defines.cargo_destination.station then
                if destination.station and destination.station.valid then
                    local dest = destination.station
                    local surface_dest = dest.surface
                    if storage.ptflogtracker["S" .. origin.surface.index] then
                        --on envoi vers les requester du network
                        local network = storage.ptflogtracker["S" .. origin.surface.index]
                        redirection(cargo_pod, surface_dest, network)
                    else
                        --on envoi vers les requester standard ou du reseau NONE
                        redirection(cargo_pod, surface_dest, "NONE")
                    end
                end
            end
        end
    end
end

local function on_space_platform_changed_state(e)
    local platform = e.platform
    if platform and platform.valid then
        if platform.surface then
            if storage.ptflogtracker["S" .. platform.surface.index] and storage.ptflogtracker["S" .. platform.surface.index] ~= "NONE" then
                if platform.state == defines.space_platform_state.waiting_at_station then
                    local schedule = platform.schedule
                    if schedule then
                        if #schedule.records == 1 then
                            network_class.set_platform_unloading(platform, schedule.records[1].station)
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
