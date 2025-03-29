local set_sprinting, mod_settings = dofile(core.get_modpath("aio_double_tap_run").."/functions/physics.lua")

aio_double_tap_run = {}

--API
aio_double_tap_run.set_sprinting = set_sprinting

--

TAP_CHECK_INTERVAL = 0.5
--
local player_double_tap = {}

local player_data = {
    count = 0,
    timer = 0, 
    was_up = false,
    sprinting = false,
    wet = false,
    running = false,
    starving = false
}

--
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
end)
--
core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name = player:get_player_name()
        local p_pos = player:get_pos()

        if not player_double_tap[name] then
            player_double_tap[name] = player_data
        end

        player_double_tap[name].wet = mod_settings.tools.player_is_in_liquid(p_pos)

        if not player_double_tap[name].wet and not is_on_ladder then
            local control_bits = player:get_player_control_bits()
            local key_is_pressed = control_bits == 1 or control_bits == 17
            if mod_settings.use_aux then
                player_double_tap[name].running = mod_settings.tools.dt_sensor(player_double_tap[name], dtime, key_is_pressed, TAP_CHECK_INTERVAL) or control_bits == 33
            else
                player_double_tap[name].running = mod_settings.tools.dt_sensor(player_double_tap[name], dtime, key_is_pressed, TAP_CHECK_INTERVAL)
            end
        else
            player_double_tap[name].running = false
        end

        if mod_settings.mod_settings.stamina.sofar.installed or mod_settings.mod_settings.stamina.tenplus.installed then
            if mod_settings.mod_settings.stamina.sofar.installed then
                player_double_tap[name].starving = mod_settings.tools.is_player_starving(stamina.get_saturation(player), mod_settings.mod_settings.stamina.sofar.treshold * 2)
            end
            if mod_settings.mod_settings.stamina.tenplus.installed then
                player_double_tap[name].starving = mod_settings.tools.is_player_starving(stamina.get_saturation(player), mod_settings.mod_settings.stamina.tenplus.treshold)
            end
            if player_double_tap[name].starving then
                player_double_tap[name].running = false
            end
        end

        if player_double_tap[name].running then
            set_sprinting(player, true)
            if mod_settings.mod_settings.stamina.sofar.installed then
                stamina.exhaust_player(player, mod_settings.mod_settings.stamina.sofar.exhaust_sprint * dtime)
            end
            if mod_settings.mod_settings.stamina.tenplus.installed then
                stamina.exhaust_player(player, (mod_settings.mod_settings.stamina.tenplus.exhaust_sprint * 100) * dtime)
            end
            local current_animation = player:get_animation()
            local animation_range = current_animation and {x = current_animation.x, y = current_animation.y} or {x = 0, y = 79}
            local sprint_speed = 30 + (player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2
            player:set_animation(animation_range, sprint_speed, 0)
        else
            if not mod_settings.mod_settings.stamina.tenplus.installed then
                if mod_settings.mod_settings.pova.installed or (mod_settings.mod_settings.pova.installed == false and mod_settings.mod_settings.player_monoids.installed == false) then
                    set_sprinting(player, false)
                    if mod_settings.mod_settings.stamina.sofar.installed then
                        stamina.exhaust_player(player, (mod_settings.mod_settings.stamina.sofar.exhaust_move) * dtime)
                    end
                    if mod_settings.mod_settings.stamina.tenplus.installed then
                        stamina.exhaust_player(player, (mod_settings.mod_settings.stamina.tenplus.exhaust_move) * dtime)
                    end
                end
            end
                local current_animation = player:get_animation()
                local animation_range = current_animation and {x = current_animation.x, y = current_animation.y} or {x = 0, y = 79}
                local sprint_speed = 15 + (player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2
                player:set_animation(animation_range, sprint_speed, 0) -- Running animation
        end
    end
end)
