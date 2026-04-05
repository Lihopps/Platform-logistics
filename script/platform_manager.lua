local util = require("script.util")
local reservation_manager = require("script.reservation_manager")
local routing = require("script.routing")


local function is_empty(entity)
    local drop_slot=entity.get_inventory(defines.inventory.hub_trash)
    if not drop_slot then return true end
    return drop_slot.is_empty()
end

local manager = {}

function manager.update_platforms()
    storage.idle_platforms = {}

    for id, platform in pairs(storage.platforms) do
        local entity = platform.entity
        if not entity.valid then
            storage.platforms[id] = nil
            goto continue
        end
        if entity.surface.platform.scheduled_for_deletion>0 then
            manager.platform_out_of_network(platform)
            storage.platforms[id] = nil
            goto continue
        end

        --platform.location = entity.surface.name
        local schedule = platform.entity.surface.platform.get_schedule().get_records()
       
        if not next(schedule) and is_empty(entity) then
            platform.mission = {}
            platform.state = "IDLE"
        else
            platform.state = "TRAVELING"
        end

        if platform.state == "IDLE" then
            storage.idle_platforms[#storage.idle_platforms + 1] = platform
        end

        ::continue::
    end
end

---find the "best" platform for the delivery between prov_loc and req_loc
---@param prov_loc LuaSurface provider surface
---@param req_loc LuaSurface requester surface
---@param network string
---@return table best platform custom table storage.platforms
function manager.find_best_platform(prov_loc, req_loc, req_node)
    for _, platform in pairs(storage.platforms) do
        if platform.network == req_node.network and util.has_common_bits_from_string_32(platform.sub_network, req_node.sub_network) then
            --si dans la mission il y a la prov_loc et la req loc avec prov_loc<req_loc on return
            if next(platform.mission) and #platform.entity.surface.platform.get_schedule().get_records()>1 then
                local p_loc = nil
                local r_loc = nil
                for index, etape in pairs(platform.mission) do
                    local surface_number = next(etape)
                    if surface_number == prov_loc.index and not p_loc then
                        p_loc = index
                    end
                    if surface_number == req_loc.index then
                        r_loc = index
                    end
                    if p_loc and r_loc then
                        if p_loc < r_loc then
                            return { platform, p_loc, r_loc }
                        end
                    end
                end
            end
        end
    end

    local idle_platforms = { { nil, math.huge } }
    for index, platform in ipairs(storage.idle_platforms) do
        if platform.state=="IDLE" and platform.network == req_node.network and util.has_common_bits_from_string_32(platform.sub_network, req_node.sub_network) then
            --if platform.network == network then
            --by distance au provider
            local plat_loc = platform.entity.surface.platform.space_location
            if not plat_loc then goto continue end
            plat_loc=plat_loc.name
            local distance = routing.get_distance_from_path(routing.a_star(plat_loc, prov_loc.planet.name))
            table.insert(idle_platforms, { index, distance })
        end
        ::continue::
    end
    table.sort(idle_platforms, function(a, b) return a[2] < b[2] end)

    --pick first IDLE platform
    return { storage.idle_platforms[idle_platforms[1][1]] }
end

---@param platform platform  platform to update
---@param new boolean is a new schedule ?
function manager.update_platform_schedule(platform, new)
    local spaceplatform = platform.entity.surface.platform
    if not spaceplatform then return end
    local schedule = spaceplatform.get_schedule()
    local section_name = "LPN : Platform n°: " .. spaceplatform.surface.index
    local section_index = util.get_logistic_section_by_name(spaceplatform.hub, section_name)
    local new_schedule={ current=1,records={}}
    local interrupts=schedule.get_interrupts()
    local new_filters = {}
    if new then
        --on supprime tous les schedules
        --schedule.clear_records()
        --on clear la section
        spaceplatform.hub.get_logistic_sections().get_section(section_index).filters = {}
    else
        new_filters=util.filter_to_dic(spaceplatform.hub.get_logistic_sections().get_section(section_index).filters)
    end
    
    for _, surface_data in pairs(platform.mission) do
        local record = {
            station = game.surfaces[next(surface_data)].planet.name,
            temporary = true,
            allows_unloading = false,
            wait_conditions = {}
        }
        if settings.global["LPN-enable-circuit-condition"].value then
            table.insert(record.wait_conditions, {
                type = "circuit",
                compare_type = "and",
                condition = {
                    comparator = ">=",
                    first_signal = {
                        type = "virtual",
                        name = "signal-green"
                    },
                    constant = 1
                }
            })
        end
        for _, station_data in pairs(surface_data[next(surface_data)]) do
            if station_data.type == "provider" then
                table.insert(record.wait_conditions,
                    {
                        type = "all_requests_satisfied"
                    })
                for itemqal, amount in pairs(station_data.item) do
                    local name,quality = table.unpack(util.name_and_qual(itemqal))
                    new_filters[itemqal]={
                        value = {
                            type = "item",
                            name = name,
                            quality = quality
                        },
                        min = amount,
                        import_from = station_data.station.location.planet.name
                    }
                end
            elseif station_data.type == "requester" then
                table.insert(record.wait_conditions,
                    {
                        type = "inactivity",
                        ticks = 60 * settings.global["LPN-default-inactivity"].value --60 * 15 --60*(2*60)
                    })
                table.insert(record.wait_conditions,
                    {
                        type = "all_requests_satisfied"
                    })
                
            elseif station_data.type == "none" then
                table.insert(record.wait_conditions,
                    {
                        type = "inactivity",
                        ticks = 60 * settings.global["LPN-default-inactivity"].value --60 * 15 --60*(2*60)
                    })
                
            end
        end
        table.insert(new_schedule.records,record)
        --schedule.add_record(record)
    end
    spaceplatform.schedule=new_schedule
    spaceplatform.get_schedule().set_interrupts(interrupts)
    spaceplatform.hub.get_logistic_sections().get_section(section_index).filters = util.dic_to_filter(new_filters)
    --spaceplatform.paused=true
    --spaceplatform.paused=false
end

function manager.reel_item_amount(platform, request)
    local capacity = platform.entity.get_inventory(defines.inventory.hub_main).count_empty_stacks(false, false)
    local stack_size = prototypes.item[util.name_and_qual(request.item)[1]].stack_size
    local amount = math.min(capacity * stack_size, request.amount)
    amount = util.amount_rocket_rounded(request.item, amount)
    return amount
end

function manager.platform_out_of_network(platform)
    if platform.mission then
        for _, surface_data in pairs(platform.mission) do
            for _, station_data in pairs(surface_data[next(surface_data)]) do
                if station_data.type == "provider" then
                    for itemqal,amount in pairs(station_data.item) do
                        reservation_manager.release_supply(station_data,itemqal,amount)
                    end
                elseif station_data.type == "requester" then
                    for itemqal,amount in pairs(station_data.item) do
                        reservation_manager.release_request_supply(station_data,itemqal,amount)
                    end
                elseif station_data.type == "none" then
                    
                end
            end
        end
        platform.entity.surface.platform.get_schedule().clear_records()
        platform.mission={}
        platform.mission_index=-1
    end
end    

local function on_space_platform_changed_state(e)
    local current_state = e.platform.state
    local old_state = e.old_state
    local platform = e.platform
    if not platform.valid then return end
    if not storage.platforms[platform.hub.unit_number] then return end

 
    if current_state==defines.space_platform_state.no_schedule and old_state == defines.space_platform_state.waiting_at_station and #storage.platforms[platform.hub.unit_number].mission>1 then
        return
    end

       --avant attendais a une station
    -- donc a fait tout ce quelle devait faire a la station (requete et provide)
    if current_state==defines.space_platform_state.on_the_path then--old_state == defines.space_platform_state.waiting_at_station then
        local mission = storage.platforms[platform.hub.unit_number].mission
        if not mission  or not next(mission) then return end

        -- local mission_data = mission[storage.platforms[platform.hub.unit_number].mission_index]
        -- for id, stations in pairs(mission_data) do
        --     --release tout les provider
        --     for _, station_data in pairs(stations) do
        --         if station_data.type == "provider" then
        --             for item, amount in pairs(station_data.item) do
        --                 reservation_manager.release_supply(station_data, item, amount)
        --             end
        --         end
        --         --release toutes les supply
        --         if station_data.type == "requester" then
        --             --pas geré ici
        --         end
        --     end
        -- end
        storage.platforms[platform.hub.unit_number].mission[storage.platforms[platform.hub.unit_number].mission_index] = nil
        storage.platforms[platform.hub.unit_number].mission_index = storage.platforms[platform.hub.unit_number]
            .mission_index + 1
    elseif current_state == defines.space_platform_state.waiting_at_station then
        -- on arrive a une station
        local space_location = platform.space_location
        if not space_location then return end

        local schedule=platform.get_schedule()
        if schedule then
            local record=schedule.get_record({schedule_index=schedule.current})
            if record then
                if record.created_by_interrupt then
                    goto continue
                end
            end
        end

        space_location = game.planets[space_location.name]
        local mission = storage.platforms[platform.hub.unit_number].mission
        if not mission or not next(mission) then return end
        local mission_index=storage.platforms[platform.hub.unit_number].mission_index
        if #schedule.get_records()==1 then 
            for i,_ in ipairs(mission) do
                mission_index=i
            end
           
        end
        local mission_data = mission[mission_index]
        for id, stations in pairs(mission_data) do
            --force la vidange
            for _, station_data in pairs(stations) do
                if station_data.type == "requester" then
                    --il faut changer la planet et faire le total du filter - la requete rocket rounded mis sur le min/max ddu filter
                    for _, section in pairs(platform.hub.get_logistic_sections().sections) do
                        if section.group == "LPN : Platform n°: " .. platform.hub.surface.index then
                            local filters = {}
                            for _, filter in pairs(section.filters) do
                                if station_data.item[filter.value.name .. "_" .. filter.value.quality] then
                                    local new_filter = {}
                                    local final_amount = math.max(0,
                                        filter.min -
                                        util.amount_rocket_rounded(filter.value.name .. "_" .. filter.value.quality,
                                            station_data.item[filter.value.name .. "_" .. filter.value.quality]))
                                    
                                    if #schedule.get_records()==1 then 
                                        final_amount=0 
                                    end
                                    new_filter.min = final_amount
                                    new_filter.max = final_amount
                                    new_filter.import_from = space_location.name
                                    new_filter.value = filter.value
                                    table.insert(filters, new_filter)
                                else
                                    table.insert(filters, filter)
                                end
                            end
                            section.filters = filters
                            break
                        end
                    end
                end
            end
        end

        --si c'est la derniere station
        if #platform.get_schedule().get_records()<=1 and storage.platforms[platform.hub.unit_number].mission_index>1 then
            storage.platforms[platform.hub.unit_number].mission={}
            storage.platforms[platform.hub.unit_number].mission_index=-1
        end
        --storage.platforms[platform.hub.unit_number].mission[space_location.surface.index]=nil

        ::continue::
    end
end

local function on_entity_disapear(e)
    local entity = e.entity
    if not entity or not entity.valid then
        return
    end
    if entity.name == "space-platform-hub" then
        if storage.platforms[entity.unit_number] then
            manager.platform_out_of_network(storage.platforms[entity.unit_number])
        end
    end
end

manager.events = {
    [defines.events.on_space_platform_changed_state] = on_space_platform_changed_state,
    [defines.events.on_entity_died] = on_entity_disapear,
}

return manager
