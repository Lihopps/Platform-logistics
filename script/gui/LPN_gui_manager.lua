local mod_gui = require("__core__.lualib.mod-gui")
local gui = require("__flib__.gui")
local util = require("script.util")
local blueprint = require("script.blueprint")
local gui_util = require("script.gui.gui-util")
local inventory_tab = require("script.gui.inventory")
local platform_tab = require("script.gui.platform")
local station_tab = require("script.gui.station")
local debug_tab=require("script.gui.debug")
local migration_gui = require("migration.migration-gui")


local margin = 3
local padding = 3

local LPN_gui_manager = {}

local function value_from_element(element)
    if not element.elem_value then return nil end
    return element.elem_value.name .. "_" .. (element.elem_value.quality or "normal")
end

local function update_gui(player, trigger)
    local parameter = player.gui.screen["LPN-manager-gui"].children[2].children[1]
    local item_filter = value_from_element(parameter.children[2])
    local alert_label = parameter.children[9]
    local network = value_from_element(parameter.children[5])
    local sub_network = parameter.children[7].text
    local selected_tab_index = player.gui.screen["LPN-manager-gui"].children[2].children[2].selected_tab_index or 1
    if selected_tab_index == 1 then     --inventory tab
        inventory_tab.update_inventory_tab(player, item_filter, network, sub_network, selected_tab_index)
    elseif selected_tab_index == 2 then --platform_tab
        platform_tab.update_platform_tab(player, item_filter, network, sub_network, selected_tab_index, trigger)
    elseif selected_tab_index == 3 then --station_tab
        station_tab.update_platform_tab(player, item_filter, network, sub_network, selected_tab_index, trigger)
    elseif selected_tab_index == 4 and settings.global["LPN-show-debug-tab"].value then --debug_tab
        debug_tab.update_debug_tab(player, item_filter, network, sub_network, selected_tab_index, trigger)
    elseif selected_tab_index == 4 and not settings.global["LPN-show-debug-tab"].value then 
        player.gui.screen["LPN-manager-gui"].children[2].children[2].selected_tab_index=1
        --remote.call("LPN_remote","update_tab",player)
    end


    alert_label.caption = { "alert.no-alert" }
    alert_label.tooltip = nil
    if not settings.global["LPN-enable-dispatcher"].value then
        alert_label.caption = { "alert.dispatcher-disable" }
        alert_label.tooltip = { "alert.dispatcher-disable-tooltip" }
    else
        local alerts = player.get_alerts { type = defines.alert_type.custom, prototype = "ptflog-requester" }
        if alerts then
            for _, arr in pairs(alerts) do
                for id, alert in pairs(arr) do
                    if alert and next(alert) then
                        for _, data in pairs(alert) do
                            if data.target.name == "ptflog-requester" then
                                alert_label.caption = data.message
                                goto continue
                            end
                        end
                    end
                end
            end
        end
    end
    ::continue::
end

local function toogle_visibility(e)
    if not e.element then return end
    local name = e.element.name
    if name == "LPN-open-manager" or name == "LPN-button_close" or name == "LPN-manager-gui" then
        local player = game.players[e.player_index]
        if player then
            if player.gui.screen["LPN-manager-gui"] then
                player.gui.screen["LPN-manager-gui"].visible = not player.gui.screen["LPN-manager-gui"].visible
                if player.gui.screen["LPN-manager-gui"].visible then
                    player.opened = player.gui.screen["LPN-manager-gui"]
                    update_gui(player)
                    --update_general_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
                else
                    player.opened = nil
                end
            end
        end
    end
end

local function on_gui_closed(e)
    local element = e.element
    if element and element.valid then
        if element.name == "LPN-manager-gui" and element.visible then
            game.players[e.player_index].opened = nil
            toogle_visibility(e)
        end
    end
end

local function toogle_visibility_short(e)
    local name = e.prototype_name or e.input_name or nil
    if name == "toggle-LPN-MANAGER" then
        local event = {
            element = { name = "LPN-manager-gui" },
            player_index = e.player_index
        }
        toogle_visibility(event)
    end
end

local function open_migration(e)
     local player = game.players[e.player_index]
     if not player then return end
     local version=storage.version
     migration_gui.create_gui(player,version)
end

local function give_book(e)
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid then
        --stack.clear()
        player.clear_cursor()
        stack.import_stack(blueprint.book)
    end
end

local function update_trigger(e)
    local player = game.players[e.element.player_index]
    if not player then
        return
    end
    update_gui(player)
end

local function on_platform_sort_checkbox_changed(e)
    local player = game.players[e.element.player_index]
    if not player then return end

    update_gui(player, e.element.tags.trigger)
end

