local util = require("script.util")


local function on_entity_build(e)
	if not e.entity then return end
	if e.entity.name == "ptflog-requester" then
		storage.request_nodes[e.entity.unit_number] = {
			id = e.entity.unit_number,
			entity = e.entity,
			location = e.entity.surface,
			network="signal-A_normal",
			sub_network="1"
		}
	end
end

local function on_entity_disapear(e)
	local entity = e.entity
	if not entity or not entity.valid then
		return
	end
	if entity.name == "ptflog-requester" then
		storage.request_nodes[entity.unit_number] = nil
		storage.request_reservations[e.entity.unit_number] = nil
	end
end


local requester = {}

requester.events = {
	[defines.events.on_built_entity] = on_entity_build,
	[defines.events.on_robot_built_entity] = on_entity_build,
	[defines.events.on_pre_player_mined_item] = on_entity_disapear,
	[defines.events.on_robot_pre_mined] = on_entity_disapear,
	[defines.events.on_entity_died] = on_entity_disapear,
	[defines.events.script_raised_destroy] = on_entity_disapear,

}

return requester
