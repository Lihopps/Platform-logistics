data:extend({
    {
    type = "sprite",
    name = "LPN-manager-black",
    filename = "__Platform-logistics__/graphics/utility/manager-black.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = {"gui-icon"},
    },
    {
    type = "sprite",
    name = "LPN-manager-white",
    filename = "__Platform-logistics__/graphics/utility/manager-white.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = {"gui-icon"},
    },
    {
    type = "sprite",
    name = "LPN-ship-black",
    filename = "__Platform-logistics__/graphics/utility/ship.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = {"gui-icon"},
    },
    {
    type = "sprite",
    name = "LPN-ship-white",
    filename = "__Platform-logistics__/graphics/utility/ship-white.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = {"gui-icon"},
    },
    {
    type = "sprite",
    name = "LPN-book",
    filename = "__Platform-logistics__/graphics/utility/book.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = {"gui-icon"},
    },
})

data:extend({
    {
    type = "custom-input",
    name = "toggle-LPN-MANAGER",
    key_sequence = "Z",
    consuming = "game-only",
    action = "lua"
  },
    {
    type = "shortcut",
    name = "toggle-LPN-MANAGER",
    --order = "c[toggles]-a[roboport]",
    action = "lua",
    localised_name = {"gui.toggle-LPN-MANAGER"},
    associated_control_input = "toggle-LPN-MANAGER",
    technology_to_unlock = "LPN-starter",
    unavailable_until_unlocked=true,
    icon = "__Platform-logistics__/graphics/utility/manager-black.png",
    icon_size = 64,
    small_icon = "__Platform-logistics__/graphics/utility/manager-black.png",
    small_icon_size = 64
  },
})

data.extend({
{
    type = "virtual-signal",
    name = "LPN-ship",
    icon = "__Platform-logistics__/graphics/utility/ship-white.png",
    subgroup = "pictographs",
    order = "sjd[z]-[lpn-ship]"
  },
})