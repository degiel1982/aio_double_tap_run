local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")

local player_double_tap = {}

local settings = {
    trigger_delay = 0.5,
    starve_lvl = tonumber(core.settings:get("stamina.starve_lvl")) or 3,
    drain_points_sprint = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28.0,
    drain_points_walk = tonumber(core.settings:get("stamina.exhaust_move")) or 0.5,
}

settings.starve_lvl = settings.starve_lvl * 2

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name    = player:get_player_name()
        local control = player:get_player_control()
        local p_pos = player:get_pos()
        
        if not player_double_tap[name] then
            player_double_tap[name] = {
                count     = 0,      -- Number of taps detected.
                timer     = 0,      -- Timer to track the time window for double taps.
                was_up    = false,  -- Tracks if the "up" key was released.
                sprinting = false,  -- Whether the player is currently sprinting.
            }
        end

        local im_wet = is_touching_liquid(p_pos)


        local sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5)

        -- Prevent sprinting if the "aux1" key (commonly used for sneak or special actions) is pressed.
        if sprinting and control.aux1 then
            sprinting = false
        end

        if sprinting then
            if im_wet then
                stamina.set_sprinting(player, false)
            else
                stamina.set_sprinting(player, true)
            end
            current_stamina = stamina.get_saturation(player)
            if current_stamina > settings.starve_lvl then
                stamina.exhaust_player(player, settings.drain_points_sprint * dtime, "sprinting")
            else
                stamina.set_sprinting(player, false)
                stamina.exhaust_player(player, settings.drain_points_walk * dtime, "walking")
            end
        else
            if im_wet then
                stamina.set_sprinting(player, false)
            end
        end
    end
end)