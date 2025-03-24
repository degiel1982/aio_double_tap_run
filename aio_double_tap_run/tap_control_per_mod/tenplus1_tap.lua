local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")
local is_touching_liquid = dofile(core.get_modpath("aio_double_tap_run").."/modules/liquid_check.lua")


local settings = {
    stamina_drain_sprint = core.settings:get("stamina_sprint_drain") or 0.35,
    extra_speed = core.settings:get("stamina_sprint_speed") or 0.5,
    move_exhaust = 1.5,
}

local player_double_tap = {}
local player_is_sprinting = {}
local player_liquid_timer = {} 

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil 
    player_is_sprinting[name] = nil 
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
        if not player_liquid_timer[name] then
            player_liquid_timer[name] = 0
        end

        -- Update liquid check at intervals
        player_liquid_timer[name] = player_liquid_timer[name] + dtime

        local im_wet = is_touching_liquid(p_pos)


        local sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5)
        

        if (sprinting and control.aux1) or im_wet then
            sprinting = false
            if im_wet then
                player:set_physics_override({ speed = 0.8 })
            end
        end

        if sprinting then
            local current_stamina = stamina.get_saturation(player)
            if current_stamina >= 7 then
                if not player_is_sprinting[name] then
                    player:set_physics_override({ speed = (1.0 + settings.extra_speed) })
                    player_is_sprinting[name] = true
                end
                stamina.change(player, -(settings.stamina_drain_sprint * dtime))
            else
                if player_is_sprinting[name] then
                    player:set_physics_override({ speed = 1 })
                    player_is_sprinting[name] = false
                end
                stamina.exhaust_player(player, settings.move_exhaust * dtime)
            end
        else
            if not im_wet then
                if player_is_sprinting[name] then
                    player:set_physics_override({ speed = 1 })
                    player_is_sprinting[name] = false
                end
            end
        end
    end
end)
