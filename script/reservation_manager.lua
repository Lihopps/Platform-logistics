local reservation = {}

function reservation.reserve_supply(node_id, amount,itemqal)

    if storage.reservations[node_id] == nil then
        storage.reservations[node_id]={}
    end
    if storage.reservations[node_id][itemqal] == nil then
        storage.reservations[node_id][itemqal]=0
    end

    storage.reservations[node_id][itemqal]= storage.reservations[node_id][itemqal] + amount

end

function reservation.reserve_request(node_id, amount,itemqal)

    if storage.request_reservations[node_id] == nil then
        storage.request_reservations[node_id] = {}
    end
    if storage.request_reservations[node_id][itemqal] == nil then
        storage.request_reservations[node_id][itemqal] = 0
    end

    storage.request_reservations[node_id][itemqal] =
        storage.request_reservations[node_id][itemqal] + amount

end

function reservation.get_supply_reserved(node_id,itemqal)
    if not storage.reservations[node_id] then
        storage.reservations[node_id]={}
    end
    return storage.reservations[node_id][itemqal] or 0

end

function reservation.get_request_reserved(node_id,itemqal)
    if not storage.request_reservations[node_id] then
        storage.request_reservations[node_id]={}
    end
    return storage.request_reservations[node_id][itemqal] or 0

end

--- release supply reservation
---@param station_data any a node
---@param item string item name
---@param amount number quantity
function reservation.release_supply(station_data,item,amount)
    local res=storage.reservations[station_data.station.id]
    if not res then return end
    res=res[item]
    if not res then return end
    storage.reservations[station_data.station.id][item]=math.max(0,storage.reservations[station_data.station.id][item]-amount)
end

--- release request supply reservation
---@param station_data any a node
---@param item string item name
---@param amount number quantity
function reservation.release_request_supply(station_data,item,amount)
    local unit_number=station_data.station.unit_number or station_data.station.id
    local res=storage.request_reservations[unit_number]
    if not res then return end
    res=res[item]
    if not res then return end
    storage.request_reservations[unit_number][item]=math.max(0,storage.request_reservations[unit_number][item]-amount)
end

reservation.events={}

return reservation