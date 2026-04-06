local LPN_GUI_MANAGER = require("script.gui.LPN_gui_manager")
local dispatcher = require("script.dispatcher")
local reservation_manager = require("script.reservation_manager")
local util = require("script.util")
local debug = require("script.debug")
local migration_gui = require("migration.migration-gui")

local v2_0_0 = {}
local alpha = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
    "V", "W", "X", "Y", "Z" }


local function update_delivery(channel_name, platform_unit_number, platform)
    --pour chaque platform on recreer la request puis on la réaffect via dispatcher

    local mission = {}
    local records = platform.get_schedule().get_records()
    local hub = game.get_entity_by_unit_number(platform_unit_number)
    local provitems = {}

    local section_name = "LPN : Platform n°: " .. hub.surface.index
    local section_index = util.get_logistic_section_by_name(hub, section_name)
    local filters = hub.get_logistic_sections().get_section(section_index).filters
    for _, filter in pairs(filters) do
        if next(filter) then
            if filter.min>0 then
                local surface_index = game.planets[filter.import_from.name].surface.index
                if not provitems[surface_index] then provitems[surface_index] = {} end
                provitems[surface_index][filter.value.name .. "_" .. (filter.value.quality or "normal")] = filter.min
            end
        end
    end

    local items={}
    for i, record in ipairs(records) do
        local surface = game.planets[record.station].surface
        local type = { none = true }
        for _, wait in pairs(record.wait_conditions) do
            if wait.type == "all_requests_satisfied" then
                local providers = surface.find_entities_filtered { name = "ptflog-provider" }
                if next(providers) then
                    for _, provider in pairs(providers) do
                        local prov = storage.old_storage.ptflogchannel[channel_name].building["ptflog-provider"]
                            [provider.unit_number]
                        if prov then
                            for itemqal, data in pairs(prov["reserved"]) do
                                if provitems[provider.surface.index][itemqal] then
                                    if not items[itemqal] then items[itemqal]={} end
                                    items[itemqal]["provider"]={node=storage.supply_nodes[provider.unit_number]}
                                    
                                end
                            end
                        end
                    end
                end
                goto continue_req
            end
        end
        ::continue_req::

        local req_item = {}
        local requesters = surface.find_entities_filtered { name = "ptflog-requester" }
        if next(requesters) then
            for _, requester in pairs(requesters) do
                local req = storage.old_storage.ptflogchannel[channel_name].building["ptflog-requester"]
                    [requester.unit_number]
                if req then
                    for itemqal, data in pairs(req["incomming"]) do
                        for id, _ in pairs(data.platform) do
                            if id == platform_unit_number then
                                if not items[itemqal] then items[itemqal]={request={}} end
                                if not items[itemqal].request then items[itemqal]["request"]={} end
                                items[itemqal]["request"].node=storage.request_nodes[requester.unit_number]
                                items[itemqal]["request"].item=itemqal
                                items[itemqal]["request"].priority=0
                                items[itemqal]["request"].destination=surface
                                items[itemqal]["request"].amount=(items[itemqal]["request"].amount or 0)+data.quantity
                                goto continue
                            end
                        end
                    end
                end
            end
        end
        ::continue::
    end

    local first=true
    for itemqal, item_data in pairs(items) do
        if item_data["request"] then
            if first then
                dispatcher.create_delivery(storage.platforms[platform.hub.unit_number],item_data["provider"],item_data["request"])
                first=false
            else
                local p_loc=item_data["provider"].node.location.index
                local r_loc=item_data["request"].destination.index
                dispatcher.update_delivery({storage.platforms[platform.hub.unit_number],p_loc,r_loc},item_data["provider"],item_data["request"])
            end
        else
            game.print("not requested")
        end
    end
end



-- all change for 2.0.0
function v2_0_0.change()
    helpers.write_file("previous_storage_2_0_0.json", helpers.table_to_json(storage))

    local old_storage = storage
    storage = {}
    storage.old_storage = old_storage

    if not storage.platforms then storage.platforms = {} end
    if not storage.idle_platforms then storage.idle_platforms = {} end

    if not storage.requests then storage.requests = {} end
    if not storage.request_nodes then storage.request_nodes = {} end

    if not storage.supplies then storage.supplies = {} end
    if not storage.supply_nodes then storage.supply_nodes = {} end

    if not storage.reservations then storage.reservations = {} end
    if not storage.request_reservations then storage.request_reservations = {} end

    local channel_mapping = { DEFAULT = { network = "signal-A", sub_network = "1" } }
    local channel_index = 2
    for channel_name, channel_data in pairs(storage.old_storage.ptflogchannel) do
        if not channel_mapping[channel_name] then
            channel_mapping[channel_name] = {
                network = "signal-" .. alpha[channel_index % 26],
                sub_network =
                    channel_index - (channel_index % 26) + 1
            }
            channel_index=channel_index+1
        end

        --request_nodes
        for unit_number, incomming in pairs(storage.old_storage.ptflogchannel[channel_name].building["ptflog-requester"]) do
            local entity = game.get_entity_by_unit_number(unit_number)
            storage.request_nodes[unit_number] = {
                id = unit_number,
                entity = entity,
                location = entity.surface,
                network = channel_mapping[channel_name].network,
                sub_network = channel_mapping[channel_name].sub_network,
            }

            --request_reservation
            -- for _, incom in pairs(incomming) do
            --     for itemqal, data in pairs(incom) do
            --         reservation_manager.reserve_request(unit_number, data.quantity, itemqal)
            --     end
            -- end
        end

        --supply_nodes
        for unit_number, reserved in pairs(storage.old_storage.ptflogchannel[channel_name].building["ptflog-provider"]) do
            local entity = game.get_entity_by_unit_number(unit_number)
            storage.supply_nodes[unit_number] = {
                id = unit_number,
                entity = entity,
                location = entity.surface,
                network = channel_mapping[channel_name].network,
                sub_network = channel_mapping[channel_name].sub_network,
            }

            --reservation
            -- for _, reser in pairs(reserved) do
            --     for itemqal, data in pairs(reser) do
            --         reservation_manager.reserve_supply(unit_number, data.quantity, itemqal)
            --     end
            -- end
        end

        --platform
        for _, platform in pairs(storage.old_storage.ptflogchannel[channel_name].platform) do
            storage.platforms[platform.hub.unit_number] = {
                entity = platform.hub,
                state = "IDLE",
                network = channel_mapping[channel_name].network,
                sub_network = channel_mapping[channel_name].sub_network,
                mission = {},
                mission_index = -1
            }
            update_delivery(channel_name, platform.hub.unit_number, platform)
        end
    end

    helpers.write_file("storage_2_0_0_AU.json", helpers.table_to_json(storage))

    settings.global["LPN-enable-dispatcher"] = { value = false }
    
    debug.control_system(false)

    --dispatcher.update() -- idle_platforms, request, supplies
    --dispatcher.dispatch()
    LPN_GUI_MANAGER.rebuild()
    game.print({ "alert.update-2-0-0_1" })
    game.print({ "alert.update-2-0-0_2" })
    --game.tick_paused = true
    --on coupe le dispatcher ?

    for _,player in pairs(game.players) do
        migration_gui.create_gui(player,"2_0_0")
    end
end

return v2_0_0
