local function on_entity_build(e)
    if not e.entity then return end
    if e.entity.name=="ptflog-provider" then  
        storage.ptflogchannel["DEFAULT"].building["ptflog-provider"][e.entity.unit_number]={
            reserved={}
        }
        storage.ptflogtracker[e.entity.unit_number]="DEFAULT"
        --e.entity.operable=false
    end
end

local function on_entity_disapear(e)
    local entity = e.entity
	if not entity or not entity.valid then
		return
	end
	if entity.name == "ptflog-provider" then
		storage.ptflogchannel["DEFAULT"].building["ptflog-provider"][e.entity.unit_number] = nil
        storage.ptflogtracker[e.entity.unit_number]=nil
	end

end

local provider={}

provider.events={
    [defines.events.on_built_entity]=on_entity_build,
	[defines.events.on_robot_built_entity]=on_entity_build,
    [defines.events.on_pre_player_mined_item]=on_entity_disapear,
	[defines.events.on_robot_pre_mined]=on_entity_disapear,
	[defines.events.on_entity_died]=on_entity_disapear,
	[defines.events.script_raised_destroy]=on_entity_disapear,
}

return provider