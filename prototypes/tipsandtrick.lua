--[[
tips titre : présentation entity prov request platform
tips 1 : channel (create, define)
tips 2 : platform schedule
tips 3 : gui manager
tips 4 : more landing pad per planet

]]

data:extend({
	{
		type = "tips-and-tricks-item-category",
		name = "LPN",
		order = "l-[space-age]-[LPN]",
	},
	{
		type = "tips-and-tricks-item",
		name = "LPN-title",
		localised_description={"tips-and-tricks-item-description.LPN-title"},
		category = "LPN",
		order = "0",
		starting_status = "locked",
		trigger =
		{
			type = "research",
			technology = "LPN-starter"
		},
		tag = "[virtual-signal=LPN-ship]",
		is_title = true,
        image="__Platform-logistics__/graphics/utility/tat-title.png",
		--simulation=simulations.spidertron
	},
     {
		type = "tips-and-tricks-item",
		name = "LPN-tat-1",
		localised_description={"tips-and-tricks-item-description.LPN-tat-1"},
		category = "LPN",
		order = "1",
		starting_status = "locked",
        indent=1,
		trigger =
		{
			type = "research",
			technology = "LPN-starter"
		},
		--tag = "[virtual-signal=LPN-ship]",
		is_title = false,
        image="__Platform-logistics__/graphics/utility/tat-channel.png",
		--simulation=simulations.spidertron
	},
    {
		type = "tips-and-tricks-item",
		name = "LPN-tat-2",
		localised_description={"tips-and-tricks-item-description.LPN-tat-2"},
		category = "LPN",
		order = "2",
        indent=1,
		starting_status = "locked",
		trigger =
		{
			type = "research",
			technology = "LPN-starter"
		},
		--tag = "[virtual-signal=LPN-ship]",
		is_title = false,
        image="__Platform-logistics__/graphics/utility/tat-schedule.png",
		--simulation=simulations.spidertron
	},
    {
		type = "tips-and-tricks-item",
		name = "LPN-tat-3",
		localised_description={"tips-and-tricks-item-description.LPN-tat-3"},
		category = "LPN",
		order = "3",
		starting_status = "locked",
        indent=1,
		trigger =
		{
			type = "research",
			technology = "LPN-starter"
		},
		tag = "[img=LPN-manager-white]",
		is_title = false,
        image="__Platform-logistics__/graphics/utility/tat-lpngm.png",
		--simulation=simulations.spidertron
	},
	{
		type = "tips-and-tricks-item",
		name = "LPN-tat-4",
		localised_description={"tips-and-tricks-item-description.LPN-tat-4"},
		category = "LPN",
		order = "4",
		starting_status = "locked",
        indent=1,
		trigger =
		{
			type = "research",
			technology = "LPN-landing-bonus"
		},
		is_title = false,
        image="__Platform-logistics__/graphics/utility/tat-landing-bonus.png",
		--simulation=simulations.spidertron
	},
})