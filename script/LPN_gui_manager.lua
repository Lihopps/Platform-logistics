local mod_gui = require("__core__.lualib.mod-gui")
local gui = require("__flib__.gui")
local format = require("__flib__.format")
local util = require("script.util")
local blueprint = require("script.blueprint")



local margin = 3
local padding = 3

local LPN_gui_manager = {}

local function on_collapse_click(e)
    local requester = e.element.parent.parent
    if not requester then return end
    if not requester.valid then return end
    requester["requester_request_state_" .. e.element.tags["unit_number"]].visible = not requester
    ["requester_request_state_" .. e.element.tags["unit_number"]].visible
end

local function on_slider_rate_changed(e)
    local tags = e.element.tags
    if not tags then return end
    if not tags.channel or not tags.unit_number or not tags.item then return end
    storage.ptflogchannel[tags.channel].building["ptflog-requester"][tags.unit_number].incomming[tags.item].rate = e
    .element.slider_value
    e.element.parent["label_" .. tags.unit_number .. "_" .. tags.item].caption = (e.element.slider_value * 100) .. "%"
    e.element.parent["labelincomming_" .. tags.unit_number .. "_" .. tags.item].caption = "[< " ..
    format.number(e.element.slider_value * (tags.request or 0), true) .. "]"
end

local function reset_request(e)
    local channel = e.element.tags["channel"]
    local unit_number = e.element.tags["unit_number"]
    local item_and_qual = e.element.tags["item_and_qual"]
    storage.ptflogchannel[channel].building["ptflog-requester"][unit_number].incomming[item_and_qual] = nil
    LPN_gui_manager.update_manager__gen_gui()
    -- for k, player in pairs(game.players) do
    --     if player.gui.screen["LPN-manager-gui"] then
    --         if player.gui.screen["LPN-manager-gui"].visible then
    --             LPN_gui_manager.update_general_flow(player)
    --         end
    --     end
    -- end
end

local function on_view_requester(e)
    local unit_number = e.element.tags["unit_number"]
    local player = game.players[e.player_index]
    if player and player.valid and unit_number then
        local entity = game.get_entity_by_unit_number(unit_number)
        if entity and entity.valid then
            player.centered_on = entity
        end
    end
end


local function get_platform_name(hub_number)
    local entity = game.get_entity_by_unit_number(hub_number)
    if entity and entity.valid then
        local platform = entity.surface.platform
        if platform and platform.valid then
            return platform.name
        end
    end
    return "name-error"
end

local function incoming_platform(unit_number, item, channel)
    local platform_button = {}
    if storage.ptflogchannel[channel].building["ptflog-requester"][unit_number].incomming[item].platform then
        for punit_number, _ in pairs(storage.ptflogchannel[channel].building["ptflog-requester"][unit_number].incomming[item].platform) do
            table.insert(platform_button, {
                type = "sprite-button",
                style = "frame_action_button",
                style_mods = { margin = 3, size = { 26, 26 } },
                sprite = "LPN-ship-white",
                name = punit_number,
                tags = { unit_number = punit_number },
                tooltip = { "gui.see-platform", get_platform_name(punit_number) },
                handler = { [defines.events.on_gui_click] = on_view_requester },
            })
        end
    end
    return platform_button
end

local function reset_reserved(e)
    local channel = e.element.tags["channel"]
    local unit_number = e.element.tags["unit_number"]
    local item_and_qual = e.element.tags["item_and_qual"]
    storage.ptflogchannel[channel].building["ptflog-provider"][unit_number].reserved[item_and_qual] = nil
    LPN_gui_manager.update_manager__gen_gui()
    -- for k, player in pairs(game.players) do
    --     if player.gui.screen["LPN-manager-gui"] then
    --         if player.gui.screen["LPN-manager-gui"].visible then
    --             LPN_gui_manager.update_general_flow(player)
    --         end
    --     end
    -- end
end

local function create_provide_table(entity)
    local table1 = {
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.item" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-item-prov" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.reserved" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-reserved" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.delete-reserved" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-delete-reserved" }
        }
    }
    local channel = storage.ptflogtracker[entity.unit_number]
    for item, item_data in pairs(storage.ptflogchannel[channel].building["ptflog-provider"][entity.unit_number].reserved) do
        local name_and_qual = util.split(item, "_")
        local reserved = (item_data.quantity or 0)
        table.insert(table1, {
            type = "label",
            style_mods = { vertical_align = "center", margin = margin, padding = padding },
            caption = "[item=" .. name_and_qual[1] .. ",quality=" .. name_and_qual[2] .. "]",
            elem_tooltip = { type = "item", name = name_and_qual[1] },
            --tooltip = name_and_qual[1]
        })
        table.insert(table1, {
            type = "label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            vertical_align = "center",
            caption = format.number(reserved, true),
            tooltip = reserved
        })
        table.insert(table1, {
            type = "button",
            --style = "frame_action_button",
            style_mods = { margin = 3 },
            caption = { "gui.delete-reserved" },
            tooltip = { "gui.tooltip-delete-reserved" },
            tags = { channel = channel, unit_number = entity.unit_number, item_and_qual = item },
            handler = { [defines.events.on_gui_click] = reset_reserved }
        })
    end
    return table1
