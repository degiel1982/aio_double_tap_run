local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")
local get_keycode = dofile(core.get_modpath("aio_double_tap_run").."/tap_control_per_mod/functions/get_keycode.lua")
local settings = {
    trigger_delay = 0.5,
    stamina_sprint_drain = tonumber(core.settings:get("stamina_sprint_drain")) or 0.35,
    move_exhaust = 1.5,
    enable_stamina = core.settings:get_bool("enable_stamina", true)
}
local player_double_tap = {}
local player_data = {
    count = 0,
    timer = 0, 
    was_up = false,
    sprinting = false,
    starving = function(current_stamina, treshold)
        if current_stamina >= treshold then
            return false
        else
            return true
        end
    end,
    keycode = 0,
    wet = false
}
core.register_on_leaveplayer(function(player)
    player_double_tap[player:get_player_name()] = nil  
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
        player_double_tap[name].wet = is_touching_liquid(p_pos)
        local stamina_is_enabled = settings.enable_stamina
        if not player_double_tap[name].wet then
          player_double_tap[name].keycode = get_keycode(player)
          local key_code = player_double_tap[name].keycode
          player_double_tap[name].is_sprinting = update_double_tap(player_double_tap[name], dtime, control.up, settings.trigger_delay) 
          local is_sprinting = player_double_tap[name].is_sprinting
          if key_code == 1 then
            if stamina_is_enabled then
              local current_stamina = stamina.get_saturation(player)
              local is_starving = player_double_tap[name].starving(current_stamina, 6)
              if is_sprinting and not is_starving then
                stamina.set_sprinting(player, true)
              end
              stamina.change_saturation(player, -(settings.stamina_sprint_drain * dtime))
            end
          else
            if is_sprinting and not is_starving then
              stamina.set_sprinting(player, true)
            end
          end
        else
          if stamina_is_enabled then
            stamina.set_sprinting(player, false)
            stamina.exhaust_player(player, settings.move_exhaust * dtime)
          else
            stamina.set_sprinting(player, false)
          end
        end
    end
end)