local LPN_gui_manager = require("script.LPN_gui_manager")
local util = require("script.util")

---@param platform LuaSpacePlatform
---@param item LuaItemPrototype
local function item_in_filters(item, platform)
    if not platform or not platform.valid then return end
    local hub = platform.hub
    if hub and hub.valid then
        local sections = hub.get_logistic_sections()
        if sections then
            local section_name = "LPN : Platform n°: " .. platform.surface.index
            for _, section in ipairs(sections.sections) do
                if section.group == section_name then
                    for _, filter in ipairs(section.filters) do
                        if filter.value.name == item then
                            return true
                        end
                    end
                    return false
                end
            end
        end
    end
    return false
end

---@param platform LuaSpacePlatform
local function clear_platform_request(platform)
    if not platform or not platform.valid then return end
    local hub = platform.hub
    if hub and hub.valid then
        local sections = hub.get_logistic_sections()
        if sections then
            local section_name = "LPN : Platform n°: " .. platform.surface.index
            for _, section in ipairs(sections.sections) do
                if section.group == section_name then
                    section.filters = {}
                    return
                end
            end
        end
    end
end

---@param platform LuaSpacePlatform
---@param planet_name string
local function set_platform_unloading(platform, planet_name)
    if not platform or not platform.valid then return false end
    local hub = platform.hub
    if hub and hub.valid then
        local sections = hub.get_logistic_sections()
        if sections then
            local section_name = "LPN : Platform n°: " .. platform.surface.index
            for _, section in ipairs(sections.sections) do
                if section.group == section_name then
                    local new_filters = {}
                    local schedule = platform.get_schedule()
                    local index = 3
                    schedule.change_wait_condition({ schedule_index = 1 }, 1, {
                        type = "inactivity",
                        ticks = 60 * 5 --60 * 15 --60*(2*60)
                    })
                    schedule.change_wait_condition({ schedule_index = 1 }, 2, {
                        type = "circuit",
                        compare_type = "and",
                        condition = {
                            comparator = "=",
                            first_signal = {
                                type = "virtual",
                                name = "signal-green"
                            },
                            constant = 1
                        }
                    })

                    for _, filter in ipairs(section.filters) do
                        local new_filter = filter
                        new_filter.min = 0
                        new_filter.max = 0
                        new_filter.import_from = planet_name
                        table.insert(new_filters, new_filter)
                        game.print(new_filter.value.name .. "_" .. new_filter.value.quality)
                        if not schedule.get_wait_condition({schedule_index=1},index) then
                            schedule.add_wait_condition({ schedule_index = 1 }, index, "item_count")
                        end
                        schedule.change_wait_condition({ schedule_index = 1 }, index, {
                            type = "item_count",
                            compare_type = "and",
                            condition = {
                                comparator = "=",
                                first_signal = {
                                    type = "item",
                                    name = new_filter.value.name,
                                    quality = new_filter.value.quality
                                },
                                constant = 0
                            }
                        })
                        index = index + 1
                        game.print(index)
                    end
                    section.filters = new_filters
                    return
                end
            end
        end
    end
end


---@param platform LuaSpacePlatform
---@param planet LuaPlanet
---@param item string
---@param quality string
---@param real_provided number
local function add_platform_request(platform, planet, item, quality, real_provided, secur)
    if not secur then secur = 1 end
    if secur >= 10 then return false end

    if not platform or not platform.valid then return false end
    local hub = platform.hub
    if not planet then planet = { name = nil } end
    if hub and hub.valid then
        local sections = hub.get_logistic_sections()
        local section_name = "LPN : Platform n°: " .. platform.surface.index
        if sections then
            for _, section in ipairs(sections.sections) do
                if section.group == section_name then
                    for i = 1, section.filters_count do
                        local slot = section.get_slot(i)
                        if slot.value.name == item and slot.value.quality == quality then
                            section.set_slot(i, {
                                value = { type = "item", name = item, quality = quality },
                                min = slot.min + real_provided,
                                import_from = planet.name
                            })
                            return true
                        end
                    end
                    section.set_slot(section.filters_count + 1, {
                        value = { type = "item", name = item, quality = quality },
                        min = real_provided,
                        import_from = planet.name
                    })
                    return true
                end
            end
            sections.add_section(section_name)
            return add_platform_request(platform, planet, item, quality, real_provided, secur + 1)
        end
    end
    return false
