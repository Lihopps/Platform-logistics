local util = {}


--separate string
function util.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---@param item string item with name_qual form
---@return array {name,qual}
function util.name_and_qual(item)
    local names = util.split(item, "_")
    local qual = names[#names]
    if #names==1 then qual="normal" end
    local name = string.gsub(item, "_" .. qual, "")
    return { name, qual }
end

function util.create_flying_text(player, text, position, cursor, type)
    if not player or not player.valid then return end

    player.create_local_flying_text { text = text, position = position, create_at_cursor = cursor }
end

---@param hub LuaEntity platform hub
---@param name string name of the section
---@return number section or nil
function util.get_logistic_section_by_name(hub, name)
    local sections = hub.get_logistic_sections()

    if not sections then return nil end

    for _, section in pairs(sections.sections) do
        if section.group == name then
            return section.index
        end
    end
    sections.add_section(name)
    return util.get_logistic_section_by_name(hub, name)
end

---convert array name in the same array but with planet
---@param name_array table table of name
---@return table planet_array table of planet
function util.name_to_planet(name_array)
    local planet_array = {}
    for _, name in pairs(name_array) do
        table.insert(planet_array, game.planets[name])
    end
    return planet_array
end

---round rocket the number of item
---@param item String name_qual format
---@param amount number
---@return number : quantity rocket rounded
function util.amount_rocket_rounded(item, amount)
    local item_name = util.name_and_qual(item)[1]
    local item_weight = prototypes.item[item_name].weight
    local item_per_rocket=math.floor(1000000/item_weight)
    local nb_rocket=math.ceil(amount/item_per_rocket)
    return nb_rocket*item_per_rocket
end

---@param unit_number number Unit_number of the entity
---@return string network as string : signal_quality
function util.get_network_from_unit_number(unit_number)
    if storage.platforms[unit_number] then
        return storage.platforms[unit_number].network or "signal-A_normal"
    end
    if storage.request_nodes[unit_number] then
        return storage.request_nodes[unit_number].network or "signal-A_normal"
    end
    if storage.supply_nodes[unit_number] then
        return storage.supply_nodes[unit_number].network or "signal-A_normal"
    end
    return "signal-A_normal"
end


---@param unit_number number Unit_number of the entity
---@return string sub_network as string : number of sub network
function util.get_sub_network_from_unit_number(unit_number)
    if storage.platforms[unit_number] then
        return storage.platforms[unit_number].sub_network or "1"
    end
    if storage.request_nodes[unit_number] then
        return storage.request_nodes[unit_number].sub_network or "1"
    end
    if storage.supply_nodes[unit_number] then
        return storage.supply_nodes[unit_number].sub_network or "1"
    end
    return "1"
end

function util.has_common_bits_from_string_32(a_str, b_str)
    if (not a_str or a_str=="") then return true end
    local a = tonumber(a_str)
    local b = tonumber(b_str)
    return bit32.band(a, b) ~= 0
end

--- @param count integer
--- @return string
function util.format_signal_count(count)
    if not count then return "" end
	local function si_format(divisor, si_symbol)
		if math.abs(math.floor(count / divisor)) >= 10 then
			count = math.floor(count / divisor)
			return string.format("%.0f%s", count, si_symbol)
		else
			count = math.floor(count / (divisor / 10)) / 10
			return string.format("%.1f%s", count, si_symbol)
		end
	end

	local abs = math.abs(count)
	return -- signals are 32bit integers so Giga is enough
			abs >= 1e9 and si_format(1e9, "G") or
			abs >= 1e6 and si_format(1e6, "M") or
			abs >= 1e3 and si_format(1e3, "k") or
			tostring(count)
end

function util.rich_text_from_itemqal(item,qual)
    return "[item="..item..",quality="..(qual or "normal").."]"
end

function util.parameter_from_signal(param)
    local parameter={
        priority=settings.global["LPN-default-priority"].value,
        rocket_threshold=0,
        items={}
    }
    if param then
        if param.signals then
            for _,signal in pairs(param.signals) do
                if signal.signal.name=="LPN-priority" then
                    parameter.priority=signal.count
                elseif signal.signal.name=="LPN-rocket_stack" then
                    parameter.rocket_threshold=math.max(signal.count,0)
                else
                    parameter.items[signal.signal.name.."_"..(signal.signal.quality or "normal")]=signal.count
                end
            end
        end
    end
    return parameter
end

function util.threshold(parameter,itemqal)
    if parameter.items[itemqal] then
        return parameter.items[itemqal]
    end
    if parameter.rocket_threshold>0 then
        return (parameter.rocket_threshold*util.amount_rocket_rounded(itemqal,1))
    end
    local default_t=settings.global["LPN-default-threshold"].value
    return 0-- (default_t*util.amount_rocket_rounded(itemqal,1))-1
end

function util.itemqal_in_filters(itemqal,filters)
    if not itemqal then return true end
    for i,filter in ipairs(filters) do
        if next(filter) then
            if (filter.value.name.."_"..(filter.value.quality or "normal"))==itemqal and filter.min>0 then
                return true
            end
        end
    end
    return false
end

function util.filter_from_parameter(parameter)
    local filters={}
        table.insert(filters,{
            min=parameter.priority,
            type="default",
            value={name="LPN-priority"}
        })
        table.insert(filters,{
            min=parameter.rocket_threshold,
            type="default",
            value={name="LPN-rocket_stack"}
        })
    for itemqal,count in pairs(parameter.items) do
        local item,quality=table.unpack(util.name_and_qual(itemqal))
        table.insert(filters,{
            type="default",
            min=count,
            value={
                name=item,
                quality=quality
            }
        })
    end
    return filters
end

function util.filter_to_dic(filters)
    local new_filters={}
    for _,filter in pairs(filters)do
        local itemqal=filter.value.name.."_"..filter.value.quality
        if not new_filters[itemqal] then new_filters[itemqal]=filter end
    end
    return new_filters
end

function util.dic_to_filter(filter_dic) 
    local filters={}
    for itemqal,filter in pairs(filter_dic) do
        table.insert(filters,filter)
    end
    return filters
end
return util
