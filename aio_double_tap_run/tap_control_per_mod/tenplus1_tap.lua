local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")

local player_double_tap = {}
local player_is_sprinting = {}
local settings = {
    stamina_drain = core.settings:get("stamina_sprint_drain") or 0.35,
}
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

        if sprinting then
            if not player_is_sprinting[name] then
                player:set_physics_override({ speed = 1.5 }) -- Double the player's speed while sprinting.
                player_is_sprinting[name] = true
            end
            stamina.change(player, -0.5 * dtime)
        else
            if player_is_sprinting[name] then
                player:set_physics_override({ speed = 1 }) -- Reset the player's speed to normal.
                player_is_sprinting[name] = false
            end
        end
    end
end)