end

local function create_request_table(entity)
    local table1 = {
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.item" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-item" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.request" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-request" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.stock" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-stock" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.incoming" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-incoming" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.delta" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-delta" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.rate" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-rate" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.platform-incoming" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-platform-incoming" }
        },
        {
            type = "label",
            style = "subheader_caption_label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = { "", { "gui.delete-request" }, "[virtual-signal=signal-info]" },
            tooltip = { "gui.tooltip-delete-request" }
        }
    }
    local channel = storage.ptflogtracker[entity.unit_number]
    for item, item_data in pairs(storage.ptflogchannel[channel].building["ptflog-requester"][entity.unit_number].incomming) do
        local name_and_qual = util.split(item, "_")
        local request = (item_data.request or 0)
        local stock = (item_data.stock or 0)
        local incoming = (item_data.quantity or 0)
        local delta = request - stock - incoming
        local rate = (item_data.rate or 0.5)
        if delta < 0 then delta = 0 end
        table.insert(table1, {
            type = "label",
            style_mods = { vertical_align = "center", margin = margin, padding = padding },
            caption = "[item=" .. name_and_qual[1] .. ",quality=" .. name_and_qual[2] .. "]",
            elem_tooltip = { type = "item", name = name_and_qual[1] },
            --tooltip = name_and_qual[1]
        })
        table.insert(table1, {
            type = "label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            vertical_align = "center",
            caption = format.number(request, true),
            tooltip = request
        })
        table.insert(table1, {
            type = "label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = format.number(stock, true),
            tooltip = stock
        })
        table.insert(table1, {
            type = "label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = format.number(incoming, true),
            tooltip = incoming
        })
        table.insert(table1, {
            type = "label",
            style_mods = { horizontal_align = "center", margin = margin, padding = padding },
            caption = format.number(delta, true),
            tooltip = delta
        })
        table.insert(table1, {
            type = "flow",
            direction = "horizontal",
            children = {
                {
                    type = "slider",
                    style = "notched_slider",
                    style_mods = { horizontal_align = "center", margin = margin, padding = padding },
                    minimum_value = 0.1,
                    maximum_value = 1,
                    value_step = 0.1,
                    value = rate,
                    caption = "test",
                    tags = { unit_number = entity.unit_number, channel = channel, item = item, request = request or 0 },
                    handler = { [defines.events.on_gui_value_changed] = on_slider_rate_changed },
                },
                {
                    type = "label",
                    name = "label_" .. entity.unit_number .. "_" .. item,
                    caption = (rate * 100) .. "%"
                },
                {
                    type = "label",
                    name = "labelincomming_" .. entity.unit_number .. "_" .. item,
                    caption = "[< " .. format.number(rate * request, true) .. "]",
                    tooltip = { "gui.stock_inferior" }
                }
            }
        })
        table.insert(table1, {
            type = "flow",
            direction = "horizontal",
            children = incoming_platform(entity.unit_number, item, channel)
        })
        table.insert(table1, {
            type = "button",
            --style = "frame_action_button",
            style_mods = { margin = 3 },
            caption = { "gui.delete-request" },
            tooltip = { "gui.tooltip-delete-request" },
            tags = { channel = channel, unit_number = entity.unit_number, item_and_qual = item },
            handler = { [defines.events.on_gui_click] = reset_request }
        })
    end

    return table1
end

local function update_request_flow(general_flow)
    local tab_index = general_flow.selected_tab_index
    if tab_index == nil then
        tab_index = 1
        general_flow.selected_tab_index = 1
    end
    for _, requester_gen_flow in pairs(general_flow.children[2 * tab_index].children) do
        local requester_request_table = requester_gen_flow.children[2]
        if not requester_request_table then return end
        if not requester_request_table.valid then return end
        if requester_request_table.visible then
            local entity = game.get_entity_by_unit_number(requester_request_table.tags.unit_number)
            if entity and entity.valid then
                if tab_index == 1 then
                    requester_request_table.clear()
                    gui.add(requester_request_table, create_request_table(entity))
                else
                    requester_request_table.clear()
                    gui.add(requester_request_table, create_provide_table(entity))
                end
            end
        end
    end
end

