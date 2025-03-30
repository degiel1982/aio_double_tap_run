-- Liquid check
local function player_is_in_liquid(pos)
    local feet_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local head_pos = { x = pos.x, y = pos.y + 0.85, z = pos.z }
    local check_positions = { vector.round(feet_pos), vector.round(head_pos) }
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

-- Helper function to check if a player is on a ladder
local function is_player_on_ladder(player)
    local pos = player:get_pos()
    pos.y = pos.y - 0.5 -- Adjust downward to check the node beneath the player
    local node = minetest.get_node_or_nil(pos)
    if node ~= nil then
        local nodedef = minetest.registered_nodes[node.name]
        return nodedef and nodedef.climbable or false
    else 
        return false
    end
end

local function dt_sensor(dt_state, dtime, key_pressed, trigger_delay)
    if not dt_state.sprinting then
        if dt_state.count > 0 then
            dt_state.timer = dt_state.timer + dtime
        end

        if key_pressed and not dt_state.was_up then
            dt_state.count = dt_state.count + 1
            if dt_state.count == 1 then
                dt_state.timer = 0
            end
        end

        dt_state.was_up = key_pressed

        if dt_state.timer > trigger_delay then
            dt_state.count = 0
            dt_state.timer = 0
        end

        if dt_state.count == 2 and dt_state.timer <= trigger_delay then
            dt_state.sprinting = true
        end
    else
        if not key_pressed then
            dt_state.sprinting = false
            dt_state.count = 0
            dt_state.timer = 0
        end
    end

    return dt_state.sprinting
end

local function get_mod_author(modname)
    -- Get the path to the mod's directory
    local modpath = core.get_modpath(modname)
    if not modpath then
        return nil, "Mod not found"
    end

    -- Load the mod.conf file
    local mod_conf = Settings(modpath .. "/mod.conf")
    if not mod_conf then
        return nil, "mod.conf not found"
    end

    -- Get the author field
    local author = mod_conf:get("author")
    if author then
        return author
    else
        return nil, "Author field not found in mod.conf"
    end
end

local function is_player_starving(current_stamina, treshold)
    if current_stamina >= treshold then
        return false
    else
        return true
    end
end
local function is_player_running_against_wall(player)
    local pos = player:get_pos()
    local dir = player:get_look_dir()
    
    -- Check a position slightly in front of the player
    local check_pos = { 
        x = pos.x + dir.x * 0.5, 
        y = pos.y, 
        z = pos.z + dir.z * 0.5 
    }
    local node = minetest.get_node_or_nil(vector.round(check_pos))
    
    if node then
        local nodedef = minetest.registered_nodes[node.name]
        -- Check if the node is solid (not walkable) to determine a wall
        return nodedef and nodedef.walkable or false
    else
        return false
    end
end
return player_is_in_liquid, dt_sensor, get_mod_author, is_player_starving, is_player_on_ladder, is_player_running_against_wall