local function parameter(player)
    local bandeau = {
        type = "frame",
        style = "LPN_main_toolbar_frame",
        style_mods = { height = 45, vertical_align = "center", horizontally_stretchable = true, padding = 10 },
        direction = "horizontal",
        children = {
            {
                type = "label",
                caption = { "gui.lpnitem" },
                style = "heading_2_label",
            },
            {
                type = "choose-elem-button",
                elem_type = "signal",
                handler = { [defines.events.on_gui_elem_changed] = update_trigger },
            },
            {
                type = "empty-widget",
                style_mods = { width = 200 }
            },
            {
                type = "label",
                caption = { "gui.network" },
                style = "heading_2_label",
            },
            {
                type = "choose-elem-button",
                elem_type = "signal",
                tooltip = { "gui.LPN-network-tooltip" },
                handler = { [defines.events.on_gui_elem_changed] = update_trigger },
            },
            {
                type = "label",
                caption = { "gui.sub_network" },
                style = "heading_2_label",
            },
            {
                type = "textfield",
                numeric = true,
                allow_decimal = false,
                allow_negative = false,
                lose_focus_on_confirm = true,
            },
            {
                type = "label",
                caption = { "gui.alert" },
                style = "heading_2_label",
            },
            {
                type = "label",
                caption = "",
            },

        }
    }
    return bandeau
end

local function tabbed_pane(player)
    local tabbed = {
        type = "tabbed-pane",
        name = "general_flow",
        style = "LPN_tabbed_pane",
        style_mods = { horizontally_squashable = true, horizontally_stretchable = true, vertically_squashable = true, vertically_stretchable = true },
        handler = { [defines.events.on_gui_selected_tab_changed] = update_trigger },
        children = {
            {
                tab = {
                    type = "tab",
                    caption = { "gui.inventory" },
                    --style="LPN_tabbed_pane"
                },
                content = {
                    type = "flow",
                    style = "horizontal_flow",
                    style_mods = { horizontal_spacing = 12 },
                    direction = "horizontal",
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            style_mods = { height = 744, width = 492 },
                            children = {
                                {
                                    type = "label",
                                    caption = { "gui.lpnprovided" },
                                    style = "heading_2_label"
                                },
                                gui_util.make_slot_table(12)
                            }
                        },
                        {
                            type = "flow",
                            direction = "vertical",
                            style_mods = { height = 744, width = 332 },
                            children = {
                                {
                                    type = "label",
                                    caption = { "gui.in_transit" },
                                    style = "heading_2_label"
                                },
                                gui_util.make_slot_table(8)
                            }
                        },
                        {
                            type = "flow",
                            direction = "vertical",
                            style_mods = { height = 744, width = 332 },
                            children = {
                                {
                                    type = "label",
                                    caption = { "gui.lpnrequest" },
                                    style = "heading_2_label"
                                },
                                gui_util.make_slot_table(8)
                            }
                        }
                    }
                }
            },
            {
                tab = {
                    type = "tab",
                    caption = { "platforms" },
                },
                content = {
                    type = "flow",
                    style = "horizontal_flow",
                    style_mods = { horizontal_spacing = 12 },
                    direction = "horizontal",
                    children = {
                        {
                            type = "frame",
                            style = "inside_deep_frame",
                            direction = "vertical",
                            children = {
                                {
                                    type = "frame",
                                    style = "LPN_table_toolbar_frame",
                                    direction = "horizontal",
                                    children = {
                                        gui_util.sort_checkbox(90, { "platforms" }, true, nil,
                                            on_platform_sort_checkbox_changed, "id"),
                                        gui_util.sort_checkbox(100, { "gui.network" }, true, nil,
                                            on_platform_sort_checkbox_changed, "network"),
                                        {
                                            type = "label",
                                            caption = { "gui.position" },
                                            style = "heading_2_label",
                                            style_mods = { width = 525 }
                                        }
                                        , {
                                        type = "label",
                                        caption = { "gui.shipment" },
                                        style = "heading_2_label"
                                    }

                                    }
                                },
                                {
                                    type = "scroll-pane",
                                    direction = "vertical",
                                    style_mods = { horizontally_squashable = true, horizontally_stretchable = true, vertically_squashable = true, vertically_stretchable = true },
                                    style = "LPN_table_scroll_pane",
                                    children = {}
                                }
                            }
                        }
                    }
                },
            },
            {
                tab = {
                    type = "tab",
                    caption = { "gui.stations" },
                },
                content = {
                    type = "flow",
                    style = "horizontal_flow",
                    style_mods = { horizontal_spacing = 12 },
                    direction = "horizontal",
                    children = {
                        {
                            type = "frame",
                            style = "inside_deep_frame",
                            direction = "vertical",
                            children = {
                                {
                                    type = "frame",
                                    style = "LPN_table_toolbar_frame",
                                    direction = "horizontal",
                                    children = {
                                        gui_util.sort_checkbox(230, { "gui.stations" }, true, nil,
                                            on_platform_sort_checkbox_changed, "id"),
                                        gui_util.sort_checkbox(100, { "gui.network" }, true, nil,
                                            on_platform_sort_checkbox_changed, "network"),
                                        {
                                            type = "label",
                                            caption = { "gui.provided-requested" },
                                            style = "heading_2_label",
                                            style_mods = { width = 250 }
                                        }
                                        , {
                                        type = "label",
                                        caption = { "gui.shipment" },
                                        style = "heading_2_label",
                                        style_mods = { width = 250 }
                                    },
                                        {
                                            type = "label",
                                            caption = { "gui.control" },
                                            style = "heading_2_label",
                                            style_mods = { width = 250 }
                                        }
                                    }
                                },
                                {
                                    type = "scroll-pane",
                                    direction = "vertical",
                                    style_mods = { horizontally_squashable = true, horizontally_stretchable = true, vertically_squashable = true, vertically_stretchable = true },
                                    style = "LPN_table_scroll_pane",
                                    children = {}
                                }
                            }
                        }
                    }
                },
            },
        }
    }
    return tabbed
