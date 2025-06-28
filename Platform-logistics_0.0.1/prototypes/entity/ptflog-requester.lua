if not data.raw["cargo-landing-pad"]["cargo-landing-pad"].fast_replaceable_group then
    data.raw["cargo-landing-pad"]["cargo-landing-pad"].fast_replaceable_group="cargo-landing-pad"
end

requester = table.deepcopy(data.raw["cargo-landing-pad"]["cargo-landing-pad"])
requester.minable = { mining_time = 0.1, result = "ptflog-requester" }
requester.name = "ptflog-requester"
requester.flags={"placeable-neutral", "player-creation","get-by-unit-number"}
requester.collision_box = {{-3.9, -3.9}, {3.9, 3.9}}
requester.selection_box = {{-4, -4}, {4, 4}}
requester.icon = "__Platform-logistics__/graphics/entity/ptflog-requester/cargo-landing-pad.png"
requester.icon_size = 64
--requester.fast_replaceable_group="cargo-landing-pad"
requester.graphics_set.picture[5]={
          render_layer = "above-inserters",
          layers =
          {
            util.sprite_load("__Platform-logistics__/graphics/entity/ptflog-requester/planet-upper-hatch-occluder",
            {
              scale = 0.5,
              shift = {0, -1}
            })
          }
        }
requester.graphics_set.picture[4] = {
    render_layer = "object",
    layers =
    {
        util.sprite_load("__Platform-logistics__/graphics/entity/ptflog-requester/platform-hub-3",
            {
                scale = 0.5,
                shift = { 0, -1 }
            }),
        util.sprite_load("__base__/graphics/entity/cargo-hubs/hubs/planet-hub-shadow",
            {
                scale = 0.5,
                shift = { 8, 0 },
                draw_as_shadow = true
            }),
        util.sprite_load("__base__/graphics/entity/cargo-hubs/hubs/planet-hub-emission-A",
            {
                scale = 0.5,
                shift = { 0, -1 },
                draw_as_glow = true,
                blend_mode = "additive"
            }),
        util.sprite_load("__base__/graphics/entity/cargo-hubs/hubs/planet-hub-emission-C",
            {
                scale = 0.5,
                shift = { 0, -1 },
                draw_as_glow = true,
                blend_mode = "additive"
            }),
    }
}
requester.cargo_station_parameters.giga_hatch_definitions[1].hatch_graphics_back={
    layers =
    {
    util.sprite_load("__Platform-logistics__/graphics/entity/ptflog-requester/planet-upper-hatch-back",
      {
        scale = 0.5,
        shift = {0, -0.5},
        run_mode = "forward",
        frame_count = 20
      }),
    util.sprite_load("__base__/graphics/entity/cargo-hubs/hatches/shared-upper-hatch-shadow",
      {
        scale = 0.5,
        shift = {4,-0.5}, --util.by_pixel(128, 0)
        run_mode = "forward",
        draw_as_shadow = true,
        frame_count = 20
      }),
    util.sprite_load("__base__/graphics/entity/cargo-hubs/hatches/shared-upper-back-hatch-emission",
      {
        scale = 0.5,
        shift = {0, -0.5},
        run_mode = "forward",
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 20
      }),
    util.sprite_load("__base__/graphics/entity/cargo-hubs/hatches/planet-upper-front-hatch-emission",
      {
        scale = 0.5,
        shift = {0, -0.5},
        run_mode = "forward",
        draw_as_glow = true,
        blend_mode = "additive",
        frame_count = 3,
        frame_sequence = {1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3}
      })
    }
  }

requester.cargo_station_parameters.giga_hatch_definitions[1].hatch_graphics_front={
    layers =
    {
    util.sprite_load("__Platform-logistics__/graphics/entity/ptflog-requester/planet-upper-hatch-front",
      {
        scale = 0.5,
        shift = {0, -0.5},
        run_mode = "forward",
        frame_count = 20
      })
    }
  }



data:extend({requester})

data:extend({
    {
        type = "recipe",
        name = "ptflog-requester",
        enabled = lihop_debug,
        energy_required = 2,
        ingredients =
        {
            { type = "item", name = "cargo-landing-pad", amount = 1 },
            { type = "item", name = "requester-chest", amount = 5 },
            { type = "item", name = "radar", amount = 1 },
        },
        results = { { type = "item", name = "ptflog-requester", amount = 1 } }
    },
    {
        type = "item",
        name = "ptflog-requester",
        icon = "__Platform-logistics__/graphics/entity/ptflog-requester/cargo-landing-pad.png",
        icon_size = 64,
        subgroup = "space-interactors",
        order = "d-LPN[requester]",
        place_result = "ptflog-requester",
        stack_size = 1,
        weight = 1000 * kg
    },
})