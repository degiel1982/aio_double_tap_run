local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")
local get_keycode = dofile(core.get_modpath("aio_double_tap_run").."/tap_control_per_mod/functions/get_keycode.lua")
local get_mod_author = dofile(core.get_modpath("aio_double_tap_run").."/modules/get_mod_author.lua")
local set_sprint = dofile(core.get_modpath("aio_double_tap_run").."/modules/monoids.lua")

local settings = {}
local player_double_tap = {}
local player_is_sprinting = {}

local player_data = {
    count = 0,
    timer = 0, 
    was_up = false,
    sprinting = false,
    keycode = 0,
    wet = false
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

        player_double_tap[name].wet = is_touching_liquid(p_pos)

        if not player_double_tap[name].wet then
            player_double_tap[name].keycode = get_keycode(player)
            local key_code = player_double_tap[name].keycode
            player_double_tap[name].is_sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5) 
            local is_sprinting = player_double_tap[name].is_sprinting
            if key_code == 1 then
                if is_sprinting then
                    set_sprint(player, true)
                else
                    set_sprint(player, false)
                end
            end
        end
    end
end)
