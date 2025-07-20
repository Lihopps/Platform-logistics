local gui = require("__flib__.gui")
local network_class = require("script.network")
local util=require("script.util")

local function on_gui_closed(e)
    local player = game.get_player(e.player_index)
    if not player then return end
    local refs= player.opened or e.element or nil
    if not refs then return end
    if refs.object_name=="LuaGuiElement" then
        if refs.name=="provider_channel" then
            refs.destroy()
            player.opened=nil
        end
    end
end

local function on_gui_closed_click(e)
    on_gui_closed(e)
end

local function update_channels()
    local items = { "NONE" }
    for name, _ in pairs(storage.ptflogchannel) do
        table.insert(items, name)
    end
    return items
end

local function get_current_channel(entity)
    local key = entity.unit_number
    if entity.type == "space-platform-hub" then
        key = "S" .. entity.surface.index
    end
    local channel = storage.ptflogtracker[key]
    if not channel then channel = "NONE" end
    return channel
end

local function get_index_channel(channels, current_channel)
    for k, v in ipairs(channels) do
        if v == current_channel then
            return k
        end
    end
    return 0
end

local function on_set_channel_clicked(e,chan)
    local channel = chan
    if not chan then
        channel=e.element.parent["selection_channel"].items[e.element.parent["selection_channel"].selected_index]
    end
    if channel==e.element.tags["current_channel"] then return end
    local entity = game.get_entity_by_unit_number(e.element.tags["unit_number"])
    if entity and entity.valid then
        local key = entity.unit_number
        if entity.name == "space-platform-hub" then
            key = "S" .. entity.surface.index
            if channel=="NONE" then
                storage.ptflogchannel[e.element.tags["current_channel"]].platform[key]=nil
                storage.ptflogtracker[key] = nil
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            elseif e.element.tags["current_channel"]=="NONE" then
                storage.ptflogchannel[channel].platform[key]=entity.surface.platform
                storage.ptflogtracker[key] = channel
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            else
                storage.ptflogchannel[e.element.tags["current_channel"]].platform[key]=nil
                storage.ptflogchannel[channel].platform[key]=entity.surface.platform
                storage.ptflogtracker[key] = channel
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            end

        elseif entity.name == "ptflog-requester" then
            if channel=="NONE" then
                storage.ptflogchannel[e.element.tags["current_channel"]].building["ptflog-requester"][key] = nil
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
                storage.ptflogtracker[key] = nil
            
            elseif e.element.tags["current_channel"]=="NONE" then
                storage.ptflogchannel[channel].building["ptflog-requester"][key]={
                    incomming={}
                }
                storage.ptflogtracker[key] = channel
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            
            else
                storage.ptflogchannel[channel].building["ptflog-requester"][key]=storage.ptflogchannel[e.element.tags["current_channel"]].building["ptflog-requester"][key]
                storage.ptflogchannel[e.element.tags["current_channel"]].building["ptflog-requester"][key] = nil
                storage.ptflogtracker[key] = channel
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            end
        elseif entity.name == "ptflog-provider" then
            if channel=="NONE" then
                storage.ptflogchannel[e.element.tags["current_channel"]].building["ptflog-provider"][key] = nil
                storage.ptflogtracker[key] = nil
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
                
            elseif e.element.tags["current_channel"]=="NONE" then
                storage.ptflogchannel[channel].building["ptflog-provider"][key]={
                    reserved={}
                }
                storage.ptflogtracker[key] = channel
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            
            else
                storage.ptflogchannel[channel].building["ptflog-provider"][key]=storage.ptflogchannel[e.element.tags["current_channel"]].building["ptflog-provider"][key]
                storage.ptflogchannel[e.element.tags["current_channel"]].building["ptflog-provider"][key] = nil
                storage.ptflogtracker[key] = channel
                e.element.tags={ unit_number = entity.unit_number, current_channel = channel}
            end
        end
        if not chan then
            e.element.parent.parent["definition_flow"]["channel_label"].caption = "Current channel : " .. channel
        
        --besoin de reconstruire le bouton je sais pas pourquoi...
        --mais on le fait pas si c'est copié collé (le chan est présent que si copy paste)
        local parent=e.element.parent
        e.element.destroy()
        gui.add(parent,{
                        type = "sprite-button",
                        style = "item_and_count_select_confirm",
                        sprite = "utility/check_mark",
                        tooltip={"gui.set-channel"},
                        tags = { unit_number = entity.unit_number, current_channel = channel },
                        handler = { [defines.events.on_gui_click] = on_set_channel_clicked },
                    })
        
        end

        
        
        
    end
