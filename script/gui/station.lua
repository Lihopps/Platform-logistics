local reservation = require("script.reservation_manager")
local util = require("script.util")
local gui_util = require("script.gui.gui-util")
local gui = require("__flib__.gui")

local function on_button_slot_shipment_station_click(e)
    local parent=game.players[e.player_index].gui.screen["LPN-manager-gui"]
    local filter=parent.children[2].children[1].children[2]
    local item,qal = table.unpack(util.name_and_qual(e.element.tags.itemqal))
    filter.elem_value={
        type="item",
        name=item,
        quality=qal
    }
   
    parent.children[2].children[2].selected_tab_index=2
    remote.call("LPN_remote","update_tab",game.players[e.player_index])
end

local function on_camera_click(e)
    local id = e.element.tags.station_id
    local entity=game.get_entity_by_unit_number(id)
    --open on map
    if e.shift then
        game.players[e.player_index].gui.screen["LPN-manager-gui"].visible=false
        game.players[e.player_index].opened=nil
        game.players[e.player_index].centered_on=entity
        return
    end

    --open gui
    game.players[e.player_index].gui.screen["LPN-manager-gui"].visible=false
    game.players[e.player_index].opened=entity

end

local function update_ship_prov(entity)
    local ship = {}
    for itemqal, count in pairs(storage.reservations[entity.unit_number] or {}) do
        if count > 0 then
            local item, quality = table.unpack(util.name_and_qual(itemqal))
            table.insert(ship, {
                min = -count,
                type = "requester", --just to be red
                value = {
                    name = item,
                    quality = quality
                }
            })
        end
    end

    return ship
end

local function update_ship_req(entity)
    local ship = {}
    for itemqal, count in pairs(storage.request_reservations[entity.unit_number] or {}) do
        if count > 0 then
            local item, quality = table.unpack(util.name_and_qual(itemqal))
            table.insert(ship, {
                min = count,
                type = "provider", --just to be green
                value = {
                    name = item,
                    quality = quality
                }
            })
        end
    end

    return ship
end

local function update_prov(provider)
    local provreq = {}
    local controls = {}
    if not provider.valid then
        return { provreq, controls }
    end


    local input = provider.get_circuit_network(defines.wire_connector_id.combinator_input_red)       --input
    local parameter = provider.get_circuit_network(defines.wire_connector_id.combinator_input_green) --threshold
    parameter = util.parameter_from_signal(parameter)
    controls = util.filter_from_parameter(parameter)
    if input then
        if input.signals then
            for _, signal in pairs(input.signals) do
                if prototypes.item[signal.signal.name] then
                    if signal.count >= util.threshold(parameter, signal.signal.name .. "_" .. (signal.signal.quality or "normal")) then
                        provreq[signal.signal.name .. "_" .. (signal.signal.quality or "normal")] = {
                            min = signal.count,
                            type = "provider",
                            value = { name = signal.signal.name, quality = (signal.signal.quality or "normal") }
                        }
                    end
                end
            end
        end
    end
    return { provreq, controls }
end

local function update_req(entity)
    local provreq = {}
    local controls = {}
    if not entity.valid then
        return { provreq, controls }
    end

    local inventory = entity.get_inventory(defines.inventory.cargo_landing_pad_main)


    local parameter = entity.get_circuit_network(defines.wire_connector_id.circuit_green) --threshold
    parameter = util.parameter_from_signal(parameter)
    controls = util.filter_from_parameter(parameter)

    if not inventory then
        return { provreq, controls }
    end
    local sections = entity.get_logistic_sections()
    if sections then
        sections = sections.sections
        for _, section in pairs(sections) do
            if section.active then
                local finded = string.find(section.group, "[virtual-signal=signal-no-entry]", 1, true)
                if not finded then
                    local filters = section.filters
                    for _, filter in pairs(filters) do
                        if filter and next(filter) then
                            local current = inventory.get_item_count({
                                name = filter.value.name,
                                quality = filter.value.quality
                            })
                            local reserved = reservation.get_request_reserved(entity.unit_number,
                                filter.value.name .. "_" .. filter.value.quality)
                            local needed = filter.min - current - reserved
                            local threshold = util.threshold(parameter, filter.value.name .. "_" .. filter.value.quality)


                            if current - filter.min < threshold then
                                provreq[filter.value.name .. "_" .. (filter.value.quality or "normal")] = {
                                    min = -(filter.min - current),
                                    type = "requester",
                                    value = { name = filter.value.name, quality = filter.value.quality }
                                }
                            elseif current - filter.min > threshold then
                                provreq[filter.value.name .. "_" .. (filter.value.quality or "normal")] = {
                                    min = -(filter.min - current),
                                    type = "provider",
                                    value = { name = filter.value.name, quality = filter.value.quality }
                                }
                            end
                        end
                    end
                end
            end
        end
    end


    return { provreq, controls }
