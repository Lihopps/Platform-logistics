local reservation = require("script.reservation_manager")
local util = require("script.util")
local routing = require("script.routing")

local manager = {}

function manager.update_supplies()
    storage.supplies = {}

    for id, node in pairs(storage.supply_nodes) do
        local provider = node.entity

        if not provider.valid then
            storage.supply_nodes[id] = nil
            goto continue
        end


        local input = provider.get_circuit_network(defines.wire_connector_id.combinator_input_red)       --input
        local parameter = provider.get_circuit_network(defines.wire_connector_id.combinator_input_green) --threshold
        parameter = util.parameter_from_signal(parameter)
        
        if input then
            if input.signals then
                for _, signal in pairs(input.signals) do
                    if prototypes.item[signal.signal.name] then
                        if signal.count >= util.threshold(parameter, signal.signal.name .. "_" .. (signal.signal.quality or "normal")) then
                            if storage.supplies[signal.signal.name .. "_" .. (signal.signal.quality or "normal")] == nil then
                                storage.supplies[signal.signal.name .. "_" .. (signal.signal.quality or "normal")] = {}
                            end
                            storage.supplies[signal.signal.name .. "_" .. (signal.signal.quality or "normal")][node.id] = {
                                node = node,
                                available = signal.count,
                                location = node.location,
                                priority = parameter.priority
                            }
                        end
                    end
                end
            end
        end

        ::continue::
    end
end

function manager.find_best_supply(request)
    local providers = storage.supplies[request.item]

    if providers == nil then
        return nil
    end

    local best = nil
    local best_score = -math.huge

    for _, provider in pairs(providers) do
        if provider.node.network == request.node.network and util.has_common_bits_from_string_32(provider.node.sub_network, request.node.sub_network) then
            local reserved =
                reservation.get_supply_reserved(provider.node.id, request.item)

            local available =
                provider.available - reserved

            if available <= 0 then
                goto continue
            end

            local distance = routing.get_distance_from_path(routing.a_star(provider.location.planet.name,
                request.destination.planet.name))


            local score =
                provider.priority * 100
                - (distance / 1000)
                + available * 0.01

            if score > best_score then
                best = provider
                best_score = score
            end
        end
        ::continue::
    end

    return best
end

manager.events = {}


return manager
