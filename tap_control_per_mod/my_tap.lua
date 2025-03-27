local player_is_in_liquid, dt_sensor, sprint, get_mod_author = dofile(core.get_modpath("aio_double_tap_run").."/modules/tools.lua")
local mod_settings = dofile(core.get_modpath("aio_double_tap_run").."/modules/tools.lua")

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
            player_double_tap[name].wet = is_touching_liquid(p_pos)
            player_double_tap[name].liquid_check_timer = 0
        end

        local control_bits = player:get_player_control_bits()

        local key_is_pressed = control_bits == 1 or control_bits == 17

        local player_double_tap[name].running = dt_sensor(player_double_tap[name], dtime, key_is_pressed, TAP_CHECK_INTERVAL) and not player_double_tap[name].wet

        sprint(player, player_double_tap[name].running, mod_settings.extra_speed)


        --if not player_double_tap[name].wet then
        --    player_double_tap[name].keycode = get_keycode(player)
        --    local key_code = player_double_tap[name].keycode
        --    player_double_tap[name].is_sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5) 
        --    local is_sprinting = player_double_tap[name].is_sprinting
        --    if key_code == 1 then
        --        if is_sprinting then
        --            set_sprint(player, true)
        --        else
        --            set_sprint(player, false)
        --        end
        --    end
        --end
    end
end)