end


local station_gui = {}

function station_gui.update_platform_tab(player, item_filter, network, sub_network, selected_tab_index,trigger)
    local tab_content = player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index]
        .content
    local toolbar = tab_content.children[1].children[1]
    local scroll = tab_content.children[1].children[2]
    scroll.clear()
    local idx = 0
    local plat_unit = {}
    for key, _ in pairs(storage.supply_nodes) do
        table.insert(plat_unit, key)
    end
    for key, _ in pairs(storage.request_nodes) do
        table.insert(plat_unit, key)
    end
    local trigger_update = trigger or (toolbar.tags.trigger or "id")
    toolbar.tags = { trigger = trigger_update }
    table.sort(plat_unit, function(a, b)
        local by_number = toolbar.children[1].state
        local by_network = toolbar.children[2].state
        local plat_a = storage.request_nodes[a] or storage.supply_nodes[a]
        local plat_b = storage.request_nodes[b] or storage.supply_nodes[b]
        if trigger_update == "id" then
            if by_number then
                return a < b
            else
                return a > b
            end
        elseif trigger_update == "network" then
            if by_network then
                return plat_a.network..plat_a.sub_network < plat_b.network..plat_b.sub_network
            else
                return plat_a.network..plat_a.sub_network > plat_b.network..plat_b.sub_network
            end
        end
    end)
    for _, id in pairs(plat_unit) do
        local station = storage.supply_nodes[id] or storage.request_nodes[id]
        local type = "provider"
        local zoom = 0.75
        local labeltype = { "gui.labeltype_P" }
        if station.entity.name == "ptflog-requester" then
            type = "requester"
            zoom = 0.5
            labeltype = { "gui.labeltype_R" }
        end




        if not network or (network == station.network and util.has_common_bits_from_string_32(sub_network, station.sub_network)) then
            local color = idx % 2 == 0 and "light" or "dark"
            local provreq = {}
            local shpiments = {}
            local controls = {}
            if type == "requester" then
                provreq, controls = table.unpack(update_req(station.entity))
                shpiments = update_ship_req(station.entity)
            elseif type == "provider" then
                provreq, controls = table.unpack(update_prov(station.entity))
                shpiments = update_ship_prov(station.entity)
            end

            if not item_filter or provreq[item_filter] then
                local flow = {
                    type = "frame",
                    direction = "horizontal",
                    style = "LPN_table_row_frame_" .. color,
                    style_mods = { height = 250, width = 1165, vertical_align = "center" },
                    children = {
                        {
                            type = "camera",
                            name = "station_minimap",
                            style = "LPN_station_camera",
                            position = station.entity.position,
                            surface_index = station.entity.surface.index,
                            zoom = zoom,
                            style_mods = { vertical_align = "center", horizontal_align = "center" },
                            { type = "label", style = "LPN_station_camera_label",      caption = id },
                            { type = "label", style = "LPN_station_camera_label_type", caption = labeltype },
                            {
                                type = "button",
                                style = "LPN_station_camera_button",
                                tooltip = { "gui.open-hub-gui" },
                                tags = { station_id = id },
                                handler = { [defines.events.on_gui_click] = on_camera_click },
                            },
                        },
                        {
                            type = "flow",
                            direction = "horizontal",
                            style_mods = { width = 100 },
                            {
                                type = "sprite-button",
                                style = "flib_slot_button_default",
                                enabled = true,
                                ignored_by_interaction = true,
                                sprite = gui_util.sprite_from_signal(station.network)[1],
                                quality = gui_util.sprite_from_signal(station.network)[2],
                                number = station.sub_network,
                            }
                        },
                        gui_util.make_slot_table(6, nil, 225),
                        gui_util.make_slot_table(6, nil, 225),
                        gui_util.make_slot_table(6, nil, 225)
                    }
                }
                gui.add(scroll, flow)
                idx = idx + 1
                --player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content.children[1].children[2].children[idx].children[1].entity =station.entity
                gui_util.add_filter_to_table(provreq, nil, nil,
                    player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content
                    .children
                    [1].children[2].children[idx].children[3])
                gui_util.add_filter_to_table(shpiments, nil, nil,
                    player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content
                    .children
                    [1].children[2].children[idx].children[4],on_button_slot_shipment_station_click)
                gui_util.add_filter_to_table(controls, nil, nil,
                    player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content
                    .children
                    [1].children[2].children[idx].children[5], nil, true)
            end
        end
    end
end

gui.add_handlers({
    on_camera_click=on_camera_click,
    on_button_slot_shipment_station_click=on_button_slot_shipment_station_click
})


return station_gui
