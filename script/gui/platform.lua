local gui_util=require("script.gui.gui-util")
local util=require("script.util")
local gui = require("__flib__.gui")


local function on_button_slot_shipment_platform_click(e)
    local parent=game.players[e.player_index].gui.screen["LPN-manager-gui"]
    local filter=parent.children[2].children[1].children[2]
    local item,qal = table.unpack(util.name_and_qual(e.element.tags.itemqal))
    filter.elem_value={
        type="item",
        name=item,
        quality=qal
    }
   
    parent.children[2].children[2].selected_tab_index=3
    remote.call("LPN_remote","update_tab",game.players[e.player_index])
end

local function on_minimap_click(e)
    local id = e.element.tags.platform_id
    local entity=game.get_entity_by_unit_number(id)
    --open on map
    if e.shift then
        game.players[e.player_index].gui.screen["LPN-manager-gui"].visible=false
        game.players[e.player_index].opened=nil
        game.players[e.player_index].centered_on=entity
        return
    end

    --open gui
    game.players[e.player_index].gui.screen["LPN-manager-gui"].visible=false
    game.players[e.player_index].opened=entity     
end

local platform_gui = {}

function platform_gui.update_platform_tab(player,item_filter,network,sub_network,selected_tab_index,trigger)
    local tab_content = player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index]
        .content
    local toolbar = tab_content.children[1].children[1]
    local scroll = tab_content.children[1].children[2]
    scroll.clear()
    local idx = 0
    local plat_unit = {}
    for key, _ in pairs(storage.platforms) do
        table.insert(plat_unit, key)
    end
    local trigger_update = trigger or (toolbar.tags.trigger or "id")
    toolbar.tags = { trigger = trigger_update }
    table.sort(plat_unit, function(a, b)
        local by_number = toolbar.children[1].state
        local by_network = toolbar.children[2].state
        local plat_a = storage.platforms[a]
        local plat_b = storage.platforms[b]
        if trigger_update == "id" then
            if by_number then
                return a < b
            else
                return a > b
            end
        elseif trigger_update == "network" then
            if by_network then
                return plat_a.network..plat_a.sub_network < plat_b.network..plat_b.sub_network
            else
                return plat_a.network..plat_a.sub_network > plat_b.network..plat_b.sub_network
            end
        end
    end)
    for _, id in pairs(plat_unit) do
        local platform = storage.platforms[id]
        local section_name = "LPN : Platform n°: " .. platform.entity.surface.index
        local section_index = util.get_logistic_section_by_name(platform.entity, section_name)
        local filters = platform.entity.get_logistic_sections().get_section(section_index).filters
        local state = platform.state
        local as_itemqal = util.itemqal_in_filters(item_filter, filters)
        if (not network or (network == platform.network and util.has_common_bits_from_string_32(sub_network, platform.sub_network))) and (as_itemqal) then
            local color = idx % 2 == 0 and "light" or "dark"
            local elem_tooltip=nil
            if platform.entity.surface.platform.space_location then
                elem_tooltip={
                            type="space-location",
                            name=platform.entity.surface.platform.space_location.name 
                        }
            end
            local flow = {
                type = "frame",
                direction = "horizontal",
                style = "LPN_table_row_frame_" .. color,
                style_mods = { height = 122, width = 1165 },
                children = {
                    {
                        type = "minimap",
                        name = "platform_minimap",
                        style = "LPN_train_minimap",
                        style_mods={vertical_align="center",horizontal_align="center"},
                        { type = "label", style = "LPN_minimap_label", caption = platform.entity.surface.platform.name },
                        {
                            type = "button",
                            style = "LPN_train_minimap_button",
                            tooltip = { "gui.open-hub-gui" },
                            tags = { platform_id = id },
                            handler ={ [defines.events.on_gui_click] = on_minimap_click }, 
                        },
                    },
                    {
                        type = "flow",
                        direction = "horizontal",
                        style_mods = { width = 100 },
                        {
                            type = "sprite-button",
                            style = "flib_slot_button_default",
                            enabled = true,
                            ignored_by_interaction = true,
                            sprite = gui_util.sprite_from_signal(platform.network)[1],
                            quality = gui_util.sprite_from_signal(platform.network)[2],
                            number = platform.sub_network,
                        }
                    },
                    {
                        type = "label",
                        style_mods = { width = 525,height=110, vertical_align = "center", horizontally_stretchable = true, horizontally_squashable = true },
                        style = "LPN_label_position",
                        caption = gui_util.platform_position(platform.entity.surface.platform),
                        elem_tooltip=elem_tooltip
                    },
                    gui_util.make_slot_table(10)
                },
            }


            gui.add(scroll, flow)
            idx = idx + 1
            player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content.children[1].children[2].children[idx].children[1].entity =
            platform.entity
            gui_util.add_filter_to_table(filters,"default",0,player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content.children[1].children[2].children[idx].children[4],on_button_slot_shipment_platform_click)
        end
    end
end

gui.add_handlers({
    on_minimap_click=on_minimap_click,
    on_button_slot_shipment_platform_click=on_button_slot_shipment_platform_click
})

return platform_gui
