local network = require "script.network"


local function on_entity_build(e)
    if not e.entity then return end
    if e.entity.name=="ptflog-requester" then  
		storage.ptflogchannel["DEFAULT"].building["ptflog-requester"][e.entity.unit_number]={
			incomming={}
		}
		storage.ptflogtracker[e.entity.unit_number]="DEFAULT"
		local sections = e.entity.get_logistic_sections()
		local point=e.entity.get_logistic_point(defines.logistic_member_index.logistic_container)
		if point.trash_not_requested then
			point.trash_not_requested=false
		end
		if sections then
			sections = sections.sections
			for _, section in pairs(sections) do
				if section.is_manual then
					section.active=false
				end
			end
		end
		local control=e.entity.get_or_create_control_behavior()
		if control then
			control.circuit_exclusive_mode_of_operation=defines.control_behavior.cargo_landing_pad.exclusive_mode.none
		end
	end
end

local function on_entity_disapear(e)
    local entity = e.entity
	if not entity or not entity.valid then
		return
	end
	if entity.name == "ptflog-requester" then
		storage.ptflogchannel["DEFAULT"].building["ptflog-requester"][e.entity.unit_number] = nil
		storage.ptflogtracker[e.entity.unit_number]=nil
	end

end


local requester={}

requester.events={
    [defines.events.on_built_entity]=on_entity_build,
	[defines.events.on_robot_built_entity]=on_entity_build,
    [defines.events.on_pre_player_mined_item]=on_entity_disapear,
	[defines.events.on_robot_pre_mined]=on_entity_disapear,
	[defines.events.on_entity_died]=on_entity_disapear,
	[defines.events.script_raised_destroy]=on_entity_disapear,
}

return requester