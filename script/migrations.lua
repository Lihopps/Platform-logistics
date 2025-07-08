local flib_migration = require("__flib__.migration")
local v1_0_2 =require("migration.1_0_2")


local by_version = {
  ["1.0.2"] = function()
    --reset all network si il y a des channels avec nouveau nom github#1
    v1_0_2.change()
  end,
}

--- @param e ConfigurationChangedData
local function on_configuration_changed(e)
  flib_migration.on_config_changed(e, by_version)
end

local migrations = {}

migrations.on_configuration_changed = on_configuration_changed

return migrations