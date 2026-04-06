local gui = require("__flib__.gui")
local util = require("script.util")
local platform_manager = require("script.platform_manager")

local function on_gui_closed(e)
    local player = game.get_player(e.player_index)
    if not player then return end
    local refs = player.opened or e.element or nil
    if not refs then return end
    if refs.valid==false then return end
    if refs.object_name == "LuaGuiElement" then
        if refs.name == "provider_channel" then
            refs.destroy()
            player.opened = nil
        end
    end
end

local function on_gui_closed_click(e)
    on_gui_closed(e)
end

local function on_gui_text_changed(e)
    if not e.element or not e.element.valid then return end
    if e.element.name == "LPN_sub_network" then
        local unit_number = e.element.tags.unit_number
        local text = e.element.text
        if text == "" then
            text = "1"
        end
        if storage.platforms[unit_number] then
            storage.platforms[unit_number].sub_network = text
            return
        end
        if storage.request_nodes[unit_number] then
            storage.request_nodes[unit_number].sub_network = text
            return
        end
        if storage.supply_nodes[unit_number] then
            storage.supply_nodes[unit_number].sub_network = text
            return
        end
    end
end

local function on_gui_elem_changed(e)
    if not e.element or not e.element.valid then return end
    if e.element.name == "LPN_network_selector" then
        local unit_number = e.element.tags.unit_number
        if storage.platforms[unit_number] then
            storage.platforms[unit_number].network = e.element.elem_value.name ..
                "_" .. (e.element.elem_value.quality or "normal")
            return
        end
        if storage.request_nodes[unit_number] then
            storage.request_nodes[unit_number].network = e.element.elem_value.name ..
                "_" .. (e.element.elem_value.quality or "normal")
            return
        end
        if storage.supply_nodes[unit_number] then
            storage.supply_nodes[unit_number].network = e.element.elem_value.name ..
                "_" .. (e.element.elem_value.quality or "normal")
            return
        end
    end
end

local function create_gui_base(entity, player)
    local network = util.name_and_qual(util.get_network_from_unit_number(entity.unit_number))
    local sub_network = util.get_sub_network_from_unit_number(entity.unit_number)
    local child = {
        type = "flow",
        direction = "vertical",
        children = {
            --current
            {
                type = "flow",
                direction = "vertical",
                name = "definition_flow",
                children = {
                    {
                        type = "flow",
                        direction = "horizontal",
                        style_mods = { vertical_align = "center" },
                        children = {
                            {
                                type = "label",
                                style = "heading_2_label",
                                caption = { "gui.id" },
                                style_mods = { top_padding = 8 }
                            },
                            {
                                type = "label",
                                caption = entity.unit_number,
                                style_mods = { top_padding = 8 }
                            }
                        }
                    },
                    {
                        type = "line",
                        direction = "horizontal"
                    },
                    {
                        type = "label",
                        style = "heading_2_label",
                        caption = { "gui.network" },
                        style_mods = { top_padding = 8 }
                    },
                    {
                        type = "flow",
                        direction = "horizontal",
                        style_mods = { vertical_align = "center" },
                        children = {
                            {
                                type = "choose-elem-button",
                                elem_type = "signal",
                                name = "LPN_network_selector",
                                tags = { unit_number = entity.unit_number, name = entity.name },
                                signal = {
                                    type = "virtual",
                                    name = network[1],
                                    --quality = network[2]
                                },
                                tooltip = { "gui.LPN-network-tooltip" },
                                handler = { [defines.events.on_gui_elem_changed] = on_gui_elem_changed },
                            },
                            {
                                type = "textfield",
                                name = "LPN_sub_network",
                                numeric = true,
                                allow_decimal = false,
                                allow_negative = false,
                                lose_focus_on_confirm = true,
                                text = sub_network,
                                tags = { unit_number = entity.unit_number },
                                handler = { [defines.events.on_gui_text_changed] = on_gui_text_changed },
                            }
                        }
                    }
                }
            },
        }
    }
    return child
end

local function create_gui_prov(entity, player)
    if player.gui.screen["provider_channel"] then
        player.gui.screen["provider_channel"].destroy()
    end
    local prov = gui.add(player.gui.screen, {
        type = "frame",
        name = "provider_channel",
        direction = "vertical",
        handler = { [defines.events.on_gui_closed] = on_gui_closed },
        children = {
            {
                type = "flow",
                style_mods = { horizontally_squashable = true },
                name = "titlebar",
                children = {
                    {
                        type = "label",
                        style = "subheader_caption_label",
                        rich_text_setting = "enabled",
                        caption = { "gui.lpnchannelselector" },
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
                        name = "button_close",
                        hovered_sprite = "utility/close",
                        clicked_sprite = "utility/close",
                        tooltip = { "gui.close-instruction" },
                        handler = { [defines.events.on_gui_click] = on_gui_closed_click },
                    },
                },
            },
            {

                type = "frame",
                style = "entity_frame",
                direction = "vertical",
                children = {
                    {
                        type = "frame",
                        style = "deep_frame_in_shallow_frame",
                        style_mods = {
                            minimal_width = 0,
                            horizontally_stretchable = true,
                            padding = 0,
                        },
                        children =
                        {
                            type = "entity-preview",
                            name = "preview",
                            style = "wide_entity_button",
                            style_mods = { height = 152, width = 354 }
                        }
                    },
                    create_gui_base(entity, player)
                }

            }

        }
    })
    prov.preview.entity = entity
    prov.titlebar.drag_target = prov.provider_channel
    prov.provider_channel.force_auto_center()
    player.opened = prov.provider_channel
