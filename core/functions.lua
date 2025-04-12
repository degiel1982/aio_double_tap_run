local air_timer = {}

-- Reset air timer when player leaves
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    air_timer[player_name] = nil
end)

-- Check if player's health is below a threshold
local function is_player_low_on_health(player, threshold)
    local current_health = player:get_hp()
    return current_health and current_health < threshold
end

-- Check if player is in liquid
local function player_is_in_liquid(pos)
    local check_positions = {
        { x = pos.x, y = pos.y - 0.5, z = pos.z }, -- Feet position
        { x = pos.x, y = pos.y + 0.85, z = pos.z } -- Head position
    }
    for _, p in ipairs(check_positions) do
        local node = core.get_node_or_nil(p)
        if node then
            local nodedef = core.registered_nodes[node.name]
            if nodedef and nodedef.liquidtype and nodedef.liquidtype ~= "none" then
                return true
            end
        end
    end
    return false
end

-- Check if player is standing on a climbable node
local function is_player_on_climbable(player)
    local pos = player:get_pos()
    pos.y = pos.y - 0.5
    local node = core.get_node_or_nil(pos)
    local nodedef = node and core.registered_nodes[node.name]
    return nodedef and nodedef.climbable or false
end

-- Check if player is running against a wall
local function is_player_running_against_wall(player)
    local pos = player:get_pos()
    local dir = player:get_look_dir()
    local check_pos = { 
        x = pos.x + dir.x * 0.5, 
        y = pos.y, 
        z = pos.z + dir.z * 0.5 
    }
    local node = core.get_node_or_nil(vector.round(check_pos))
    local nodedef = node and core.registered_nodes[node.name]
    return nodedef and nodedef.walkable or false
end

-- Check if player is standing on snowy group nodes
local function is_player_standing_on_snowy_group(player)
    local pos = player:get_pos()
    local check_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local node = core.get_node_or_nil(check_pos)
    local nodedef = node and core.registered_nodes[node.name]
    return nodedef and nodedef.groups and nodedef.groups.snowy
end

-- Check if player is in the air for a specific duration
local function is_player_in_air_for_duration(player, duration)
    local player_name = player:get_player_name()
    local pos = player:get_pos()
    local check_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local node = core.get_node_or_nil(check_pos)
    local in_air = not (node and core.registered_nodes[node.name] and core.registered_nodes[node.name].walkable)

    if in_air then
        air_timer[player_name] = (air_timer[player_name] or 0) + 1 / core.settings:get("dedicated_server_step", 0.1)
    else
        air_timer[player_name] = nil
    end
    return air_timer[player_name] and air_timer[player_name] >= duration
end

-- Check if player is submerged in water
local function submerged_in_water(player)
    local pos = player:get_pos()
    local props = player:get_properties()
    local cb = props.collisionbox
    local minp = vector.floor(vector.add(pos, { x = cb[1], y = cb[2], z = cb[3] }))
    local maxp = vector.ceil(vector.add(pos, { x = cb[4], y = cb[5], z = cb[6] }))

    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local npos = { x = x, y = y, z = z }
                local node = core.get_node_or_nil(npos)
                local nodedef = node and core.registered_nodes[node.name]
                if not nodedef or not nodedef.liquidtype or nodedef.liquidtype == "none" then
                    return false
                end
            end
        end
    end
    return true
end


return {
    low_health = is_player_low_on_health,
    in_liquid = player_is_in_liquid,
    on_climbable = is_player_on_climbable,
    wall_bump = is_player_running_against_wall,
    on_snowy_node = is_player_standing_on_snowy_group,
    in_air = is_player_in_air_for_duration,
    submerged = submerged_in_water,
}
