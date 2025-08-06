data:extend({
	{
    type = "technology",
    name = "LPN-starter",
    icon_size = 256,
    icon ="__Platform-logistics__/graphics/technology/lpn-starter.png",
    effects =
    {
		{
			type = "unlock-recipe",
			recipe = "ptflog-provider"
		},
		{
			type = "unlock-recipe",
			recipe = "ptflog-requester"
		},
		{
			type = "nothing",
			effect_description={"gui.unlock-LPN-manager"},
            icon="__Platform-logistics__/graphics/utility/manager-white.png"
		},
        {
			type = "nothing",
			effect_description={"gui.unlock-LPN-platform"},
            icons={
				{
					icon="__space-age__/graphics/icons/space-platform-hub.png",

				},
				{
					icon="__Platform-logistics__/graphics/utility/logistics.png",
					scale=0.5,
					shift={5,0}
				}
			}
		},
	},
    prerequisites = {"space-platform-thruster","radar","logistic-system"},
    unit =
    {
		  count = 2000,
		  ingredients =
		  {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"production-science-pack", 1},
			{"utility-science-pack", 1},
			{"space-science-pack", 1}
		  },
		  time = 30
	},
    order = "a-b-b"
	},
	{
    type = "technology",
    name = "LPN-landing-bonus",
    icon_size = 256,
    icon ="__Platform-logistics__/graphics/technology/lpn-bonus.png",
    effects =
    {
		{
			type = "cargo-landing-pad-count",
			modifier=1,
			hidden=true
		},
		{
			type = "nothing",
			effect_description={"",{"technology-description.landing-bonus"},""},
            icon="__Platform-logistics__/graphics/utility/landig-bonus.png"
		},
	},
	show_levels_info=true,
    prerequisites = {"LPN-starter"},
    unit =
    {
		  count_formula = "2^(L-1)*3000",
		  ingredients =
		  {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"production-science-pack", 1},
			{"utility-science-pack", 1},
			{"space-science-pack", 1}
		  },
		  time = 30
	},
	max_level = "infinite",
    upgrade = true,
    order = "a-b-b"
	}
})