local function update_general_flow(general_flow)
    local channel = general_flow.parent["selection_flow"]["channel_selector"].items
        [general_flow.parent["selection_flow"]["channel_selector"].selected_index]
    general_flow.children[2].clear()
    general_flow.children[4].clear()
    local tab_index = general_flow.selected_tab_index
    if tab_index == nil then
        tab_index = 1
        general_flow.selected_tab_index = 1
    end
    if tab_index == 1 then
        local flows = {}
        for number, state in pairs(storage.ptflogchannel[channel].building["ptflog-requester"]) do
            local entity = game.get_entity_by_unit_number(number)
            if entity and entity.valid then
                local planet = entity.surface
                local flow_requester = {
                    type = "frame",
                    style = "inside_deep_frame",
                    direction = "vertical",
                    children = {
                        {
                            type = "flow",
                            name = "requester_state_" .. number,
                            direction = "horizontal",
                            style_mods = { vertical_align = "center", horizontally_stretchable = true, left_padding = 5, top_margin = 3, bottom_margin = 8 },
                            children = {
                                {
                                    type = "label",
                                    style_mods = { left_padding = 5, top_margin = 3, bottom_margin = 3 },
                                    caption = { "", "[planet=" .. planet.name .. "] ", { "gui.req-num" }, " ", number },
                                    tooltip = "[planet=" .. planet.name .. "]" .. planet.name
                                },
                                {
                                    type = "sprite-button",
                                    style = "frame_action_button",
                                    style_mods = { margin = 3 },
                                    sprite = "utility/search",
                                    name = "teleport_" .. number,
                                    tooltip = { "gui.see-requester" },
                                    tags = { unit_number = number },
                                    handler = { [defines.events.on_gui_click] = on_view_requester },
                                },
                                {
                                    type = "sprite-button",
                                    style = "frame_action_button",
                                    style_mods = { margin = 3 },
                                    sprite = "utility/dropdown",
                                    name = "collapse_" .. number,
                                    tooltip = { "gui.deploy" },
                                    auto_toggle = true,
                                    tags = { unit_number = number },
                                    handler = { [defines.events.on_gui_click] = on_collapse_click },
                                },
                            }
                        },
                        {
                            type = "table",
                            name = "requester_request_state_" .. number,
                            style = "table_with_selection",
                            visible = false,
                            style_mods = { margin = 5, horizontally_stretchable = true, horizontal_align = "center", },
                            column_count = 8,
                            tags = { unit_number = number },
                            children = create_request_table(entity)
                        }
                    }
                }
                table.insert(flows, flow_requester)
            end
        end
        gui.add(general_flow.children[2], flows)
    elseif tab_index == 2 then
        local flows = {}
        for number, state in pairs(storage.ptflogchannel[channel].building["ptflog-provider"]) do
            local entity = game.get_entity_by_unit_number(number)
            if entity and entity.valid then
                local planet = entity.surface
                local flow_requester = {
                    type = "frame",
                    style = "inside_deep_frame",
                    direction = "vertical",
                    children = {
                        {
                            type = "flow",
                            name = "requester_state_" .. number,
                            direction = "horizontal",
                            style_mods = { vertical_align = "center", horizontally_stretchable = true, left_padding = 5, top_margin = 3, bottom_margin = 8 },
                            children = {
                                {
                                    type = "label",
                                    style_mods = { left_padding = 5, top_margin = 3, bottom_margin = 3 },
                                    caption = { "", "[planet=" .. planet.name .. "] ", { "gui.prov-num" }, " ", number },
                                    tooltip = "[planet=" .. planet.name .. "]" .. planet.name
                                },
                                {
                                    type = "sprite-button",
                                    style = "frame_action_button",
                                    style_mods = { margin = 3 },
                                    sprite = "utility/search",
                                    name = "teleport_" .. number,
                                    tooltip = { "gui.see-provider" },
                                    tags = { unit_number = number },
                                    handler = { [defines.events.on_gui_click] = on_view_requester },
                                },
                                {
                                    type = "sprite-button",
                                    style = "frame_action_button",
                                    style_mods = { margin = 3 },
                                    sprite = "utility/dropdown",
                                    name = "collapse_" .. number,
                                    tooltip = { "gui.deploy" },
                                    auto_toggle = true,
                                    tags = { unit_number = number },
                                    handler = { [defines.events.on_gui_click] = on_collapse_click },
                                },
                            }
                        },
                        {
                            type = "table",
                            name = "requester_request_state_" .. number,
                            style = "table_with_selection",
                            style_mods = { margin = 5, horizontally_stretchable = true, horizontal_align = "center", },
                            visible = false,
                            column_count = 3,
                            tags = { unit_number = number },
                            children = create_provide_table(entity)
                        }
                    }
                }
                table.insert(flows, flow_requester)
            end
        end
        gui.add(general_flow.children[4], flows)
    end
    update_request_flow(general_flow)
end


