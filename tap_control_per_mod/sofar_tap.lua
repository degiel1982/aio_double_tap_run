local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")


local player_double_tap = {}

local settings = {
    trigger_delay = 0.5,
    starve_lvl = tonumber(core.settings:get("stamina.starve_lvl")) or 3,
    drain_points_sprint = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28.0,
    drain_points_walk = tonumber(core.settings:get("stamina.exhaust_move")) or 0.5,
}

--Player status information
local player_data = {
    count = 0,
    timer = 0, 
    was_up = false,
    sprinting = false,
    is_wet = false,
    starving = function(current_stamina)
        local treshold = settings.starve_lvl * 2
        if current_stamina > treshold then
            return false
        else
            return true
        end
    end,
    is_sprinting = false,
}

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
            player_double_tap[name] = player_data
        end

        local is_crouching = control.sneak
        local is_aux = control.aux1

        player_double_tap[name].is_wet = is_touching_liquid(p_pos) 
        
        local is_wet = player_double_tap[name].is_wet
        local is_sprinting = player_double_tap[name].is_sprinting

        local current_stamina = stamina.get_saturation(player)

        local is_starving = player_double_tap[name].starving(current_stamina)

        if is_crouching or (is_crouching and is_aux)then
            break
        end

        player_double_tap[name].is_sprinting = update_double_tap(player_double_tap[name], dtime, control.up, settings.trigger_delay)
        
        if is_wet or (is_sprinting and (is_aux or is_starving)) then
            stamina.set_sprinting(player, false)
            if is_sprinting then
                stamina.exhaust_player(player, (settings.drain_points_walk*2) * dtime, "walking")
            end
            break
        end

        if is_sprinting and not is_wet and not is_starving and not is_aux then
            stamina.set_sprinting(player, true)
            if is_sprinting then
                stamina.exhaust_player(player, (settings.drain_points_sprint*2) * dtime, "sprinting")
            end
        end
    end
end)