end

local function on_create_clicked(e)
    if e.element.parent["new_channel_name"].text ~= "" then
        network_class.create_channel(e.element.parent["new_channel_name"].text)
        game.print("New channel created : " .. e.element.parent["new_channel_name"].text)
        e.element.parent.parent["selection_flow"]["selection_channel"].items = update_channels()
    end
    --network_class.create_channel(e.element.text)
end

local function create_gui_base(entity, player)
    local channels = update_channels()
    local current_channel = get_current_channel(entity)
    local index_channel = get_index_channel(channels, current_channel)
    local child = {
        type = "flow",
        direction = "vertical",
        children = {
            --current
            {
                type = "flow",
                direction = "horizontal",
                name = "definition_flow",
                children = {
                    {
                        type = "label",
                        name = "channel_label",
                        caption = {"",{"gui.current-channel"},current_channel}
                    }
                }
            },
            {
                type = "line",
                direction = "horizontal"
            },
            --selection vation,erase
            {
                type = "flow",
                direction = "horizontal",
                name = "selection_flow",
                children = {
                    {
                        type = "drop-down",
                        name = "selection_channel",
                        selected_index = index_channel,
                        items = channels
                    },
                    {
                        type = "sprite-button",
                        style = "item_and_count_select_confirm",
                        sprite = "utility/check_mark",
                        tooltip={"gui.set-channel"},
                        tags = { unit_number = entity.unit_number, current_channel = current_channel },
                        handler = { [defines.events.on_gui_click] = on_set_channel_clicked },
                    }
                }
            },
            {
                type = "line",
                direction = "horizontal"
            },
            --create new
            {
                type = "flow",
                direction = "horizontal",
                name = "create_flow",
                children = {
                    {
                        type = "textfield",
                        rich_text_setting = "enabled",
                        name = "new_channel_name",
                        icon_selector = true
                    },
                    {
                        type = "sprite-button",
                        style = "item_and_count_select_confirm",
                        sprite = "utility/add",
                        tooltip = {"gui.create-channel"},
                        handler = { [defines.events.on_gui_click] = on_create_clicked },
                    }
                }
            }
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
                        caption = {"gui.lpnchannelselector"},
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
            create_gui_base(entity, player)
        }
    })
    prov.titlebar.drag_target = prov.provider_channel
    prov.provider_channel.force_auto_center()
    player.opened = prov.provider_channel
end

local function on_gui_switch_state_changed(e)
    if not e.element or not e.element.valid then return end
    if e.element.name=="lpnplatformstate" then
        storage.ptflogfilter[e.element.tags.unit_number].state=e.element.switch_state
    end
end

local function filter_gui(unit_number)
    if not storage.ptflogfilter[unit_number] then
        storage.ptflogfilter[unit_number]={state="right",filter={}} -- left = allowed /right disallowed
    end
    local entity_data=storage.ptflogfilter[unit_number]
    local filtergui={
        type = "flow",
        name="filter_frame_"..unit_number,
        direction="vertical",
        children={
            {
                type="switch",
                name="lpnplatformstate",
                switch_state=entity_data.state,
                allow_none_state=false,
                left_label_caption={"gui.left_label"},
                right_label_caption={"gui.right_label"},
                tags={unit_number=unit_number},
                handler = { [defines.events.on_gui_switch_state_changed] = on_gui_switch_state_changed },
            },
            {
                type="table",
                style="slot_table",
                column_count=5,
                children={}
            }
        }
    }
    for k,v in pairs(entity_data.filter) do
        table.insert(filtergui.children[2].children,{
            type="choose-elem-button",
            style="slot_button",
            elem_type="space-location",
            name="lpnfilterbutton_"..k,
            ["space-location"]=k,
            tags={unit_number=unit_number,location=k},
            handler = { [defines.events.on_gui_elem_changed] = on_gui_elem_changed },
        })
    end
    table.insert(filtergui.children[2].children,{
            type="choose-elem-button",
            elem_type="space-location",
            style="slot_button",
            name="lpnfilterbutton",
            tags={unit_number=unit_number,location="chooser"},
            handler = { [defines.events.on_gui_elem_changed] = on_gui_elem_changed },
        })
    return filtergui
end

