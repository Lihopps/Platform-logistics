local simulation = {}

simulation.lpn_provider2 = {
 init =
    [[
    require("__core__/lualib/story")
    player = game.simulation.create_test_player{name = "big k"}
    player.teleport({-2, 0})
    game.simulation.camera_player = player
    game.simulation.camera_position = {0, 0.5}
    game.simulation.camera_player_cursor_position = player.position
    game.simulation.camera_alt_info=true
    player.character.direction = defines.direction.south
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNp9kttugzAMht/Fl1OoCgMGvMo0oQBusQQJTQJaVeXd57SjSBvbXXz8P9u5QTPMOBlSDqobUKuVher9BpbOSg7Bp+SIUMHkToM+R5PRC3VowAsg1eEnVLH/EIDKkSN8FN+Na63mseHMKhZ/NREwact1WgUl7hXFWSHgyo88eWMJ5nFGD3WDvVxIm5AmDbl+REdtzeHuXm5DwGKwg9M6GQY6CtATGvkQgBfw3otfeMkTzzpt5BmjtkfrduHKQ7bipYeMAQ1eZk6uTzQ4NCvGNxKvYtvRnvTrU3qFjlo9NqQkk+wC5D8B9ja0EfxDE65GDkcW3/6AgIWnuCtmeVKmZZkV6TE5poX3X2zevNw=",
      position = {0, 0},
    }

    game.forces.player.technologies["circuit-network"].research_recursive()
    --game.forces.player.technologies["logistics"].researched = true -- for splitters to be selectable

    chest = game.surfaces[1].find_entities_filtered{name = "storage-chest"}[1]
    chest.insert({name="iron-plate", count=1000, quality="normal"})
    provider = game.surfaces[1].find_entities_filtered{name = "ptflog-provider"}[1]
    combinator=game.surfaces[1].find_entities_filtered{name = "constant-combinator"}[1]
    local text_position={5,0}
    local time=3

    button = ""
    slot_data = ""
    item_group=""
    typ=""
    type_text=""

    local story_table =
    {
      {
        {
          name = "start",
          init = function()
           
            button = "0"
            slot_data = "signal-A"
            item_group ="signals"
            typ="signals"
            type_text="item"
          end,

          condition = story_elapsed_check(time+1)
        },
        {
          init = function() player.cursor_stack.set_stack{name = "red-wire", count = 1} end,
          condition = function() return game.simulation.move_cursor({position = chest.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = chest.position} end
        },
        {
          condition = function() return game.simulation.move_cursor({position = provider.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = provider.position} end
        },
        {
            init = function()
            player.cursor_stack.clear()
             end,

            condition = story_elapsed_check(time+1)
        },
        {
            init = function()
          
          end,
            condition = story_elapsed_check(time+1)
        },
         {
          init = function() player.cursor_stack.set_stack{name = "green-wire", count = 1} end,
          condition = function() return game.simulation.move_cursor({position = combinator.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = combinator.position} end
        },
        {
          condition = function() return game.simulation.move_cursor({position = provider.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = provider.position} end
        },
         {
          init = function() player.cursor_stack.clear() end,
          condition = function() return game.simulation.move_cursor({position = combinator.position, speed = 0.1}) end,
        },
        {
          condition = story_elapsed_check(0.5),
          action = function()
            local chest_position = chest.position
            local provider_position =provider.position
            local combinator_pos=combinator.position
            chest.destroy()
            provider.destroy()
            combinator.destroy()
            chest = game.surfaces[1].create_entity{name = "storage-chest", position = chest_position, force = player.force, create_build_effect_smoke = false}
            provider = game.surfaces[1].create_entity{name = "ptflog-provider", position = provider_position, force = player.force, create_build_effect_smoke = false}
            combinator = game.surfaces[1].create_entity{name = "constant-combinator", position = combinator_pos, force = player.force, create_build_effect_smoke = false}
            chest.insert({name="iron-plate", count=1000, quality="normal"})

            story_jump_to(storage.story, "start")
          end
        }
      }
    }
    tip_story_init(story_table)
  ]]
}

simulation.lpn_provider = {
    init =
    [[
    require("__core__/lualib/story")
    player = game.simulation.create_test_player{name = "big k"}
    player.teleport({-2, 0})
    game.simulation.camera_player = player
    game.simulation.camera_position = {0, 0.5}
    game.simulation.camera_player_cursor_position = player.position
    game.simulation.camera_alt_info=true
    player.character.direction = defines.direction.south
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNp9kttugzAMht/Fl1OoCgMGvMo0oQBusQQJTQJaVeXd57SjSBvbXXz8P9u5QTPMOBlSDqobUKuVher9BpbOSg7Bp+SIUMHkToM+R5PRC3VowAsg1eEnVLH/EIDKkSN8FN+Na63mseHMKhZ/NREwact1WgUl7hXFWSHgyo88eWMJ5nFGD3WDvVxIm5AmDbl+REdtzeHuXm5DwGKwg9M6GQY6CtATGvkQgBfw3otfeMkTzzpt5BmjtkfrduHKQ7bipYeMAQ1eZk6uTzQ4NCvGNxKvYtvRnvTrU3qFjlo9NqQkk+wC5D8B9ja0EfxDE65GDkcW3/6AgIWnuCtmeVKmZZkV6TE5poX3X2zevNw=",
      position = {0, 0},
    }

    game.forces.player.technologies["circuit-network"].research_recursive()
    --game.forces.player.technologies["logistics"].researched = true -- for splitters to be selectable

    chest = game.surfaces[1].find_entities_filtered{name = "storage-chest"}[1]
    chest.insert({name="iron-plate", count=1000, quality="normal"})
    provider = game.surfaces[1].find_entities_filtered{name = "ptflog-provider"}[1]
    combinator=game.surfaces[1].find_entities_filtered{name = "constant-combinator"}[1]
    local text_position={0,3.5}
    local time=3

    button = ""
    slot_data = ""
    item_group=""
    typ=""
    type_text=""

    local story_table =
    {
      {
        {
          name = "start",
          init = function()
           rendering.draw_text{
                text={"tat-text-1"},
                target=text_position,
                time_to_live=60*time,
                surface=game.surfaces[1],
                color={r = 1, g = 1, b = 1},
                alignment="center",
            }
            button = "0"
            slot_data = "signal-A"
            item_group ="signals"
            typ="signals"
            type_text="item"
          end,

          condition = story_elapsed_check(time+1)
        },
        {
          init = function() player.cursor_stack.set_stack{name = "red-wire", count = 1} end,
          condition = function() return game.simulation.move_cursor({position = chest.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = chest.position} end
        },
        {
          condition = function() return game.simulation.move_cursor({position = provider.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = provider.position} end
        },
        {
            init = function()
            player.cursor_stack.clear()
            rendering.draw_text{
                text={"tat-text-2"},
                target=text_position,
                time_to_live=60*time,
                surface=game.surfaces[1],
                color={r = 1, g = 1, b = 1},
                alignment="center",
            }
             end,

            condition = story_elapsed_check(time+1)
        },
        {
            init = function()
           rendering.draw_text{
                text={"tat-text-3"},
                target=text_position,
                time_to_live=60*time,
                surface=game.surfaces[1],
                color={r = 1, g = 1, b = 1},
                alignment="center",
            }
          end,
            condition = story_elapsed_check(time+1)
        },
         {
          init = function() player.cursor_stack.set_stack{name = "green-wire", count = 1} end,
          condition = function() return game.simulation.move_cursor({position = combinator.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = combinator.position} end
        },
        {
          condition = function() return game.simulation.move_cursor({position = provider.position, speed = 0.1}) end,
          action = function() player.drag_wire{position = provider.position} end
        },
         {
          init = function() player.cursor_stack.clear() end,
          condition = function() return game.simulation.move_cursor({position = combinator.position, speed = 0.1}) end,
        },
        {
          condition = story_elapsed_check(0.25),
          action = function() player.opened = combinator end
        },
        { condition = story_elapsed_check(0.25) },
        {
          name = "continue",
          condition = function()
            local target = game.simulation.get_widget_position({type = "logistics-button", data = button})
            return game.simulation.move_cursor({position = target, speed = 0.1})
          end
        },
        {
          condition = story_elapsed_check(0.25),
          action = function() game.simulation.mouse_click() end
        },
        {
          condition = function()
            local target = game.simulation.get_widget_position({type = "item-group-tab", data = item_group})
            return game.simulation.move_cursor({position = target, speed = 0.1})
          end
        },
        {
          condition = story_elapsed_check(0.35),
          action = function() game.simulation.mouse_click() end
        },
        {
          condition = function()
            local target = game.simulation.get_widget_position({type = "signal-id-base", data = slot_data,data2="virtual"})
            return game.simulation.move_cursor({position = target, speed = 0.1})
          end
        },
        {
          condition = story_elapsed_check(0.35),
          action = function() game.simulation.mouse_click() end
        },
        {
          condition = story_elapsed_check(0.75),
          action = function()
            game.simulation.control_press{control = "confirm-gui", notify = true}
          end
        },
        {
            condition = story_elapsed_check(4),
            init = function()
                rendering.draw_text{
                    text={"tat-text-4-type"},
                    target=text_position,
                    time_to_live=60*time,
                    surface=game.surfaces[1],
                    color={r = 1, g = 1, b = 1},
                    alignment="center",
                }
            end,
        },
        {
          condition = story_elapsed_check(0.25),
          action = function()
            if button == "2" then button = "3" end
            if button == "1" then
                button = "2"
                slot_data = "LPN-rocket_stack"
                item_group="signals"
                typ="signal"
                type_text="stack"
            end
            if button == "0" then
                button = "1"
                slot_data = "signal-A"
                item_group="signals"
                typ="signal"
                type_text="priority"
            end
            if button < "3" then story_jump_to(storage.story, "continue") end
          end
        },
        {
          condition = function() return game.simulation.move_cursor({position = player.position, speed = 0.5}) end,
          action = function() player.opened = nil end
        },
        {
          condition = story_elapsed_check(0.5),
          action = function()
            local chest_position = chest.position
            local provider_position =provider.position
            local combinator_pos=combinator.position
            chest.destroy()
            provider.destroy()
            combinator.destroy()
            chest = game.surfaces[1].create_entity{name = "storage-chest", position = chest_position, force = player.force, create_build_effect_smoke = false}
            provider = game.surfaces[1].create_entity{name = "ptflog-provider", position = provider_position, force = player.force, create_build_effect_smoke = false}
            combinator = game.surfaces[1].create_entity{name = "constant-combinator", position = combinator_pos, force = player.force, create_build_effect_smoke = false}
            chest.insert({name="iron-plate", count=1000, quality="normal"})

            story_jump_to(storage.story, "start")
          end
        }
      }
    }
    tip_story_init(story_table)
  ]]
}

simulation.lpn_requester = {
 init =
    [[
    require("__core__/lualib/story")
    player = game.simulation.create_test_player{name = "big k"}
    player.teleport({-6, 2})
    game.simulation.camera_player = player
    game.simulation.camera_position = {0, 0.5}
    game.simulation.camera_player_cursor_position = player.position
    game.simulation.camera_alt_info=true
    player.character.direction = defines.direction.south
    game.surfaces[1].create_entities_from_blueprint_string
    {
      string = "0eNqllM1uqzAQhV+l8hpXQEmVIHXRV+g2ipABQ0cyHuKftFHEu3cMt9Cfm0oRYoGwPcefj4dzYaXysjegHcsvDCrUluX7C7PQaqHCmBadZDnrXaOw5UYevbROGjZEDHQt31meDIeISe3AgZyqx49zoX1X0so8ia6qRKxHS4Wow14kts0idmZ5RvIE4wyqopSv4gRowooKTOXBFR3WssCmwF4aMZWnVPJPuGhAkboNFVZWYX4C+ySO2Lzi2+gnpsFKWgu65V6DI8qjF4qORHMaTUfOBLyuF7R5AGNP44APNiZxHA/RrJrOqq+oOvAd75VwcpXmw6xpPRlARtW+CkVrRJPl/M7rlq5H80qYEup1sEn6W3e9BelCGyBR8wZKuc6BdCFV+MZrqak1z9w6Q+56cyNwGsQP3zvhz64DQ6dAc7sv/+22CntqjbV6D19cVhW4VWLZjyu7XYuCpjXoe5rZn8A4quZTVD1NL66RU/qY8+H56EHh3cuUCCyUzulgsCtK3zTjVdDtyiFQ/kitr1Zq64R2nNBK0GL6034F1/1mjK7t/eZKeC1RdCWWqF2GAPoGZkzSfRKl4TnQGHnfEcuS1xE7Ef8IsHlMd9lut9lmcRpn22H4AMid8rg=",
      position = {0, 0},
    }

    --game.forces.player.technologies["circuit-network"].research_recursive()
    --game.forces.player.technologies["logistics"].researched = true -- for splitters to be selectable

   
    requester = game.surfaces[1].find_entities_filtered{name = "ptflog-requester"}[1]
    combinator=game.surfaces[1].find_entities_filtered{name = "constant-combinator"}[1]
    local text_position={5,0}
    local time=3

    button = ""
    slot_data = ""
    item_group=""
    typ=""
    type_text=""

    local story_table =
    {
      {
        {
          name = "start",
          init = function()
           
           
          end,
        action = function() player.opened = requester end,
          condition = story_elapsed_check(1)
        },
      }
    }
    tip_story_init(story_table)
  ]]
}


return simulation
