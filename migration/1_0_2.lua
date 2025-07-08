local network=require("script.network")
local v1_0_2={}

function v1_0_2.change()
    local oldptflogchannel=storage.ptflogchannel
    --helpers.write_file("test.text",helpers.table_to_json(oldptflogchannel))
    storage.ptflogchannel={}
    network.create_channel("DEFAULT")
    for entity_number,channel_name in pairs(storage.ptflogtracker) do
        network.create_channel(channel_name)
        if string.find(entity_number,"S",0,true) then
            --c'est une platform
            --c'est elle n'y est pas on rajoute
            if not storage.ptflogchannel[channel_name].platform[entity_number] then
                local index=tonumber(entity_number:sub(2))
                if game.surfaces[index] then
                    if game.surfaces[index].platform then
                        if game.surfaces[index].platform.valid then
                            storage.ptflogchannel[channel_name].platform[entity_number]=game.surfaces[index].platform
                        end
                    end
                end
            end
        else
            -- c'est un provider ou requester
            if game.get_entity_by_unit_number(entity_number).name=="ptflog-requester" then 
                if not storage.ptflogchannel[channel_name].building["ptflog-requester"][entity_number] then
                    storage.ptflogchannel[channel_name].building["ptflog-requester"][entity_number]={
                        incomming={}
                    }
                end
                for k,v in pairs(oldptflogchannel) do
                    for num,inc in pairs(v.building["ptflog-requester"]) do
                        if num==entity_number then
                            storage.ptflogchannel[channel_name].building["ptflog-requester"][entity_number].incomming=inc.incomming
                        end
                    end
                end
            elseif game.get_entity_by_unit_number(entity_number).name=="ptflog-provider"  then
                if not storage.ptflogchannel[channel_name].building["ptflog-provider"][entity_number] then
                    storage.ptflogchannel[channel_name].building["ptflog-provider"][entity_number]={
                        reserved={}
                    }
                end
                for k,v in pairs(oldptflogchannel) do
                    for num,res in pairs(v.building["ptflog-provider"]) do
                        if num==entity_number then
                            storage.ptflogchannel[channel_name].building["ptflog-provider"][entity_number].reserved=res.reserved
                        end
                    end
                end
            end
        end
    end
end

return v1_0_2