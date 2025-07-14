local LPN_GUI_MANAGER= require("script.LPN_gui_manager")
local v1_0_5={}


--regarde la cohérence entre le tracker et et le storage
function v1_0_5.change()
    for channel_name,channel in pairs(storage.ptflogchannel) do
        for ptflog,entity_list in pairs(channel.building) do
            for unit_number,inc in pairs(entity_list) do
                if not storage.ptflogtracker[unit_number] then
                    storage.ptflogchannel[channel_name].building[ptflog][unit_number]=nil
                else
                    if ptflog=="ptflog-requester" then
                        if not inc.incomming then
                            inc.incomming={}
                        end
                    elseif ptflog=="ptflog-provider" then
                         if not inc.reserved then
                            inc.reserved={}
                        end
                    end
                end
            end
        end
    end
    LPN_GUI_MANAGER.rebuild()
end

return v1_0_5