end


local function create_lpn_manager_gui(player)
    if player.gui.screen["LPN-manager-gui"] then
        player.gui.screen["LPN-manager-gui"].destroy()
    end
    local lpn_manager = gui.add(player.gui.screen,
        {
            type = "frame",
            name = "LPN-manager-gui",
            direction = "vertical",
            visible = false,
            style_mods = {
                size = { 1228, 920 }
            },
            handler = { [defines.events.on_gui_closed] = on_gui_closed },
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
                            caption = { "gui.manager" },
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
                            sprite = "LPN-migration-version",
                            name = "LPN-show-migration_gui",
                            tooltip = { "gui.migration_tooltip" },
                            handler = { [defines.events.on_gui_click] = open_migration },
                        },
                        {
                            type = "sprite-button",
                            style = "frame_action_button",
                            sprite = "LPN-book",
                            name = "LPN-button_give_book",
                            tooltip = { "gui.book" },
                            handler = { [defines.events.on_gui_click] = give_book },
                        },
                        {
                            type = "sprite-button",
                            style = "frame_action_button",
                            sprite = "utility/close",
                            name = "LPN-button_close",
                            hovered_sprite = "utility/close",
                            clicked_sprite = "utility/close",
                            tooltip = { "gui.close-instruction" },
                            handler = { [defines.events.on_gui_click] = toogle_visibility },
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
                        parameter(player),
                        tabbed_pane(player)
                    }
                }

            }
        })

    --update_general_flow(lpn_manager["general_flow"])
    lpn_manager.titlebar.drag_target = lpn_manager["LPN-manager-gui"]
    lpn_manager["LPN-manager-gui"].force_auto_center()
    --player.opened = lpnager["LPN-manager-gui"]
end

function LPN_gui_manager.rebuild()
    for _, player in pairs(game.players) do
        if player.gui.screen["LPN-manager-gui"] then
            create_lpn_manager_gui(player)
        end
    end
    if settings.global["LPN-show-debug-tab"].value then
        debug_tab.create_content_tab()
    end
    game.print("LOGISTIC PLANET NETWORK : LPN GUI MANAGER REBUILT")
end

function LPN_gui_manager.update(player)
    update_gui(player)
end

function LPN_gui_manager.add_button_manager(player)
    local flow = mod_gui.get_button_flow(player)
    if flow then
        if not flow["LPN-open-manager"] then
            local button = gui.add(mod_gui.get_button_flow(player), {
                {
                    type = "sprite-button",
                    style = "frame_action_button",
                    sprite = "LPN-manager-white",
                    style_mods = { size = { 37, 37 } },
                    name = "LPN-open-manager",
                    tooltip = { "gui.open-lpn-gui-manager" },
                    handler = { [defines.events.on_gui_click] = toogle_visibility },
                },
            })
        end
        create_lpn_manager_gui(player)
    end
end

function LPN_gui_manager.updateP()
    for _, player in pairs(game.players) do
        if player.gui.screen["LPN-manager-gui"] then
            if player.gui.screen["LPN-manager-gui"].visible then
                update_gui(player)
            end
        end
    end
end

local function on_runtime_mod_setting_changed(e)
    if e.setting_type=="runtime-global" then
        if e.setting=="LPN-show-debug-tab" then
            if settings.global["LPN-show-debug-tab"].value then
                debug_tab.create_content_tab()
            else
                debug_tab.remove()
            end
            LPN_gui_manager.updateP()
        end
    end
end

LPN_gui_manager.events = {
    [defines.events.on_gui_closed] = on_gui_closed,
    [defines.events.on_lua_shortcut] = toogle_visibility_short,
    ["toggle-LPN-MANAGER"] = toogle_visibility_short,
    [defines.events.on_runtime_mod_setting_changed]=on_runtime_mod_setting_changed
}

gui.add_handlers({
    toogle_visibility = toogle_visibility,
    open_migration=open_migration,
    give_book = give_book,
    update_trigger = update_trigger,
    on_platform_sort_checkbox_changed = on_platform_sort_checkbox_changed
})

if not remote.interfaces["LPN_remote"] then
    remote.add_interface("LPN_remote",
        {
            update_tab = function(player) update_gui(player) end,
            rebuild = function() LPN_gui_manager.rebuild() end,
        })
end
return LPN_gui_manager
