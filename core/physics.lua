local mod_name = core.get_current_modname()

local pova_is_installed = core.get_modpath("pova") ~= nil
local monoids_is_installed = core.get_modpath("player_monoids") ~= nil

local reset_timers = {}

local function set_sprinting(player, sprint, extra_speed, extra_jump)
    if not aio_double_tap_run.is_player(player) then return nil end
    local player_name = player:get_player_name()
    if not player_name then return end

    if sprint then
        -- Set sprint speed
        if monoids_is_installed then
            player_monoids.speed:add_change(player, (1 + extra_speed), mod_name .. ":sprinting")
             player_monoids.jump:add_change(player, (1 + (extra_jump or 0)), mod_name .. ":sprinting")
        elseif pova_is_installed then
            local override_name = mod_name .. ":sprinting"
            local override_table = { speed = (extra_speed), jump = extra_jump or nil, gravity = nil }
            pova.add_override(player_name, override_name, override_table)
            --pova.del_override(player_name, override_name)
        else
            player:set_physics_override({ speed = (1 + extra_speed), jump = (1+ (extra_jump or 0)) })
        end
        -- Cancel any existing reset timer by overwriting it
        if reset_timers[player_name] then
            reset_timers[player_name] = nil
        end

        -- Create a new reset timer
        reset_timers[player_name] = core.after(0.3, function()
            -- Ensure the player still exists and reset their speed
            if player and player:is_player() then
                if monoids_is_installed then
                    player_monoids.speed:del_change(player, mod_name .. ":sprinting")
                elseif pova_is_installed then
                else
                    player:set_physics_override({ speed = 1 })
            
                end
            end
            reset_timers[player_name] = nil
        end)
    else
        if monoids_is_installed then
            player_monoids.speed:del_change(player, mod_name .. ":sprinting")
        elseif pova_is_installed then
            local override_name = mod_name .. ":sprinting"
            pova.del_override(player_name, override_name)
        else
            player:set_physics_override({ speed = 1 })
    
        end
        reset_timers[player_name] = nil
    end
end

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    reset_timers[player_name] = nil
end)

return {
    sprint = set_sprinting,
    monoids_is_installed = monoids_is_installed,
    pova_is_installed = pova_is_installed,
}
