
local gui = require("__flib__.gui")
local migration_gui={}

local function on_gui_migration_closed(e)
    local element = e.element
    if element and element.valid then
        if (element.name == "LPN-migration-gui" and element.visible) or element.name=="LPN-migration-button_close" then
            game.players[e.player_index].opened = nil
            game.players[e.player_index].gui.screen["LPN-migration-gui"].destroy()
        end
    end
end

function migration_gui.create_gui(player,version)
    if player.gui.screen["LPN-migration-gui"] then
        player.gui.screen["LPN-migration-gui"].destroy()
    end
    local migration_manager = gui.add(player.gui.screen,
        {
            type = "frame",
            name = "LPN-migration-gui",
            direction = "vertical",
            visible = true,
            style_mods = {
                size = { 1228, 920 }
            },
            handler = { [defines.events.on_gui_closed] = on_gui_migration_closed },
            children = {
                ----bar du haut
                {
                    type = "flow",
                    style_mods = { horizontally_squashable = true },
                    name = "titlebar",
                    children = {
                        {
                            type = "label",
                            style = "subheader_caption_label",
                            rich_text_setting = "enabled",
                            caption = { "gui.migration_gui" },
                            name = "name_label",
                        },
                        {
                            type = "empty-widget",
                            style = "draggable_space_header",
                            style_mods = { height = 24, horizontally_stretchable = true, right_margin = 4 },
                            ignored_by_interaction = true,
                        },
                        {
                            type = "sprite-button",
                            style = "frame_action_button",
                            sprite = "utility/close",
                            name = "LPN-migration-button_close",
                            hovered_sprite = "utility/close",
                            clicked_sprite = "utility/close",
                            tooltip = { "gui.close-instruction" },
                            handler = { [defines.events.on_gui_click] = on_gui_migration_closed },
                        },
                    },
                },
                ---- page principale
                {
                    type = "frame",
                    style = "inside_deep_frame",
                    direction = "vertical",
                    style_mods = { horizontally_stretchable = true, vertically_stretchable = true },
                    children = {
                        {
                            type="flow",
                            direction = "vertical",
                            style_mods = {padding=10,margin=10},
                            children={
                                {
                                    type="label",
                                    caption={"gui.migration-title",version},
                                    style = "heading_2_label",
                                },
                                {
                                    type="label",
                                    style_mods={single_line=false},
                                    caption={"migration."..version}
                                }
                            }
                        }
                    }
                }

            }
        })

    --update_general_flow(lpn_manager["general_flow"])
    migration_manager.titlebar.drag_target = migration_manager["LPN-migration-gui"]
    migration_manager["LPN-migration-gui"].force_auto_center()
    player.opened = migration_manager["LPN-migration-gui"]
end





migration_gui.events = {
    [defines.events.on_gui_closed] = on_gui_migration_closed,
}

gui.add_handlers({
    on_gui_migration_closed=on_gui_migration_closed
})



return migration_gui