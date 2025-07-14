local LPN_GUI_MANAGER= require("script.LPN_gui_manager")
local v1_0_4={}


--regarde la coérence entre le tracker et et le storage
function v1_0_4.change()
    for channel_name,channel in pairs(storage.ptflogchannel) do
        for ptflog,entity_list in pairs(channel.building) do
            for unit_number,inc in pairs(entity_list) do
                if not storage.ptflogtracker[unit_number] then
                    storage.ptflogchannel[channel_name].building[ptflog][unit_number]=nil
                end
            end
        end
    end
    LPN_GUI_MANAGER.rebuild()
end

return v1_0_4