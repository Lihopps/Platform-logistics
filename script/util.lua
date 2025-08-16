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

function util.name_and_qual(item)
    local names=util.split(item,"_")
    local qual=names[#names]
    local name=string.gsub(item,"_"..qual,"")
    return {name,qual}
end

function util.check(channel, entity, contents, name)
    --game.print("start test")
    local token=true
    if not channel then 
        token=false
        goto save 
    end
    if not storage.ptflogchannel[channel] then 
        token=false
        goto save 
    end
    if not storage.ptflogchannel[channel].building["ptflog-" .. name] then 
        token=false
        goto save 
    end
    if not storage.ptflogchannel[channel].building["ptflog-" .. name][entity.unit_number] then 
        token=false
        goto save 
    end
    if not contents.name then 
        token=false
        goto save 
    end
    if not contents.quality then 
        token=false
        goto save 
    end
    if not storage.ptflogchannel[channel].building["ptflog-" .. name][entity.unit_number].incomming and not storage.ptflogchannel[channel].building["ptflog-" .. name][entity.unit_number].reserved then 
        token=false
        goto save 
    end
    --game.print("test pass")
    ::save::
    if token then
        return token
    else
        if settings.global["LPN-edit_file"].value then
            local object={
                channel=channel,
                entity=entity,
                contents=contents,
                name=name,
                storage=storage
            }
            helpers.write_file("check_fail_"..game.tick..".json",helpers.table_to_json(object))
            if lihop_debug then
                game.print("Some check fail see file")
            end
        end
        return token
    end
end

function util.create_flying_text(player,text,position,cursor,type)
    if not player or not player.valid then return end

    player.create_local_flying_text{text=text,position=position,create_at_cursor=cursor}

end


return util
