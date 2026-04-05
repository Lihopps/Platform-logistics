local reservation = require("script.reservation_manager")
local util=require("script.util")

local manager = {}

function manager.update_requests()
    storage.requests = {}

    for id, node in pairs(storage.request_nodes) do
        local entity = node.entity

        if not entity.valid then
            storage.request_nodes[id] = nil
            goto continue
        end

        local inventory = entity.get_inventory(defines.inventory.cargo_landing_pad_main)
        if not inventory then
            goto continue
        end

        local parameter=entity.get_circuit_network(defines.wire_connector_id.circuit_green) --threshold
        parameter=util.parameter_from_signal(parameter)

        local sections = entity.get_logistic_sections()
        if sections then
            sections = sections.sections
            for _, section in pairs(sections) do
                if section.active then
                    local finded = string.find(section.group, "[virtual-signal=signal-no-entry]", 1, true)
                    if not finded then
                        local filters = section.filters
                        for _, filter in pairs(filters) do
                            if filter and next(filter) then
                                local current = inventory.get_item_count({
                                    name = filter.value.name,
                                    quality = filter.value.quality
                                })
                                local reserved = reservation.get_request_reserved(node.id,filter.value.name.."_"..filter.value.quality)
                                local needed = filter.min - current - reserved
                                local threshold=util.threshold(parameter,filter.value.name.."_"..filter.value.quality) 
                                if needed > threshold then 
                                    storage.requests[#storage.requests + 1] = {
                                        node = node,
                                        item = filter.value.name.."_"..filter.value.quality,
                                        amount = needed,
                                        priority = 1,
                                        destination = node.location,
                                        priority=parameter.priority
                                    }
                                end
                            end
                            
                        end
                    end
                end
            end
        end

        ::continue::
    end
    table.sort(storage.requests, function(a, b) return a.priority > b.priority end)
end

manager.events = {}


return manager