local function on_gui_elem_changed(e)
    if not e.element or not e.element.valid then return end
    if string.find(e.element.name,"lpnfilterbutton_",0,true) then
        if not storage.ptflogfilter[e.element.tags.unit_number].filter[e.element.elem_value] then
            storage.ptflogfilter[e.element.tags.unit_number].filter[e.element.tags.location]=nil
            if e.element.elem_value then
                storage.ptflogfilter[e.element.tags.unit_number].filter[e.element.elem_value]=true
            end
            e.element.destroy()
        else
            util.create_flying_text(game.players[e.player_index],{"gui.alreadypresent"},nil,true)
            e.element.elem_value=e.element.tags.location
        end
    elseif string.find(e.element.name,"lpnfilterbutton",0,true) then
        if not storage.ptflogfilter[e.element.tags.unit_number].filter[e.element.elem_value] then
            if e.element.elem_value then
                storage.ptflogfilter[e.element.tags.unit_number].filter[e.element.elem_value]=true
            end
            local unit_number= e.element.tags.unit_number
            local parent=e.element.parent.parent.parent
            e.element.parent.parent.destroy()
            gui.add(parent,filter_gui(unit_number))
        else
            util.create_flying_text(game.players[e.player_index],{"gui.alreadypresent"},nil,true)
            e.element.elem_value=nil
        end
    end
end


local function create_gui_sp(entity, player, def,spgui)
    if player.gui.relative["spaceplatformchannel"] then
        player.gui.relative["spaceplatformchannel"].destroy()
    end
    local platform =  {
        type = "frame",
        name = "spaceplatformchannel",
        caption = {"gui.lpnchannelselector"},
        anchor = {
            gui = def,
            position = defines.relative_gui_position.left,
            names = { "space-platform-hub", "ptflog-requester" }
        },
        direction = "vertical",
        children = { create_gui_base(entity, player) }
    }
    if spgui then
       table.insert(platform.children,{
                type = "line",
                direction = "horizontal"
            })
       table.insert(platform.children,filter_gui(entity.unit_number))
    end
    gui.add(player.gui.relative,platform)
end

local function on_gui_opened(e)
    if game.players[e.player_index].force.technologies["LPN-starter"].researched then
        if e.entity and e.entity.valid then
            if e.entity.name == "space-platform-hub" then
                create_gui_sp(e.entity, game.players[e.player_index], defines.relative_gui_type.space_platform_hub_gui,true)
            elseif e.entity.name == "ptflog-requester" then
                create_gui_sp(e.entity, game.players[e.player_index], defines.relative_gui_type.cargo_landing_pad_gui)
            elseif e.entity.name == "ptflog-provider" then
                create_gui_prov(e.entity, game.players[e.player_index])
            end
        end
    end
end

local function on_entity_settings_pasted(e)
    if e.source and e.source.valid and e.destination and e.destination.valid then
        if e.source.prototype.name=="space-platform-hub" and e.destination.prototype.name=="space-platform-hub" then
            if game.players[e.player_index] then
                if game.players[e.player_index].force.technologies["LPN-starter"].researched then
                    local new_channel=storage.ptflogtracker["S"..e.source.surface.index] or "NONE"
                    local event={
                        element={
                            tags={
                                current_channel=storage.ptflogtracker["S"..e.destination.surface.index] or "NONE",
                                unit_number=e.destination.unit_number
                            }
                        }
                    }
                    on_set_channel_clicked(event,new_channel)
                    
                    --copy filter settings
                    if not storage.ptflogfilter[e.source.unit_number] then
                        storage.ptflogfilter[e.source.unit_number]={state="right",filter={}}
                    end
                    storage.ptflogfilter[e.destination.unit_number]=storage.ptflogfilter[e.source.unit_number]


                end
            end
        end
    end
end

local LPN_gui = {}

LPN_gui.events = {
    [defines.events.on_gui_opened] = on_gui_opened,
    [defines.events.on_gui_closed] = on_gui_closed,
    [defines.events.on_entity_settings_pasted] = on_entity_settings_pasted,
    [defines.events.on_gui_elem_changed] = on_gui_elem_changed,
    [defines.events.on_gui_switch_state_changed] = on_gui_switch_state_changed 
}

gui.add_handlers({
    on_set_channel_clicked = on_set_channel_clicked,
    on_create_clicked = on_create_clicked,
    on_gui_closed_click = on_gui_closed_click,
})

return LPN_gui
