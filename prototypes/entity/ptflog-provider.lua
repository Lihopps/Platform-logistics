data:extend({
    {
        type = "recipe",
        name = "ptflog-provider",
        enabled = lihop_debug,
        energy_required = 2,
        ingredients =
        {
            { type = "item", name = "passive-provider-chest",      amount = 5 },
            { type = "item", name = "selector-combinator", amount = 2 },
            { type = "item", name = "radar", amount = 1 },
        },
        results = { { type = "item", name = "ptflog-provider", amount = 1 } }
    },
    {
        type = "item",
        name = "ptflog-provider",
        icon = "__Platform-logistics__/graphics/entity/ptflog-provider/provider-icon.png",
        subgroup = "space-interactors",
        order = "d-LPN[provider]",
        place_result = "ptflog-provider",
        stack_size = 10,
        weight = 100 * kg
    },
    {
    type = "arithmetic-combinator",
    name = "ptflog-provider",
    icon = "__Platform-logistics__/graphics/entity/ptflog-provider/provider-icon.png",
    flags = {"placeable-neutral", "player-creation","get-by-unit-number","not-rotatable"},
    minable = {mining_time = 0.1, result = "ptflog-provider"},
    max_health = 150,
    corpse = "arithmetic-combinator-remnants",
    dying_explosion = "arithmetic-combinator-explosion",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1, -1}, {1, 1}},
    --damaged_trigger_effect = hit_effects.entity(),
    --icon_draw_specification = {scale = 0.5},

    energy_source =
    {
      type = "void",
    },
    active_energy_usage = "1kW",

    working_sound =
    {
      sound = {filename = "__base__/sound/combinator.ogg", volume = 0.45, audible_distance_modifier = 0.2},
      fade_in_ticks = 4,
      fade_out_ticks = 20,
      match_speed_to_activity = true
    },
    --open_sound = sounds.combinator_open,
    --close_sound = sounds.combinator_close,

    activity_led_light_offsets =
    {
      {0.234375, -0.484375},
      {0.5, 0},
      {-0.265625, 0.140625},
      {-0.453125, -0.359375}
    },

    screen_light_offsets =
    {
      {0.015625, -0.234375},
      {0.015625, -0.296875},
      {0.015625, -0.234375},
      {0.015625, -0.296875}
    },

    sprites={
      filename="__Platform-logistics__/graphics/entity/ptflog-provider/provider.png",
      width=250,
      height=286,
      scale=0.5,
      shift={0,-0.5}
    },
    input_connection_bounding_box = {{-1, -1}, {1, 1}},
    output_connection_bounding_box = {{0, 0}, {0, 0}},

    circuit_wire_max_distance = combinator_circuit_wire_max_distance,
    input_connection_points =
  {
    {
      shadow =
      {
        red = util.by_pixel(5, 26),
        green = util.by_pixel(24.5, 26)
      },
      wire =
      {
        red = util.by_pixel(-5.5, 14),
        green = util.by_pixel(10, 14)
      }
    },{wire={},shadow={}},{wire={},shadow={}},{wire={},shadow={}}
  },
  output_connection_points ={{shadow ={},wire ={}},{wire={},shadow={}},{wire={},shadow={}},{wire={},shadow={}}}
  },
})