end

---@param platform LuaSpacePlatform
---@param loading LuaPlanet
---@param unloading LuaPlanet
local function set_schedule(platform, loading, unloading, busy)
    if busy then return true end
    if not unloading then return false end
    if not loading and not unloading then return false end
    clear_platform_request(platform)
    local schedule = platform.get_schedule()
    if loading then
        local loading_record = {
            station = loading.name,
            temporary = true,
            allows_unloading = true,
            wait_conditions = {
                {
                    type = "all_requests_satisfied"
                },
                {
                    type = "circuit",
                    compare_type = "and",
                    condition = {
                        comparator = "=",
                        first_signal = {
                            type = "virtual",
                            name = "signal-green"
                        },
                        constant = 1
                    }
                }
            }
        }
        schedule.add_record(loading_record)
    end
    local unloading_record = {
        station = unloading.name,
        temporary = true,
        allows_unloading = true,
        wait_conditions = {
            {
                type = "inactivity",
                ticks = 60 * 5 --60 * 15 --60*(2*60)
            },
            {
                type = "circuit",
                compare_type = "and",
                condition = {
                    comparator = "=",
                    first_signal = {
                        type = "virtual",
                        name = "signal-green"
                    },
                    constant = 1
                }
            }
        }
    }
    schedule.add_record(unloading_record)
    return true
end


local function get_rocket_quantity(item)
    local item_weight = prototypes.item[item].weight
    return 1000000 / item_weight
end

local function rocket_rounded(item, number)
    if number <= 0 then
        return 0
    else
        local a = math.ceil(number / get_rocket_quantity(item))
        return a * get_rocket_quantity(item)
    end
end

local network_class = {}
function network_class.update_incomming_platform(network, entity_number, item, quality, platform, is_added)
    if not network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].platform then
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].platform = {}
    end
    if platform then
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].platform[platform] =
            is_added
    end
end

function network_class.update_incomming(network, entity_number, item, quality, quantity, request, stock)
    local default_rate = settings.global["LPN-rate"].value
    if not network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality] then
        --do nothing
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality] = {
            request = (request or 0),
            stock = (stock or 0),
            rate = (default_rate),
            quantity = quantity,
            platform = {},
            tick = game.tick
        }
    else
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].quantity = (network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].quantity or 0) +
            quantity
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].request = (request or 0)
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].stock = (stock or 0)
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].tick = game.tick
    end
    if network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].quantity < 0 then
        network.building["ptflog-requester"][entity_number].incomming[item .. "_" .. quality].quantity = 0
    end
end

function network_class.update_reserved(network, entity_number, item, quality, quantity)
    if not network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality] then
        network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality] = {
            quantity = quantity,
            tick = game.tick
        }
    else
        network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality].quantity = (network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality].quantity or 0) +
            quantity
        network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality].tick = game.tick
    end
    if network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality].quantity < 0 then
        network.building["ptflog-provider"][entity_number].reserved[item .. "_" .. quality].quantity = 0
    end
end

