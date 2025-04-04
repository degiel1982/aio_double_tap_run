------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--[[
    LIQUID CHECK:
    When player is in liquid it returns true otherwise false
]]
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
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
--[[
    CLIMBABLE CHECK:
        When a player is on a climbable it returns true otherwise false
]]
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
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--[[
    DOUBLE TAP CHECK
]]
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
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--[[
    GET MOD AUTHOR:
        Stamina by sofar and Tenplus uses the same name as modname.
        By extracting the author of the mod I could differentiate
]]
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
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--[[
    CHECKS PLAYER IS STARVING(STAMINA ONLY):
]]
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

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--[[
    SPRINT PARTICLES:
]]

local game_textures = {}
local dirt = ""
if minetest.get_modpath("xcompat") and minetest.global_exists("xcompat") then
    game_textures = xcompat.textures
    if core.get_game_info().id == "minetest" or core.get_game_info().id == "farlands_reloaded" then
        dirt = game_textures.grass.dirt
    else
        dirt = "smoke_puff.png"
    end
else
    if core.get_game_info().id == "minetest" or core.get_game_info().id == "farlands_reloaded" then
        dirt = "default_dirt.png"
    else
        dirt = "smoke_puff.png"
    end
end

local function sprint_particles(player)
    local pos = player:get_pos()
    local node = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    local def = minetest.registered_nodes[node.name] or {}
    local drawtype = def.drawtype
    if drawtype ~= "airlike" and drawtype ~= "liquid" and drawtype ~= "flowingliquid" then
        minetest.add_particlespawner({
            amount = 5,
            time = 0.01,
            minpos = {x = pos.x - 0.25, y = pos.y + 0.1, z = pos.z - 0.25},
            maxpos = {x = pos.x + 0.25, y = pos.y + 0.1, z = pos.z + 0.25},
            minvel = {x = -0.5, y = 1, z = -0.5},
            maxvel = {x = 0.5, y = 2, z = 0.5},
            minacc = {x = 0, y = -5, z = 0},
            maxacc = {x = 0, y = -12, z = 0},
            minexptime = 0.25,
            maxexptime = 0.5,
            minsize = 0.5,
            maxsize = 1.0,
            vertical = false,
            collisiondetection = false,
            texture = dirt
        })
    end
end

local function sprint_key_activated(use_aux, use_dt, control_bits, dt_data, dtime, tap_interval, dt_sensor, name)
    -- Consolidate key state checks
    local key_state_dt = false
    local key_state_aux = false
    local has_beds = minetest.get_modpath("beds") ~= nil
    if use_aux then
        if has_beds and beds.player[name] then
            return false
        else
            key_state_aux = (control_bits == 33 or control_bits == 49 or control_bits == 545)
        end
    end
    if use_dt then
        if has_beds and beds.player[name] then
           return false
        else
            key_state_dt = (control_bits == 1 or control_bits == 17 or control_bits == 513)
            key_state_dt = dt_sensor(dt_data, dtime, key_state_dt, tap_interval)
        end
    end
    if key_state_dt or key_state_aux then
        return true
    end
    return false
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--[[
    RETURNING THE TOOLS:
]]
return {
    player_is_in_liquid = player_is_in_liquid, 
    dt_sensor = dt_sensor, 
    get_mod_author = get_mod_author, 
    is_player_starving = is_player_starving, 
    is_player_on_ladder = is_player_on_ladder, 
    is_player_running_against_wall = is_player_running_against_wall,
    sprint_particles = sprint_particles,
    sprint_key_activated = sprint_key_activated,
}
