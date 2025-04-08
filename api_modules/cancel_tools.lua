local LIQUID_CHECK = core.settings:get_bool("aio_double_tap_run.liquid_check", true)
local WALL_CHECK = core.settings:get_bool("aio_double_tap_run.wall_check", true)
local CLIMBABLE_CHECK = core.settings:get_bool("aio_double_tap_run.climbable_check", true)
local SNOW_CHECK = core.settings:get_bool("aio_double_tap_run.snow_check", true)
local FLY_CHECK = core.settings:get_bool("aio_double_tap_run.fly_check", false)
local HEALTH_CHECK = core.settings:get_bool("aio_double_tap_run.health_check", true)
local HEALTH_THRESHOLD = tonumber(core.settings:get("aio_double_tap_run.health_threshold")) or 6
local SWIM_ENABLE = core.settings:get_bool("aio_double_tap_run.enable_swim", true)
local air_timer = {}

-- Reset air timer when player leaves
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    air_timer[player_name] = nil
end)

-- Check if player's health is below a threshold
function aio_double_tap_run.is_player_low_on_health(player, threshold)
    local current_health = player:get_hp()
    return current_health and current_health < threshold
end

-- Check if player is in liquid
function aio_double_tap_run.player_is_in_liquid(pos)
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
function aio_double_tap_run.is_player_on_climbable(player)
    local pos = player:get_pos()
    pos.y = pos.y - 0.5
    local node = minetest.get_node_or_nil(pos)
    local nodedef = node and minetest.registered_nodes[node.name]
    return nodedef and nodedef.climbable or false
end

-- Check if player is running against a wall
function aio_double_tap_run.is_player_running_against_wall(player)
    local pos = player:get_pos()
    local dir = player:get_look_dir()
    local check_pos = { 
        x = pos.x + dir.x * 0.5, 
        y = pos.y, 
        z = pos.z + dir.z * 0.5 
    }
    local node = minetest.get_node_or_nil(vector.round(check_pos))
    local nodedef = node and minetest.registered_nodes[node.name]
    return nodedef and nodedef.walkable or false
end

-- Check if player is standing on snowy group nodes
function aio_double_tap_run.is_player_standing_on_snowy_group(player)
    local pos = player:get_pos()
    local check_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local node = minetest.get_node_or_nil(check_pos)
    local nodedef = node and minetest.registered_nodes[node.name]
    return nodedef and nodedef.groups and nodedef.groups.snowy
end

-- Check if player is in the air for a specific duration
function aio_double_tap_run.is_player_in_air_for_duration(player, duration)
    local player_name = player:get_player_name()
    local pos = player:get_pos()
    local check_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local node = minetest.get_node_or_nil(check_pos)
    local in_air = not (node and minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].walkable)

    if in_air then
        air_timer[player_name] = (air_timer[player_name] or 0) + 1 / minetest.settings:get("dedicated_server_step", 0.1)
    else
        air_timer[player_name] = nil
    end
    return air_timer[player_name] and air_timer[player_name] >= duration
end

-- Check if player is submerged in water
function aio_double_tap_run.submerged_in_water(player)
    local pos = player:get_pos()
    local props = player:get_properties()
    local cb = props.collisionbox
    local minp = vector.floor(vector.add(pos, { x = cb[1], y = cb[2], z = cb[3] }))
    local maxp = vector.ceil(vector.add(pos, { x = cb[4], y = cb[5], z = cb[6] }))

    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local npos = { x = x, y = y, z = z }
                local node = minetest.get_node_or_nil(npos)
                local nodedef = node and minetest.registered_nodes[node.name]
                if not nodedef or not nodedef.liquidtype or nodedef.liquidtype == "none" then
                    return false
                end
            end
        end
    end
    return true
end

aio_double_tap_run.register_dt_data_callback(function(player, filtered_data, dtime)
    local player_name = player:get_player_name()

    -- Check liquid and swimming conditions
    if LIQUID_CHECK and aio_double_tap_run.player_is_in_liquid(player:get_pos()) then
        if SWIM_ENABLE then
            -- Allow sprinting if swimming is enabled and the player is submerged
            if not aio_double_tap_run.submerged_in_water(player) then
                aio_double_tap_run.add_to_cancel_list(player_name, "WET")
                return
            end
        else
            -- Cancel sprinting entirely if swimming is disabled
            aio_double_tap_run.add_to_cancel_list(player_name, "WET")
            return
        end
    end

    -- Check if the player is on a climbable node
    if CLIMBABLE_CHECK and aio_double_tap_run.is_player_on_climbable(player) then
        aio_double_tap_run.add_to_cancel_list(player_name, "CLIMBABLE")
        return
    end

    -- Check if the player is running against a wall
    if WALL_CHECK and aio_double_tap_run.is_player_running_against_wall(player) then
        aio_double_tap_run.add_to_cancel_list(player_name, "WALL")
        return
    end

    -- Check if the player is standing on a snowy node
    if SNOW_CHECK and aio_double_tap_run.is_player_standing_on_snowy_group(player) then
        aio_double_tap_run.add_to_cancel_list(player_name, "SNOW")
        return
    end

    -- Check if the player is in the air for too long
    if FLY_CHECK and aio_double_tap_run.is_player_in_air_for_duration(player, 2) then
        aio_double_tap_run.add_to_cancel_list(player_name, "FLY")
        return
    end

    -- Check if the player is low on health
    if HEALTH_CHECK and aio_double_tap_run.is_player_low_on_health(player, HEALTH_THRESHOLD) then
        aio_double_tap_run.add_to_cancel_list(player_name, "DYING")
        return
    end
end)
