local util = require("script.util")

local function on_entity_build(e)
    if not e.entity then return end
    if e.entity.name == "ptflog-provider" then
        storage.supply_nodes[e.entity.unit_number] = {
            id = e.entity.unit_number,
            entity = e.entity,
            location = e.entity.surface,
            network = "signal-A_normal",
            sub_network = "1"
        }
        --e.entity.operable=false
    end
end

local function on_entity_disapear(e)
    local entity = e.entity
    if not entity or not entity.valid then
        return
    end
    if entity.name == "ptflog-provider" then
        storage.supply_nodes[e.entity.unit_number] = nil
        storage.reservations[e.entity.unit_number] = nil
    end
end

--- Provider, Requester, platform
local function on_entity_settings_pasted(e)
    local data = {
        ["ptflog-provider"] = "supply_nodes",
        ["ptflog-requester"] = "request_nodes",
        ["space-platform-hub"] = "platforms"
    }
    if e.destination and e.source then
        if data[e.source.name] and data[e.destination.name] then
            if storage[data[e.source.name]][e.source.unit_number] and storage[data[e.destination.name]][e.destination.unit_number] then
                storage[data[e.destination.name]][e.destination.unit_number].network=storage[data[e.source.name]][e.source.unit_number].network
                storage[data[e.destination.name]][e.destination.unit_number].sub_network=storage[data[e.source.name]][e.source.unit_number].sub_network
            end
        end
    end
end

local provider = {}

provider.events = {
    [defines.events.on_built_entity] = on_entity_build,
    [defines.events.on_robot_built_entity] = on_entity_build,
    [defines.events.on_pre_player_mined_item] = on_entity_disapear,
    [defines.events.on_robot_pre_mined] = on_entity_disapear,
    [defines.events.on_entity_died] = on_entity_disapear,
    [defines.events.script_raised_destroy] = on_entity_disapear,
    [defines.events.on_entity_settings_pasted] = on_entity_settings_pasted,
}

return provider