local function update_channels()
    local items = {}
    for name, _ in pairs(storage.ptflogchannel) do
        table.insert(items, name)
    end
    return items
end

local function reset_network(e)
    local channel = e.element.parent["channel_selector"].items[e.element.parent["channel_selector"].selected_index]
    if storage.ptflogchannel[channel] then
        util.clear_network(channel, storage.ptflogchannel[channel], true)
    end
    LPN_gui_manager.update_manager__gen_gui()
    -- for k, player in pairs(game.players) do
    --     if player.gui.screen["LPN-manager-gui"] then
    --         if player.gui.screen["LPN-manager-gui"].visible then
    --             update_general_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
    --         end
    --     end
    -- end
end

local function channel_changed(e)
    update_general_flow(e.element.parent.parent["general_flow"])
end

local function update_manager_gui(e)
    if e.tick % 60 == 30 then
        for k, player in pairs(game.players) do
            if player.gui.screen["LPN-manager-gui"] then
                if player.gui.screen["LPN-manager-gui"].visible then
                    --update_general_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
                    update_request_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
                end
            end
        end
    end
end


function LPN_gui_manager.update_manager__gen_gui()
    --game.print("general update")
    for k, player in pairs(game.players) do
        --game.print(player.name)
        if player.gui.screen["LPN-manager-gui"] then
            if player.gui.screen["LPN-manager-gui"].visible then
                update_general_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
            end
        end
    end
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
                    update_general_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
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


local function give_book(e)
    local player = game.players[e.player_index]
    local stack = player.cursor_stack
    if stack and stack.valid then
        --stack.clear()
        player.clear_cursor()
        stack.import_stack(blueprint.book)
    end
end

local function tab_changed(e)
    local player = game.players[e.player_index]
    LPN_gui_manager.update_general_flow(player)
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
                size = { 1100, 700 }
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
                ---- flow de selection
                {
                    type = "flow",
                    direction = "horizontal",
                    name = "selection_flow",
                    children = {
                        {
                            type = "drop-down",
                            name = "channel_selector",
                            items = update_channels(),
                            selected_index = 1,
                            handler = { [defines.events.on_gui_selection_state_changed] = channel_changed },
                        },
                        {
                            type = "sprite-button",
                            style = "tool_button_red",
                            sprite = "utility/reset",
                            name = "LPN-reset_network",
                            tooltip = { "gui.reset-network" },
                            handler = { [defines.events.on_gui_click] = reset_network },
                        }
                    }
                },
                --- flow general
                {
                    type = "tabbed-pane",
                    name = "general_flow",
                    style_mods = { horizontally_squashable = true, horizontally_stretchable = true, vertically_squashable = true, vertically_stretchable = true },
                    handler = { [defines.events.on_gui_selected_tab_changed] = tab_changed },
                    children = {
                        {
                            tab = {
                                type = "tab",
                                caption = { "item-name.ptflog-requester" },
                                tooltip={"gui.requestertabdescription"}
                            },
                            content = {
                                type = "scroll-pane",
                                --style="entity_frame",
                                direction = "vertical",
                                children = {}
                            }
                        },
                        {
                            tab = {
                                type = "tab",
                                caption = { "item-name.ptflog-provider" },
                                tooltip={"gui.providertabdescription"}
                            },
                            content = {
                                type = "scroll-pane",
                                --style="entity_frame",
                                direction = "vertical",
                                children = {}
                            }
                        }
                    },
                }
            }
        })

    update_general_flow(lpn_manager["general_flow"])
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
    game.print("LOGISTIC PLANET NETWORK : LPN GUI MANAGER REBUILT")
end



function LPN_gui_manager.update_general_flow(player)
    update_general_flow(player.gui.screen["LPN-manager-gui"]["general_flow"])
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

function LPN_gui_manager.update_channels()
    for k, player in pairs(game.players) do
        if player.gui.screen["LPN-manager-gui"] then
            player.gui.screen["LPN-manager-gui"]["selection_flow"]["channel_selector"].items = update_channels()
        end
    end
end

LPN_gui_manager.events = {
    [defines.events.on_gui_closed] = on_gui_closed,
    [defines.events.on_tick] = update_manager_gui,
    [defines.events.on_lua_shortcut] = toogle_visibility_short,
    ["toggle-LPN-MANAGER"] = toogle_visibility_short,


}

gui.add_handlers({
    toogle_visibility = toogle_visibility,
    channel_changed = channel_changed,
    on_view_requester = on_view_requester,
    on_slider_rate_changed = on_slider_rate_changed,
    reset_network = reset_network,
    reset_request = reset_request,
    give_book = give_book,
    reset_reserved = reset_reserved,
    tab_changed = tab_changed,
    on_collapse_click = on_collapse_click
})

return LPN_gui_manager
