local gui = require("__flib__.gui")
local debug =require("script.debug")

local function on_control_sys_click(e)
    debug.control_system(true)
end

local function on_reset_click(e)
    debug.reset(true)
end


local debug_tab = {}

function debug_tab.create_content_tab()
    for _, player in pairs(game.players) do
        if player.gui.screen["LPN-manager-gui"] then
            gui.add(player.gui.screen["LPN-manager-gui"].children[2].children[2], {
                tab = {
                    type = "tab",
                    caption = "test", --{ "gui.debug" },
                    --style="LPN_tabbed_pane"
                    visible = settings.global["LPN-show-debug-tab"].value
                },
                content = {
                    type = "flow",
                    --visible = settings.global["LPN-show-debug-tab"].value,
                    style = "horizontal_flow",
                    style_mods = { horizontal_spacing = 12 },
                    direction = "horizontal",
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            children = {
                                {
                                    type = "flow",
                                    direction = "horizontal",
                                    children = {
                                        {
                                            type = "button",
                                            caption = {"gui.control-sys"},
                                            tooltip={"gui.button-warning"},
                                            handler = { [defines.events.on_gui_click] = on_control_sys_click }
                                        },
                                        {
                                            type = "label",
                                            caption = {"gui.control-sys-label"}
                                        }
                                    }
                                },
                                {
                                    type = "flow",
                                    direction = "horizontal",
                                    children = {
                                        {
                                            type = "button",
                                            caption = {"gui.reset"},
                                            tooltip={"gui.button-warning"},
                                            handler = { [defines.events.on_gui_click] = on_reset_click }
                                        },
                                        {
                                            type = "label",
                                            caption = {"gui.reset-label"},
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        end
    end
end

function debug_tab.remove()
    for _, player in pairs(game.players) do
        if player.gui.screen["LPN-manager-gui"] then
            player.gui.screen["LPN-manager-gui"].children[2].children[2].children[7].destroy()
        end
    end
end

function debug_tab.update_debug_tab(player, item_filter, network, sub_network, selected_tab_index, trigger)

end


gui.add_handlers({
    on_control_sys_click = on_control_sys_click,
    on_reset_click = on_reset_click
})

return debug_tab
