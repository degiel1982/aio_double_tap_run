local mod_name = aio_double_tap_run.mod_name

local check = dofile(core.get_modpath(mod_name) .. "/core/functions.lua")
local settings = aio_double_tap_run.settings
local function node_at_player_feet(player)
    local pos = player:get_pos()
    -- Slightly below the player's position to catch slabs/thin nodes
    local check_pos = { x = pos.x, y = pos.y + 0.2, z = pos.z }
    local node = core.get_node_or_nil(check_pos)
    if node then
        local def = core.registered_nodes[node.name]
        if def and def.groups and def.groups.snowy and def.groups.snowy > 0 then
            return true
        end
    end
    return false
end
local LIQUID_CHECK = settings.liquid_check
local WALL_CHECK = settings.wall_check
local CLIMBABLE_CHECK = settings.climbable_check
local SNOW_CHECK = settings.snow_check
local FLY_CHECK = settings.fly_check
local HEALTH_CHECK = settings.health_check
local HEALTH_THRESHOLD = settings.health_threshold
local SWIM_ENABLE = settings.swim_enable
local CROUCH_CHECK =settings.crouch_check
local BACKWARD_CHECK = settings.backward_check

aio_double_tap_run.register_callback(function(player, data, dtime)
    if not aio_double_tap_run.is_player(player) then return nil end
    local pos = player:get_pos()

    -- If a player is in a liquid (Lava / Water)
    if LIQUID_CHECK or SWIM_ENABLE then
        if check.in_liquid(pos) then
            if SWIM_ENABLE then
                -- Allow sprinting if swimming is enabled and the player is submerged
                if not check.submerged(player) then
                    data.cancel_sprint = true
                    return data
                end
            else
                data.cancel_sprint = true
                return data
            end

        end
    end

    -- If a player is bumping against a wall
    if WALL_CHECK  then
        if check.wall_bump(player) then
            data.cancel_sprint = true
            return data
        end
    end

    -- If a player is on a climbable (ladders/ vines, etc.)
    if CLIMBABLE_CHECK then
        if check.on_climbable(player) then
            data.cancel_sprint = true
            return data
        end
    end

    if SNOW_CHECK then
        if check.node_at_player_feet(player) then
            data.cancel_sprint = true
            return data
        end
    end

    if FLY_CHECK then
        if check.in_air(player, 2) then
            data.cancel_sprint = true
            return data
        end
    end

    if HEALTH_CHECK then
        if check.low_health(player, HEALTH_THRESHOLD) then
            data.cancel_sprint = true
            return data
        end
    end
    if CROUCH_CHECK then
        local control = player:get_player_control()
        if control.sneak then
            data.cancel_sprint = true
            return data
        end
    end
    if BACKWARD_CHECK then
        local control = player:get_player_control()
        if control.down then
            data.cancel_sprint = true
            return data
        end
    end
    data.cancel_sprint = false
    
    return data
end)

