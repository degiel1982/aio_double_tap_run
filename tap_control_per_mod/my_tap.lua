local player_is_in_liquid, dt_sensor, sprint, get_mod_author = dofile(core.get_modpath("aio_double_tap_run").."/modules/tools.lua")
local mod_settings = dofile(core.get_modpath("aio_double_tap_run").."/modules/mod_settings.lua")

local stamina_is_installed = core.get_modpath("stamina") ~= nil

LIQUID_CHECK_INTERVAL = 0.5
TAP_CHECK_INTERVAL = 0.5

local player_double_tap = {}

local player_data = {
    count = 0,
    timer = 0, 
    was_up = false,
    sprinting = false,
    liquid_check_timer = LIQUID_CHECK_INTERVAL,
    wet = false,
    running = false,
    starving = false
}

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name    = player:get_player_name()
        local p_pos = player:get_pos()
        
        if not player_double_tap[name] then
            player_double_tap[name] = player_data
        end
            
        if player_double_tap[name].liquid_check_timer >= LIQUID_CHECK_INTERVAL then
            player_double_tap[name].wet = player_is_in_liquid(p_pos)
            player_double_tap[name].liquid_check_timer = 0
        end

        local control_bits = player:get_player_control_bits()

        local key_is_pressed = control_bits == 1 or control_bits == 17

        player_double_tap[name].running = dt_sensor(player_double_tap[name], dtime, key_is_pressed, TAP_CHECK_INTERVAL) and not player_double_tap[name].wet

        if player_double_tap[name].running then
            if stamina_is_installed then
                local current_stamina = stamina.get_saturation(player)
                local is_starving = player_double_tap[name].starving(current_stamina, mod_settings.treshold)
                if is_starving then
                    sprint(player, false, mod_settings.extra_speed)
                    stamina.exhaust_player(player, mod_settings.move_exhaust * dtime)
                else
                    sprint(player, true, mod_settings.extra_speed)
                    stamina.change_saturation(player, -(mod_settings.stamina_sprint_drain * dtime))
                end
            else
                sprint(player, true, mod_settings.extra_speed)
            end
        else
            sprint(player, false, mod_settings.extra_speed)
        end
    end
end)
