local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")

local player_double_tap = {}
local player_is_sprinting = {}

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
    player_is_sprinting[name] = nil -- Remove sprinting state info.
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name    = player:get_player_name()
        local control = player:get_player_control()

        -- Initialize the double tap state for the player if it doesn't exist.
        -- This state keeps track of the number of taps, a timer for detecting double taps,
        -- whether the "up" key was previously released, and the current sprinting state.
        if not player_double_tap[name] then
            player_double_tap[name] = {
                count     = 0,      -- Number of taps detected.
                timer     = 0,      -- Timer to track the time window for double taps.
                was_up    = false,  -- Tracks if the "up" key was released.
                sprinting = false,  -- Whether the player is currently sprinting.
            }
        end

        -- Update the sprinting state based on double-tap detection for the "up" key.
        -- The `update_double_tap` function handles the logic for detecting double taps
        -- within a specified time window (0.5 seconds in this case).
        local sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5)

        -- Prevent sprinting if the "aux1" key (commonly used for sneak or special actions) is pressed.
        if sprinting and control.aux1 then
            sprinting = false
        end

        -- Update the player's sprinting state and adjust their physics override accordingly.
        -- If sprinting, increase the player's speed; otherwise, reset it to normal.
        if sprinting then
            -- This code checks if the player is not already sprinting. If the player is not sprinting,
            -- it doubles their movement speed by setting the physics override to a speed of 2.
            -- The `player_is_sprinting` table is then updated to mark the player as sprinting.
            -- This approach ensures that the physics override is only applied once per sprint activation,
            -- avoiding redundant calls and potential performance issues.
            if not player_is_sprinting[name] then
                player:set_physics_override({ speed = 2 }) -- Double the player's speed while sprinting.
                player_is_sprinting[name] = true
            end
        else
            -- This block checks if the player is currently sprinting. If they are, it resets their speed to normal
            -- by setting the physics override speed to 1 and updates the sprinting state to false.
            -- This approach ensures that the player's speed is restored to the default value when they stop sprinting,
            -- maintaining consistent gameplay mechanics and preventing unintended speed boosts or reductions.
            if player_is_sprinting[name] then
                player:set_physics_override({ speed = 1 }) -- Reset the player's speed to normal.
                player_is_sprinting[name] = false
            end
        end
    end
end)