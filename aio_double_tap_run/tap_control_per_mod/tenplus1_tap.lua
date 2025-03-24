local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")

local tenplus1s = {
    get_saturation = dofile(core.get_modpath("aio_double_tap_run").."/modules/get_stamina_tenplus1s.lua")	
}
local settings = {
    stamina_drain_sprint = core.settings:get("stamina_sprint_drain") or 0.35,
    extra_speed = core.settings:get("stamina_sprint_speed") or 0.3,
    move_exhaust = 1.5,
}
local exhaustion = {}

local player_double_tap = {}
local player_is_sprinting = {}

--local function apply_sprint_exhaustion(player, dtime)
--    local name = player:get_player_name()
--    local current_stamina = tenplus1s.get_saturation(player)
--
--    -- Only apply exhaustion if the player is sprinting and has enough stamina
--    if player_is_sprinting[name] and current_stamina > 0 then
--        local sprint_drain = settings.stamina_drain_sprint or 0.35 -- Default to 0.35
--        stamina.change(player, -(sprint_drain * dtime)) -- Reduce stamina based on sprint drain
--    end
--end
--
--local function apply_walk_exhaustion(player, dtime)
--    local name = player:get_player_name()
--    local current_stamina = tenplus1s.get_saturation(player)
--
--    -- Only apply exhaustion if the player is walking and has enough stamina
--    if not player_is_sprinting[name] and current_stamina > 0 then
--        local walk_drain = settings.stamina_drain_move or 0.015
--        stamina.change(player, -(walk_drain * dtime)) -- Reduce stamina based on walk drain
--    end
--end

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil 
    player_is_sprinting[name] = nil 
    --exhaustion[name] = nil -- Clear exhaustion data
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name    = player:get_player_name()
        local control = player:get_player_control()

        if not player_double_tap[name] then
            player_double_tap[name] = {
                count     = 0,
                timer     = 0,
                was_up    = false, 
                sprinting = false,  
            }
        end

        local sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5)

        if sprinting and control.aux1 then
            sprinting = false
        end

        if sprinting then
            local current_stamina = tenplus1s.get_saturation(player)
            if current_stamina >= 7 then
                if not player_is_sprinting[name] then
                    player:set_physics_override({ speed = (1.2 + settings.extra_speed) })
                    player_is_sprinting[name] = true
                end
                
                --apply_sprint_exhaustion(player, dtime)
            else
                if player_is_sprinting[name] then
                    player:set_physics_override({ speed = 1 })
                    player_is_sprinting[name] = false
                end
                --apply_walk_exhaustion(player, dtime)
            end
        else
            if player_is_sprinting[name] then
                player:set_physics_override({ speed = 1 })
                player_is_sprinting[name] = false
            end
        end
    end
end)
