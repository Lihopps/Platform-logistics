local util = require("script.util")
local format = require("__flib__.format")
local gui = require("__flib__.gui")

local gui_util = {}

function gui_util.item_button(type, item, quality, total_station, total_available, handler,control)
    local style = "flib_slot_button_green"
    if type == "requester" then
        style = "flib_slot_button_red"
    elseif type == "transit" then
        style = "flib_slot_button_orange"
    elseif type == "default" then
        style = "flib_slot_button_default"
    end
    if not total_station then type = "LPN-nil" end
    local tooltip = nil
    local elem_tooltip = nil
    
    if control then
        tooltip = nil
        elem_tooltip = {
            type = prototypes.item[item] and "item-with-quality" or "signal",
            name = item,
            signal_type="virtual",
            quality=quality
        }
    else
        tooltip = {
        "",
        util.rich_text_from_itemqal(item, quality),
        " ", prototypes.item[item].localised_name, "\n",
        { "?",          { "", { "gui." .. type, tostring(total_station) }, "\n" }, "" },
        { "gui.amount", format.number(total_available) },
    }
        elem_tooltip = nil
    end

    local button = {
        type = "sprite-button",
        style_mods = { height = 40, width = 40 },
        style = style,
        sprite = prototypes.item[item] and "item."..item or "virtual-signal." .. item,
        quality = quality,
        tooltip = tooltip,
        elem_tooltip = elem_tooltip,
        enabled=handler and false or true,
        children = {
            {
                type = "label",
                style = "LPN_label_signal_count_inventory",
                ignored_by_interaction = true,
                caption = util.format_signal_count(total_available),
            },
            {
                type = "label",
                style = "LPN_label_train_count_inventory",
                ignored_by_interaction = true,
                caption = util.format_signal_count(total_station),
            },
        },
        handler = handler and { [defines.events.on_gui_click] = handler } or nil,
        tags = { itemqal = item .. "_" .. (quality or "normal"), type = type }
    }
    return button
end

function gui_util.make_slot_table(column, width, height)
    if not width then width = column * 40 + 12 end
    if not height then height = 1000 end
    local tab = {
        type = "frame",
        style = "LPN_table_inset_frame_dark",
        style_mods = { maximal_height = height },
        children =
        {
            type = "scroll-pane",
            direction = "vertical",
            style_mods = { width = width, maximal_height = height, horizontally_stretchable = true, vertically_stretchable = true }, --,horizontally_squashable = true,vertically_squashable = true },
            style = "LPN_slot_table_scroll_pane",
            vertical_scroll_policy = "auto-and-reserve-space",
            horizontal_scroll_policy = "never",
            children = {
                {
                    type = "table",
                    style = "slot_table",
                    column_count = column
                }
            }
        }
    }
    return tab
end

function gui_util.sprite_from_signal(signal)
    local signal, qal = table.unpack(util.name_and_qual(signal))
    return { "virtual-signal." .. signal, (qal or "normal") }
end

function gui_util.add_filter_to_table(filters, type, threshold, shipmentgui,handler,control)
    for _, filter in pairs(filters) do
        if next(filter) then
            if not threshold or filter.min > threshold then
                gui.add(shipmentgui.children[1].children[1],
                    gui_util.item_button(type or filter.type, filter.value.name, filter.value.quality, nil, filter.min,handler,control))
            end
        end
    end
end

function gui_util.platform_position(platform)
    if platform.space_connection then
        return { "", "[img=LPN-" .. platform.space_connection.from.name .. "_" .. platform.space_connection.to.name ..
        "]", "  ", { "space-connection-name", platform.space_connection.from.name, platform.space_connection.to.name } }
    elseif platform.space_location then
        return { "", "[space-location=" .. platform.space_location.name .. "]", "  ", { "space-location-name." .. platform.space_location.name } }
    end
end

function gui_util.sort_checkbox(widths, caption, selected, tooltip, handler, trigger)
    if selected == nil then
        selected = false
    end
    return {
        type = "checkbox",
        style = selected and "LPN_selected_sort_checkbox" or "LPN_sort_checkbox",
        style_mods = { width = widths, horizontally_stretchable = not widths },
        caption = caption,
        tooltip = tooltip,
        state = selected,
        handler = handler and { [defines.events.on_gui_checked_state_changed] = handler } or nil,
        tags = { trigger = trigger }
    }
end

return gui_util
