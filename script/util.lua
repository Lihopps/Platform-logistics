local time_between_message = settings.global["LPN-message"].value
local time_out = settings.global["LPN-timout"].value

local util = {}

function util.time_out(typ2, item_name)
    local item = util.split(item_name, "_")
    game.print({ "", { "gui.timeout", item[1], item[2] } })
end

function util.not_provided_item(item, quality, entity)
    if not storage.ptflogmessenger["prov" .. item .. "_" .. quality] then
        game.print({ "", { "gui.not-provided", item, quality }, " [gps=" ..
        entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.index .. "]" })
        storage.ptflogmessenger["prov" .. item .. "_" .. quality] = game.tick
    else
        if game.tick - storage.ptflogmessenger["prov" .. item .. "_" .. quality] > 60 * (time_between_message) then
            game.print({ "", { "gui.not-provided", item, quality }, " [gps=" ..
            entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.index .. "]" })
            storage.ptflogmessenger["prov" .. item .. "_" .. quality] = game.tick
        end
    end
    --game.print("not provided item: " .. item .. "_" .. quality)
end

function util.not_platform(item, quality, entity)
    if not storage.ptflogmessenger["plat" .. item .. "_" .. quality] then
        game.print({ "", { "gui.not-plat", item, quality }, " [gps=" ..
        entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.index .. "]" })
        storage.ptflogmessenger["plat" .. item .. "_" .. quality] = game.tick
    else
        if game.tick - storage.ptflogmessenger["plat" .. item .. "_" .. quality] > 60 * (time_between_message) then
            game.print({ "", { "gui.not-plat", item, quality }, " [gps=" ..
            entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.index .. "]" })
            storage.ptflogmessenger["plat" .. item .. "_" .. quality] = game.tick
        end
    end
    --game.print("not platform for item: " .. item .. "_" .. quality)
end

function util.clear_network(name, network, clear_total)
    --game.print("clear Network: "..name)
    if clear_total then
        --stop all platform and erase filter
        for _, platform in ipairs(network.platform) do
            if not platform or not platform.valid then return false end
            platform.schedule = nil
            local hub = platform.hub
            if hub and hub.valid then
                local sections = hub.get_logistic_sections()
                if sections then
                    local section_name = "LPN : Platform n°: " .. platform.surface.index
                    for _, section in ipairs(sections.sections) do
                        if section.group == section_name then
                            section.filters = {}
                            break
                        end
                    end
                end
            end
        end

        --set incomming to 0
        --set reserved to 0
        for typ, data in pairs(network.building) do
            for unit_number, data2 in pairs(data) do
                for typ2, typ2_data in pairs(data2) do
                    for item_name, item_data in pairs(typ2_data) do
                        network.building[typ][unit_number][typ2][item_name] = nil
                    end
                end
            end
        end
        game.print("channel cleared : " .. name)
    else
        for typ, data in pairs(network.building) do
            for unit_number, data2 in pairs(data) do
                for typ2, typ2_data in pairs(data2) do
                    for item_name, item_data in pairs(typ2_data) do
                        if item_data.request == 0 and item_data.quantity == 0 then
                            network.building[typ][unit_number][typ2][item_name] = nil
                        end
                        if game.tick - item_data.tick > 60 * (time_out) then
                            network.building[typ][unit_number][typ2][item_name] = nil
                            if item_data.quantity > 0 then
                                util.time_out(typ2, item_name)
                            end
                        end
                        if item_data.platform then
                            if item_data.quantity>0 and not next(item_data.platform) then
                                network.building[typ][unit_number][typ2][item_name] = nil
                            end
                        end
                    end
                end
            end
        end
    end
end

--separate string
function util.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return util
