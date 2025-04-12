local mod_name = core.get_current_modname()

local pova_is_installed = core.get_modpath("pova") ~= nil
local monoids_is_installed = core.get_modpath("player_monoids") ~= nil

local reset_timers = {}

function aio_double_tap_run.set_sprinting(player, sprint, extra_speed)
    local player_name = player:get_player_name()
    if not player_name then return end

    if sprint then
        -- Set sprint speed
        if monoids_is_installed then
            player_monoids.speed:add_change(player, (1 + extra_speed), mod_name .. ":sprinting")
        elseif pova_is_installed then
            local override_name = mod_name .. ":sprinting"
            local override_table = { speed = (extra_speed), jump = nil, gravity = nil }
            pova.add_override(player_name, override_name, override_table)
            --pova.del_override(player_name, override_name)
        else
            player:set_physics_override({ speed = (1 + extra_speed) })
        end
        -- Cancel any existing reset timer by overwriting it
        if reset_timers[player_name] then
            reset_timers[player_name] = nil
        end

        -- Create a new reset timer
        reset_timers[player_name] = minetest.after(0.3, function()
            -- Ensure the player still exists and reset their speed
            if player and player:is_player() then
                if monoids_is_installed then
                    player_monoids.speed:del_change(player, mod_name .. ":sprinting")
                elseif pova_is_installed then
                    --local override_name = "aio_double_tap_run:sprinting"
                    --pova.del_override(player_name, override_name)
                else
                    player:set_physics_override({ speed = 1 })
            
                end
            end
            reset_timers[player_name] = nil -- Clear the timer reference
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
        reset_timers[player_name] = nil -- Clear any existing timer reference
    end
end
