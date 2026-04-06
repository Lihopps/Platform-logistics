data:extend({
  {
    type = "sprite",
    name = "LPN-manager-black",
    filename = "__Platform-logistics__/graphics/utility/manager-black.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = { "gui-icon" },
  },
  {
    type = "sprite",
    name = "LPN-manager-white",
    filename = "__Platform-logistics__/graphics/utility/manager-white.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = { "gui-icon" },
  },
  {
    type = "sprite",
    name = "LPN-ship-black",
    filename = "__Platform-logistics__/graphics/utility/ship.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = { "gui-icon" },
  },
  {
    type = "sprite",
    name = "LPN-ship-white",
    filename = "__Platform-logistics__/graphics/utility/ship-white.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = { "gui-icon" },
  },
  {
    type = "sprite",
    name = "LPN-book",
    filename = "__Platform-logistics__/graphics/utility/book.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = { "gui-icon" },
  },
  {
    type = "sprite",
    name = "LPN-migration-version",
    filename = "__Platform-logistics__/graphics/utility/migration.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    flags = { "gui-icon" },
  },
})

data:extend({
  {
    type = "custom-input",
    name = "toggle-LPN-MANAGER",
    key_sequence = ";",
    consuming = "game-only",
    action = "lua"
  },
  {
    type = "shortcut",
    name = "toggle-LPN-MANAGER",
    --order = "c[toggles]-a[roboport]",
    action = "lua",
    localised_name = { "gui.toggle-LPN-MANAGER" },
    associated_control_input = "toggle-LPN-MANAGER",
    technology_to_unlock = "LPN-starter",
    unavailable_until_unlocked = true,
    icon = "__Platform-logistics__/graphics/utility/manager-black.png",
    icon_size = 64,
    small_icon = "__Platform-logistics__/graphics/utility/manager-black.png",
    small_icon_size = 64
  },
})

data.extend({
  {
    type = "item-subgroup",
    name = "LPN-virtual-signal",
    group = "signals",
    order = "ea"
  },
  {
    type = "virtual-signal",
    name = "LPN-rocket_stack",
    icon = "__Platform-logistics__/graphics/utility/rocket_stack.png",
    subgroup = "LPN-virtual-signal",
    order = "a"
  },
  {
    type = "virtual-signal",
    name = "LPN-priority",
    icon = "__Platform-logistics__/graphics/utility/priority.png",
    subgroup = "LPN-virtual-signal",
    order = "b"
  },
})

local missing_platform = table.deepcopy(data.raw["fluid"]["water"])
missing_platform.name = "LPN-no-platform"
missing_platform.icon = "__Platform-logistics__/graphics/utility/no-platform.png"
missing_platform.icon_size = 64
missing_platform.icon_mipmaps = 0
missing_platform.hidden = true
missing_platform.auto_barrel = false
missing_platform.subgroup = "LPN-virtual-signal"
data.extend({ missing_platform })
