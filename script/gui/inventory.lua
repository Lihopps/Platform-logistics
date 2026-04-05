local util=require("script.util")
local gui_util=require("script.gui.gui-util")
local gui = require("__flib__.gui")

local LPN_gui_manager=package.loaded["__Platform-logistics__/script/gui/LPN_gui_manager.lua"]


local function on_button_slot_click(e)
    local parent=game.players[e.player_index].gui.screen["LPN-manager-gui"]
    local filter=parent.children[2].children[1].children[2]
    local item,qal = table.unpack(util.name_and_qual(e.element.tags.itemqal))
    filter.elem_value={
        type="item",
        name=item,
        quality=qal
    }
    if e.element.tags.type=="provider" or e.element.tags.type=="requester" then
        parent.children[2].children[2].selected_tab_index=3
    elseif e.element.tags.type=="transit" then
        parent.children[2].children[2].selected_tab_index=2
    end
    remote.call("LPN_remote","update_tab",game.players[e.player_index])
end


local inventory={}

function inventory.update_inventory_tab(player,item_filter,network,sub_network,selected_tab_index)
    local tab_content = player.gui.screen["LPN-manager-gui"].children[2].children[2].tabs[selected_tab_index].content
    local provider_table = tab_content.children[1].children[2].children[1].children[1]
    local transit_table = tab_content.children[2].children[2].children[1].children[1]
    local request_table = tab_content.children[3].children[2].children[1].children[1]

    provider_table.clear()
    transit_table.clear()
    request_table.clear()
    for itemqal, stations in pairs(storage.supplies) do
        if not item_filter or item_filter == itemqal then
            local item, quality = table.unpack(util.name_and_qual(itemqal))
            local total_available = 0
            local total_station = 0
            for station_id, station_data in pairs(stations) do
                if not network or (network == station_data.node.network and util.has_common_bits_from_string_32(sub_network, station_data.node.sub_network)) then
                    total_available = total_available + station_data.available
                    total_station = total_station + 1
                end
            end
            if total_available > 0 then
                gui.add(provider_table, gui_util.item_button("provider", item, quality, total_station, total_available,on_button_slot_click))
            end
        end
    end

    local temp_data = {}
    for id, platform in pairs(storage.platforms) do
        if platform.mission and (not network or (network == platform.network and util.has_common_bits_from_string_32(sub_network, platform.sub_network))) then
            for index, etape in pairs(platform.mission) do
                for _, station in pairs(etape[next(etape)]) do
                    if station.type == "provider" then
                        for itemqal, amount in pairs(station.item) do
                            if not item_filter or item_filter == itemqal then
                                if not temp_data[itemqal] then temp_data[itemqal] = {} end
                                temp_data[itemqal] = {
                                    total_station = 1 + (temp_data[itemqal].total_station or 0),
                                    total_available = amount + (temp_data[itemqal].total_available or 0)
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    for itemqal, data in pairs(temp_data) do
        local item, quality = table.unpack(util.name_and_qual(itemqal))
        gui.add(transit_table, gui_util.item_button("transit", item, quality, data.total_station, data.total_available,on_button_slot_click))
    end

    temp_data = {}
    for _, items_data in pairs(storage.requests) do
        if not item_filter or item_filter == items_data.item then
            if not network or (network == items_data.node.network and util.has_common_bits_from_string_32(sub_network, items_data.node.network.sub_network)) then
                if not temp_data[items_data.item] then temp_data[items_data.item] = {} end
                temp_data[items_data.item] = {
                    total_station = 1 + (temp_data[items_data.item].total_station or 0),
                    total_available = items_data.amount + (temp_data[items_data.item].total_available or 0)
                }
            end
        end
    end
    for itemqal, data in pairs(temp_data) do
        local item, quality = table.unpack(util.name_and_qual(itemqal))
        gui.add(request_table, gui_util.item_button("requester", item, quality, data.total_station, -data
        .total_available,on_button_slot_click))
    end
    --game.print("c")
end


gui.add_handlers({
    on_button_slot_click=on_button_slot_click
})

return inventory