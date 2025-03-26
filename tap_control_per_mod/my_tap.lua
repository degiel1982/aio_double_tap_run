local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")

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
                player:set_physics_override({ speed = 2 }) -- Double the player's speed while sprinting.
                player_is_sprinting[name] = true
            end
        else
            if player_is_sprinting[name] then
                player:set_physics_override({ speed = 1 }) -- Reset the player's speed to normal.
                player_is_sprinting[name] = false
            end
        end
    end
end)
