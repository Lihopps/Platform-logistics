local platform_manager = require("script.platform_manager")
local request_manager = require("script.request_manager")
local supply_manager = require("script.supply_manager")
local reservation = require("script.reservation_manager")
local routing =require("script.routing")
local util=require("script.util")
local util_alert=require("script.util-alert")

local dispatcher = {}

local MAX_ASSIGNMENTS = settings.global["LPN-dispatcher-assign-per-cycle"].value

function dispatcher.update()
   
    platform_manager.update_platforms()
    request_manager.update_requests()
    --if next(storage.requests) then
        supply_manager.update_supplies()
    --end
    --helpers.write_file("storage.json",helpers.table_to_json(storage))

    
end

function dispatcher.dispatch()

    local assignments = 0

    for _,request in ipairs(storage.requests) do

        if assignments >= MAX_ASSIGNMENTS then
            break
        end
        local provider =supply_manager.find_best_supply(request)

        if provider == nil then
            util_alert.create_alert_no_provider(request.node.entity,request.item,true)
            goto continue
        end

        local platform =platform_manager.find_best_platform(provider.location,request.destination,request.node)

        if platform[1] == nil then
            util_alert.create_alert_no_platform(request.node.entity,request.item,true)
            goto continue
        end

        if #platform==1 then
            dispatcher.create_delivery(platform[1], provider, request)
        else
            dispatcher.update_delivery(platform,provider,request)
        end

        assignments = assignments + 1

        ::continue::

    end

end

function dispatcher.create_delivery(platform, provider, request)

    local amount = platform_manager.reel_item_amount(platform,request)
    
    
    reservation.reserve_supply(provider.node.id, amount,request.item)
    reservation.reserve_request(request.node.id, amount,request.item)

    --get mission path by A* (return list of spacelocation)
    --local path={provider.node.location.planet,request.node.location.planet}
    --local path=util.name_to_planet(routing.a_star(provider.node.location.planet.name,request.node.location.planet.name))
    local path=util.name_to_planet(routing.a_star_multi_waypoints(
        {game.planets[platform.entity.surface.platform.last_visited_space_location.name].name,provider.node.location.planet.name,
        request.node.location.planet.name}
        )
        )
    
    --si le depart et le premier prov c'est le meme on enleve le premier pour eviter le décalage du mission_index
    local starting=false
    if #path>=2 then
        if path[1].name==path[2].name then
            table.remove(path,1)
            starting=true
        end
    end

    platform.mission={}
    platform.mission_index=1
    for i,planet in ipairs(path) do
        if i==1 and not starting then --si c'est le premier et que c'est pas un prov
            table.insert(platform.mission,
                {[planet.surface.index]={
                    {
                        station={id=-1,location={planet=planet}},
                        type="none",
                    }
                }}
            )
            goto continue
        end
        -- provider requester none 
        if planet.surface.index==provider.node.location.index then
            table.insert(platform.mission,
                {[planet.surface.index]={
                    {station=provider.node,
                    type="provider",
                    item={[request.item]=amount}}
                }}
            )
                        
        elseif planet.surface.index==request.node.location.index then
            table.insert(platform.mission,
                {[planet.surface.index]={
                    {station=request.node,
                    type="requester",
                    item={[request.item]=amount}}
                }}
            )
        else
            table.insert(platform.mission,
                {[planet.surface.index]={
                   { station={id=-1,location={planet=planet}},
                    type="none",}
                }}
            )
        end
        ::continue::
    end
    platform.state = "TRAVELING"
    platform_manager.update_platform_schedule(platform,true)

end

function dispatcher.update_delivery(platform_data, provider, request)
    local platform = platform_data[1]
    local amount = platform_manager.reel_item_amount(platform,request)

    reservation.reserve_supply(provider.node.id, amount,request.item)
    reservation.reserve_request(request.node.id, amount,request.item)

    local mission=platform.mission
    local prov_index=platform_data[2]
    local req_index=platform_data[3]
    if platform.mission[prov_index][provider.node.location.index] then
        for _,station_data in pairs(platform.mission[prov_index][provider.node.location.index]) do
            if station_data.station.id==provider.node.id then
                station_data.item[request.item]=(station_data.item[request.item] or 0)+amount
                goto makerequest
            end
        end
        table.insert(platform.mission[prov_index][provider.node.location.index], {
            station=provider.node,
            type="provider",
            item={[request.item]=amount}}
        )
    end

    ::makerequest::

    if platform.mission[req_index][request.node.location.index] then
        for _,station_data in pairs(platform.mission[req_index][request.node.location.index]) do
            if station_data.station.id==request.node.id then
                station_data.item[request.item]=(station_data.item[request.item] or 0)+amount
                goto continue
            end
        end
        table.insert(platform.mission[req_index][request.node.location.index], {
            station=request.node,
            type="requester",
            item={[request.item]=amount}}
        )
    end

    ::continue::

    platform_manager.update_platform_schedule(platform,false)

end


dispatcher.events={

}

return dispatcher