function network_class.add_request(network, entity_number, item, quantity, quality, limit)
    if limit > 10 then return end
    if quantity <= 0 then return end


    local entity = game.get_entity_by_unit_number(entity_number)
    if not entity or not entity.valid then return end
    local platforms = network.platform

    local platforms_registered = {
        {}, {}, {}, {}, {}, {}, {}, {}
    }

    -- on cherche un provider qui a le stock
    local available_providers = {}
    for provider_number, state in pairs(network.building["ptflog-provider"]) do
        local provider = game.get_entity_by_unit_number(provider_number)
        if not provider or not provider.valid then return end
        local circuit_provider_red = provider.get_circuit_network(defines.wire_connector_id.combinator_input_red)
        local circuit_provider_green = provider.get_circuit_network(defines.wire_connector_id.combinator_input_green)
        local provider_stock = 0
        if circuit_provider_red then
            provider_stock = provider_stock + circuit_provider_red.get_signal({
                type = "item",
                name = item,
                quality =
                    quality
            })
        end
        if circuit_provider_green then
            provider_stock = provider_stock + circuit_provider_green.get_signal({
                type = "item",
                name = item,
                quality =
                    quality
            })
        end
        local reserved = network.building["ptflog-provider"][provider_number].reserved[item .. "_" .. quality]
        if not reserved then reserved = { ["quantity"] = 0 } end
        provider_stock = provider_stock - reserved.quantity
        if provider_stock >= rocket_rounded(item, 1) then
            table.insert(available_providers, {
                provider_number = provider_number,
                stock = provider_stock,
                distance = 1,
                surface = provider.surface
            })
        end
    end

    if not next(available_providers) then
        util.not_provided_item(item, quality, entity)
        return
    end
    local provider = available_providers[1]
    if not provider then return end
    --[[
        platforms :
            1. la platform qui a en stock et qui est en orbit
            2. la platform qui a en stock et qui vient sur l'orbit
            3. la platform qui a en stock
            4. la platform qui a en stock et qui va ailleurs puis vient sur l'orbit
            5. la platform qui va deja chercher un autre truc sur le meme provider et qui vient sur l'orbit
            6. la platform qui fait rien
    ]]

    for index, platform in pairs(platforms) do
        local en_stock = 0
        local on_orbit = 0
        local go_to_orbit = 0
        local go_another_provider = 0
        local go_to_the_same_provider = 0
        local as_schedule = false

        local allow_goto = true
        if platform.hub.valid then
            if storage.ptflogfilter[platform.hub.unit_number] then
                if storage.ptflogfilter[platform.hub.unit_number].state == "left" then
                    if storage.ptflogfilter[platform.hub.unit_number].filter[entity.surface.name] or storage.ptflogfilter[platform.hub.unit_number].filter[provider.surface.name] then
                        allow_goto = true
                    else
                        allow_goto = false
                    end
                else
                    if storage.ptflogfilter[platform.hub.unit_number].filter[entity.surface.name] or storage.ptflogfilter[platform.hub.unit_number].filter[provider.surface.name] then
                        allow_goto = false
                    else
                        allow_goto = true
                    end
                end
            end
        end

        if allow_goto then
            --en_stock
            if platform.hub.valid then
                local hub = platform.hub
                if hub and hub.valid then
                    local hub_inventory = hub.get_inventory(defines.inventory.hub_main)
                    if hub_inventory then
                        local platform_quantity = hub_inventory.get_item_count({ name = item, quality = quality })

                        --on enleve la qty qu'il y a dans les request
                        local sections = hub.get_logistic_sections()
                        local total_request = 0
                        if sections then
                            for _, section in pairs(sections.sections) do
                                for _, filter in pairs(section.filters) do
                                    if filter.value then
                                        if filter.value.name == item and filter.value.quality == quality then
                                            total_request = total_request + (filter.min or 0)
                                        end
                                    end
                                end
                            end
                        end
                        platform_quantity = platform_quantity - total_request

                        if platform_quantity > 0 then
                            en_stock = 1
                        end
                    end
                end
            end

            --on_orbit
            if platform.space_location then
                if platform.space_location.name == entity.surface.name then
                    on_orbit = 1
                end
            end

            --go_to_ailleurs  go_to_orbit  go_to_the_same_provider
            local schedule = platform.schedule
            if schedule then
                if #schedule.records >= 1 then
                    as_schedule = true
                end
                if #schedule.records == 1 then
                    if schedule.records[1].station == entity.surface.name then
                        go_to_orbit = 1
                    end
                elseif #schedule.records == 2 then
                    if schedule.records[2].station == entity.surface.name then
                        go_to_orbit = 1
                    end
                    if schedule.records[1].station == provider.surface.name then
                        go_to_the_same_provider = 1
                    else
                        go_another_provider = 1
                    end
                end
            end


            local id = table.concat({ en_stock, on_orbit, go_to_orbit, go_another_provider, go_to_the_same_provider }, "")
            --mis dans le bon tableau (id 5 chiffre)
            if (id == "00000" or id == "01000") and not as_schedule then -- elle a rien mais dispo
                table.insert(platforms_registered[8], platform)
            elseif id == "00101" then                                    --update_request
                table.insert(platforms_registered[7], platform)
            elseif id == "10110" then                                    --va deja au bon endroit avec le stock mais passe par un mauvais provider
                table.insert(platforms_registered[6], platform)
            elseif id == "10101" then                                    --va deja au bon endroit avec le stock en passant par un bon prov update_request
                table.insert(platforms_registered[5], platform)
            elseif id == "10100" then                                    --va deja au bon endroit avec le stock
                table.insert(platforms_registered[4], platform)
            elseif id == "10000" and not as_schedule then                --schedule unloading
                table.insert(platforms_registered[3], platform)
            elseif id == "11000" then                                    --schedule unloading mais est deja sur place
                table.insert(platforms_registered[2], platform)
            elseif id == "11100" then                                    --est deja sur place avec le stock entrain d'attendre
                table.insert(platforms_registered[1], platform)
            else
                -- game.print("platform not registered: "..id.." : "..platform.hub.unit_number.." : "..item.." : "..entity.surface.name)
            end
            --game.print("passer par la")
        end
    end

    local let_free_slot = settings.global["LPN-free_slot"].value or 10
    local number_free_slot_item = (let_free_slot * prototypes.item[item].stack_size) or 0
    for i, plats in ipairs(platforms_registered) do
        for j = #plats, 1, -1 do
            if quantity <= 0 or provider.stock < rocket_rounded(item, 1) then return end

            if i == 1 then
                local already_count = false
                if item_in_filters(item, plats[j]) then
                    already_count = true
                end
                if not already_count then
                    local real_provided = plats[j].hub.get_inventory(defines.inventory.hub_main).get_item_count({ name =
                    item, quality = quality })
                    if add_platform_request(plats[j], nil, item, quality, 0) then
                        set_platform_unloading(plats[j], entity.surface.planet.name)
                        network_class.update_incomming(network, entity_number, item, quality, real_provided)
                        network_class.update_incomming_platform(network, entity_number, item, quality,
                            plats[j].hub.unit_number, true)
                        quantity = quantity - real_provided
                        table.remove(platforms_registered[i], j)
                        --LPN_gui_manager.update_manager__gen_gui()
                    end
                end
            elseif i == 2 or i == 3 then
                local real_provided = plats[j].hub.get_inventory(defines.inventory.hub_main).get_item_count({
                    name = item,
                    quality =
                        quality
                })

                if set_schedule(plats[j], nil, entity.surface.planet, false) and add_platform_request(plats[j], provider.surface.planet, item, quality, real_provided) then
                    network_class.update_incomming(network, entity_number, item, quality, real_provided)
                    network_class.update_incomming_platform(network, entity_number, item, quality,
                        plats[j].hub.unit_number, true)
                    quantity = quantity - real_provided
                    table.remove(platforms_registered[i], j)
                    --LPN_gui_manager.update_manager__gen_gui()
                end
            elseif i == 4 then
                local real_provided = plats[j].hub.get_inventory(defines.inventory.hub_main).get_item_count({
                    name = item,
                    quality =
                        quality
                })

                if add_platform_request(plats[j], provider.surface.planet, item, quality, real_provided) then
                    network_class.update_incomming(network, entity_number, item, quality, real_provided)
                    network_class.update_incomming_platform(network, entity_number, item, quality,
                        plats[j].hub.unit_number, true)
                    quantity = quantity - real_provided
                    table.remove(platforms_registered[i], j)
                    --LPN_gui_manager.update_manager__gen_gui()
                end
            elseif i == 5 or i == 7 then
                local real_provided = 0

                local ptf_stock = plats[j].hub.get_inventory(defines.inventory.hub_main).get_item_count({
                    name = item,
                    quality =
                        quality
                })
                real_provided = math.min(quantity - ptf_stock, rocket_rounded(item, provider.stock),
                    plats[j].hub.get_inventory(defines.inventory.hub_main).get_insertable_count({
                        name = item,
                        quality =
                            quality
                    }) - number_free_slot_item)
                real_provided = rocket_rounded(item, real_provided)

                if add_platform_request(plats[j], provider.surface.planet, item, quality, real_provided + ptf_stock) then
                    network_class.update_reserved(network, provider.provider_number, item, quality, real_provided)
                    provider.stock = provider.stock - real_provided

                    network_class.update_incomming(network, entity_number, item, quality, real_provided + ptf_stock)
                    network_class.update_incomming_platform(network, entity_number, item, quality,
                        plats[j].hub.unit_number, true)
                    quantity = quantity - (real_provided + ptf_stock)
                    table.remove(platforms_registered[i], j)
                    --LPN_gui_manager.update_manager__gen_gui()
                end
            elseif i == 6 then
                local real_provided = plats[j].hub.get_inventory(defines.inventory.hub_main).get_item_count({
                    name = item,
                    quality =
                        quality
                })

                if add_platform_request(plats[j], nil, item, quality, real_provided) then
                    network_class.update_incomming(network, entity_number, item, quality, real_provided)
                    network_class.update_incomming_platform(network, entity_number, item, quality,
                        plats[j].hub.unit_number, true)
                    quantity = quantity - real_provided
                    table.remove(platforms_registered[i], j)
                    --LPN_gui_manager.update_manager__gen_gui()
                end
            elseif i == 8 then
                local real_provided = math.min(quantity, rocket_rounded(item, provider.stock),
                    plats[j].hub.get_inventory(defines.inventory.hub_main).get_insertable_count({
                        name = item,
                        quality =
                            quality
                    }) - number_free_slot_item)
                real_provided = rocket_rounded(item, real_provided)
                if set_schedule(plats[j], provider.surface.planet, entity.surface.planet, false) and add_platform_request(plats[j], provider.surface.planet, item, quality, real_provided) then
                    network_class.update_reserved(network, provider.provider_number, item, quality, real_provided)
                    provider.stock = provider.stock - real_provided

                    network_class.update_incomming(network, entity_number, item, quality, real_provided)
                    network_class.update_incomming_platform(network, entity_number, item, quality,
                        plats[j].hub.unit_number, true)
                    quantity = quantity - real_provided
                    table.remove(platforms_registered[i], j)
                    --LPN_gui_manager.update_manager__gen_gui()
                end
            end
        end
    end
    return