end

local function on_gui_switch_state_changed(e)
    if not e.element or not e.element.valid then return end
    if e.element.name == "lpnplatformstate" then
        if e.element.switch_state == "left" then
            local network = e.element.parent.parent.children[1].children[1].children[2].children[1]
            network = network.elem_value.name .. "_" .. (network.elem_value.quality or "normal")
            local sub_network = e.element.parent.parent.children[1].children[1].children[2].children[2]
            sub_network = sub_network.text
            storage.platforms[e.element.tags.unit_number] = {
                entity = game.get_entity_by_unit_number(e.element.tags.unit_number),
                state = "IDLE",
                network = network,
                sub_network = sub_network,
                mission_index = -1
            }
            storage.platforms[e.element.tags.unit_number].entity.surface.platform.get_schedule().clear_records()
            storage.platforms[e.element.tags.unit_number].entity.force.print({ "gui.new_platform", storage.platforms
                [e.element.tags.unit_number].entity.surface.platform.name })
        else
            storage.platforms[e.element.tags.unit_number].entity.force.print({ "gui.platform_removed", storage.platforms
                [e.element.tags.unit_number].entity.surface.platform.name })
            storage.platforms[e.element.tags.unit_number].entity.surface.platform.get_schedule().clear_records()
            platform_manager.platform_out_of_network(storage.platforms[e.element.tags.unit_number])
            storage.platforms[e.element.tags.unit_number] = nil
        end
    end
end

local function filter_gui(unit_number)
    local state = "right"
    if storage.platforms[unit_number] then
        state = "left" -- left = allowed /right disallowed
    end

    local filtergui = {
        type = "flow",
        name = "filter_frame_" .. unit_number,
        direction = "vertical",
        children = {
            {

                type = "label",
                style = "heading_2_label",
                caption = { "gui.in_network" },
                style_mods = { top_padding = 8 }

            },

            {
                type = "switch",
                name = "lpnplatformstate",
                switch_state = state,
                allow_none_state = false,
                left_label_caption = { "gui.lpnallowed" },
                left_label_tooltip = { "gui.lpnallowed_tooltip" },
                right_label_caption = { "gui.lpnnotallowed" },
                right_label_tooltip = { "gui.lpnnotallowed_tooltip" },
                tags = { unit_number = unit_number },
                handler = { [defines.events.on_gui_switch_state_changed] = on_gui_switch_state_changed },
            },

        }
    }

    return filtergui
end




local function create_gui_sp(entity, player, def, spgui)
    if player.gui.relative["spaceplatformchannel"] then
        player.gui.relative["spaceplatformchannel"].destroy()
    end
    local platform = {
        type = "frame",
        name = "spaceplatformchannel",
        caption = { "gui.lpnchannelselector" },
        anchor = {
            gui = def,
            position = defines.relative_gui_position.left,
            names = { "space-platform-hub", "ptflog-requester" }
        },
        direction = "vertical",
        children = {
            {
                type = "frame",
                style = "entity_frame",
                direction = "vertical",
                children = {
                    create_gui_base(entity, player)
                }
            }
        }
    }
    if spgui then
        table.insert(platform.children[1].children, {
            type = "line",
            direction = "horizontal"
        })
        table.insert(platform.children[1].children, filter_gui(entity.unit_number))
    end
    gui.add(player.gui.relative, platform)
end

local function on_gui_opened(e)
    if game.players[e.player_index].force.technologies["LPN-starter"].researched then
        if e.entity and e.entity.valid then
            if e.entity.name == "space-platform-hub" then
                create_gui_sp(e.entity, game.players[e.player_index], defines.relative_gui_type.space_platform_hub_gui,
                    true)
            elseif e.entity.name == "ptflog-requester" then
                create_gui_sp(e.entity, game.players[e.player_index], defines.relative_gui_type.cargo_landing_pad_gui)
            elseif e.entity.name == "ptflog-provider" then
                create_gui_prov(e.entity, game.players[e.player_index])
            end
        end
    end
end

local LPN_gui = {}

LPN_gui.events = {
    [defines.events.on_gui_opened] = on_gui_opened,
    [defines.events.on_gui_closed] = on_gui_closed,
    [defines.events.on_gui_switch_state_changed] = on_gui_switch_state_changed,
    [defines.events.on_gui_elem_changed] = on_gui_elem_changed,
    [defines.events.on_gui_text_changed] = on_gui_text_changed
}

gui.add_handlers({
    on_gui_closed_click = on_gui_closed_click,
})

return LPN_gui
