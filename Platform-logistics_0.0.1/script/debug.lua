local debug={}

function debug.network_request_state(network)
    for entity_number,state in pairs(network.building["ptflog-requester"]) do
        for item,_ in pairs(network.building["ptflog-requester"][entity_number].request) do
            local req=network.building["ptflog-requester"][entity_number].request[item]
            local income=network.building["ptflog-requester"][entity_number].incomming[item]
            game.print(item .." request : "..req.."/ incomming : "..income)
        end
    end
end


return debug