end

local function update_network(e, name, network)
    local default_rate = settings.global["LPN-rate"].value
    -- update request
    for number, state in pairs(network.building["ptflog-requester"]) do
        local entity = game.get_entity_by_unit_number(number)
        if entity and entity.valid then
            local entity_inventory = entity.get_inventory(defines.inventory.cargo_landing_pad_main)
            if entity_inventory then
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
                                        local stock = entity_inventory.get_item_count({
                                            name = filter.value.name,
                                            quality = filter
                                                .value.quality
                                        })
                                        network_class.update_incomming(network, number, filter.value.name,
                                            filter.value.quality,
                                            0,
                                            filter.min, stock)
                                        local incom = network.building["ptflog-requester"][number].incomming
                                            [filter.value.name .. "_" .. filter.value.quality]
                                        if stock + incom.quantity < (filter.min * (incom.rate or default_rate)) then
                                            network_class.add_request(network, number, filter.value.name,
                                                filter.min - (stock + incom.quantity), filter.value.quality, 0)
                                        end
                                    end
                                    --game.print(filter.value.name.." : "..filter.min)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    -- set orm schedule
end

local function update_networks(e)
    local time_clearer = settings.global["LPN-clearer"].value
    if e.tick % (60 * time_clearer) == 0 then
        for name, network in pairs(storage.ptflogchannel) do
            update_network(e, name, network)
            util.clear_network(name, network, false)
        end
    end
end

local function on_player_clicked_gps_tag(e)
    local player = game.players[e.player_index]
    if player and player.valid then
        local entity = game.surfaces[tonumber(e.surface) or 1].find_entity("ptflog-requester", e.position)
        if entity and entity.valid then
            player.centered_on = entity
        end
    end
end

function network_class.set_platform_unloading(platform, planet_name)
    set_platform_unloading(platform, planet_name)
end

function network_class.create_channel(name)
    if storage.ptflogchannel[name] then
        return -- already exist
    else
        storage.ptflogchannel[name] = {
            building = {
                ["ptflog-requester"] = {},
                ["ptflog-provider"] = {}
            },
            platform = {},
        }
    end
    LPN_gui_manager.update_channels()
end

network_class.events = {
    [defines.events.on_tick] = update_networks,
    [defines.events.on_player_clicked_gps_tag] = on_player_clicked_gps_tag,
}

return network_class
