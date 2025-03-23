local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap_sensor.lua")

local player_double_tap = {}
local player_is_sprinting = {}
local settings = {
    starve_lvl = tonumber(core.settings:get("hunger_ng_timer_starve")) or 2,
    sprint_drain = tonumber(core.settings:get("hunger_ng_timer_movement")) or 0.5,
    move_drain = tonumber(core.settings:get("hunger_ng_cost_movement")) or 0.008,
}

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
    player_is_sprinting[name] = nil -- Remove sprinting state info.
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name = player:get_player_name()
        local control = player:get_player_control()

        -- Initialize the double tap state for the player if it doesn't exist.
        if not player_double_tap[name] then
            player_double_tap[name] = {
                count = 0,      -- Number of taps detected.
                timer = 0,      -- Timer to track the time window for double taps.
                was_up = false, -- Tracks if the "up" key was released.
                sprinting = false, -- Whether the player is currently sprinting.
            }
        end

        -- Update the sprinting state based on double-tap detection for the "up" key.
        local sprinting = update_double_tap(player_double_tap[name], dtime, control.up, 0.5)

        -- Prevent sprinting if the "aux1" key (commonly used for sneak or special actions) is pressed.
        if sprinting and control.aux1 then
            sprinting = false
        end

        -- Get the player's hunger information
        local info = hunger_ng.get_hunger_information(name)
        if info.invalid then
            assert(info.invalid, 'Hunger information for ' .. name .. ' is invalid.')
        else
            if sprinting then
                -- Cancel sprinting if hunger is below the threshold
                if info.hunger.exact <= settings.starve_lvl then
                    sprinting = false
                    if player_is_sprinting[name] then
                        player:set_physics_override({ speed = 1 }) -- Reset the player's speed to normal.
                        player_is_sprinting[name] = false
                    end
                    hunger_ng.alter_hunger(name, -settings.move_drain* dtime, 'walking') -- Apply walking hunger penalty
                else
                    if sprinting then
                        if not player_is_sprinting[name] then
                            player:set_physics_override({ speed = 2 }) -- Double the player's speed while sprinting.
                            player_is_sprinting[name] = true
                        end
                        hunger_ng.alter_hunger(name, -settings.sprint_drain * dtime, 'Sprinting') -- Apply sprinting hunger penalty
                    end
                end
            else
                if player_is_sprinting[name] then
                    player:set_physics_override({ speed = 1 }) -- Reset the player's speed to normal.
                    player_is_sprinting[name] = false
                end
            end
        end
    end
end)