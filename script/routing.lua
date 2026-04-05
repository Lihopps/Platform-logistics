local routing={}


---build planet graph tree for a* routing ; use only in data-final-fixes
function routing.collect_data()
    local nodes={}
    for _,route in pairs(data.raw["space-connection"]) do
        local from=route.from
        local to=route.to
        local length=route.length
        if not data.raw["planet"][from] or not data.raw["planet"][to] then goto continue end

        if not nodes[from] then nodes[from]={} end
        nodes[from][to]=length
       
        if not nodes[to] then nodes[to]={} end
        nodes[to][from]=length
            

        ::continue::
    end
    data.extend({
        {
            type="mod-data",
            name="LPN-graph",
            data_type="planet-graphique",
            data=nodes
        }
    })

end

local function heuristics(a,b)
    return 0 -- si tu n'as pas de distance estimée
end


---@param start string start planet as string (name)
---@param goal string goal planet as string (name)
---@param heuristic ?function function that count the cost between a et b , ddistance already count
function routing.a_star(start, goal, heuristic)
    if start==goal then
        return {start,goal}
    end
    if not heuristic then heuristic=heuristics end
    local nodes=prototypes.mod_data["LPN-graph"].data
    local openSet = {[start] = true}

    local cameFrom = {}

    local gScore = {}
    local fScore = {}

    for node,_ in pairs(nodes) do
        gScore[node] = math.huge
        fScore[node] = math.huge
    end

    gScore[start] = 0
    fScore[start] = heuristic(start, goal)

    local function lowest_fscore()
        local best = nil
        local bestScore = math.huge

        for node,_ in pairs(openSet) do
            if fScore[node] < bestScore then
                bestScore = fScore[node]
                best = node
            end
        end

        return best
    end

    while next(openSet) do

        local current = lowest_fscore()

        if current == goal then
            local path = {current}

            while cameFrom[current] do
                current = cameFrom[current]
                table.insert(path,1,current)
            end

            return path
        end

        openSet[current] = nil

        for neighbor,d in pairs(nodes[current]) do

            --local neighbor = edge.node
            --local d = edge.distance

            local tentative_g = gScore[current] + d

            if tentative_g < gScore[neighbor] then

                cameFrom[neighbor] = current
                gScore[neighbor] = tentative_g
                fScore[neighbor] = tentative_g + heuristic(neighbor, goal)

                openSet[neighbor] = true
            end
        end
    end
    return nil
end

---@param points table table of all points by name in order
---@param heuristic ?function function that count the cost between a et b , ddistance already count
function routing.a_star_multi_waypoints(points, heuristic)
    local full_path = {}

    for i = 1, #points - 1 do
        local sub = routing.a_star(points[i], points[i+1], heuristic)
        if not sub then return nil end

        if i > 1 then
            table.remove(sub, 1)
        end

        for _,n in ipairs(sub) do
            table.insert(full_path, n)
        end
    end

    return full_path
end

---return route distance from a path
---@param path table array of point give by a* algorithm
---@return number distance 
function routing.get_distance_from_path(path)
    local nodes=prototypes.mod_data["LPN-graph"].data
    local distance=0
    for i=1,#path-1 do
        distance=distance+(nodes[path[i]][path[i+1]] or 0)
    end
    return distance
end

return routing