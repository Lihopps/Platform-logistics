data:extend(
  {
    { 
      type = "bool-setting",
      name = "LPN-enable-dispatcher",
      setting_type = "runtime-global",
      default_value = true,
      order="a"
    },
    {
      type = "int-setting",
      name = "LPN-dispatcher-update",
      setting_type = "runtime-global",
      default_value = 120,
      minimum_value = 1,
      order="b"
    },
    {
      type = "int-setting",
      name = "LPN-dispatcher-assign-per-cycle",
      setting_type = "runtime-global",
      default_value = 10,
      maximum_value = 100,
      minimum_value = 0,
      order="c"
    },
    {
      type = "int-setting",
      name = "LPN-default-threshold",
      setting_type = "runtime-global",
      default_value = 1,
      maximum_value = 10,
      minimum_value = 1,
      order="d",
      hidden=true,
    },
     {
      type = "int-setting",
      name = "LPN-default-priority",
      setting_type = "runtime-global",
      default_value = 0,
      order="e"
    },
    { 
      type = "bool-setting",
      name = "LPN-enable-circuit-condition",
      setting_type = "runtime-global",
      default_value = true,
      order="f"
    },
    {
      type = "int-setting",
      name = "LPN-default-inactivity",
      setting_type = "runtime-global",
      default_value = 5,
      minimum_value=1,
      order="g"
    },
    {
      type = "int-setting",
      name = "LPN-manager-update",
      setting_type = "runtime-global",
      default_value = 120,
      minimum_value = 1,
      order="h"
    },
  })

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- Settings si le présence de certain mod -------------------------------------
-------------------------------------------------------------------------------------------------------------------------

