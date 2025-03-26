local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")

local player_double_tap = {}
local player_is_sprinting = {}

-- Check for optional player_monoids support
local player_monoids = minetest.global_exists("player_monoids") and player_monoids or nil
local sprint_monoid = nil

-- Define a monoid for sprinting speed if player_monoids is available
if player_monoids then
    sprint_monoid = player_monoids.make_monoid({
        name = "sprinting_speed",
        type = "speed",
        identity = 1.0, -- Default speed multiplier
        combine = function(a, b)
            return a * b -- Combine speed changes multiplicatively
        end,
        fold = function(tab)
            local result = 1.0
            for _, value in pairs(tab) do
                result = result * value
            end
            return result
        end,
        apply = function(speed, player)
            local override = player:get_physics_override()
            override.speed = speed
            player:set_physics_override(override)
        end,
    })
end

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
    player_is_sprinting[name] = nil -- Remove sprinting state info.

    -- Reset speed if using player_monoids
    if player_monoids and sprint_monoid then
        sprint_monoid:del_change(player, "aio_double_tap_run:sprinting")
    else
        -- Fallback to resetting physics override
        player:set_physics_override({ speed = 1 })
    end
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name = player:get_player_name()
        local control = player:get_player_control()
        local p_pos = player:get_pos()

        if not player_double_tap[name] then
            player_double_tap[name] = {
                count     = 0,
                timer     = 0,
                was_up    = false,
                sprinting = false,
            }
        end

        local im_wet = is_touching_liquid(p_pos)
        local sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5)

        if (sprinting and control.aux1) or im_wet then
            sprinting = false
        end

        if sprinting then
            if not player_is_sprinting[name] then
                if player_monoids and sprint_monoid then
                    -- Use player_monoids to set sprinting speed
                    sprint_monoid:add_change(player, 2.0, "aio_double_tap_run:sprinting")
                else
                    -- Fallback to default physics override
                    player:set_physics_override({ speed = 2 })
                end
                player_is_sprinting[name] = true
            end
        else
            if player_is_sprinting[name] then
                if player_monoids and sprint_monoid then
                    -- Reset speed using player_monoids
                    sprint_monoid:del_change(player, "aio_double_tap_run:sprinting")
                else
                    -- Fallback to resetting physics override
                    player:set_physics_override({ speed = 1 })
                end
                player_is_sprinting[name] = false
            end
        end
    end
end)
