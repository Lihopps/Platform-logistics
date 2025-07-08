data:extend(
  {
    {
      type = "int-setting",
      name = "LPN-timout",
      setting_type = "runtime-global",
      default_value = 600,
      maximum_value = 600*10,
      minimum_value = 1,
    },
    {
      type = "int-setting",
      name = "LPN-message",
      setting_type = "runtime-global",
      default_value = 120,
      maximum_value = 120*10,
      minimum_value = 1,
    },
    {
      type = "double-setting",
      name = "LPN-clearer",
      setting_type = "runtime-global",
      default_value = 1,
      maximum_value = 10,
      minimum_value = 1/60,
    },
    {
      type = "double-setting",
      name = "LPN-rate",
      setting_type = "runtime-global",
      default_value = 0.7,
      maximum_value = 1,
      minimum_value = 0.1,
    },
    {
      type = "double-setting",
      name = "LPN-free_slot",
      setting_type = "runtime-global",
      default_value = 10,
      maximum_value = 100,
      minimum_value = 0,
    },
   
  })

-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- Settings si le présence de certain mod -------------------------------------
-------------------------------------------------------------------------------------------------------------------------

