local player_monoid = {}
local monoids_is_installed = minetest.get_modpath("player_monoids") ~= nil

if monoids_is_installed then
-- Define a new monoid for sprinting speed
sprint_monoid = player_monoids.make_monoid({
    combine = function(a, b)
        return a * b -- Combine speed changes multiplicatively
    end,
    fold = function(tab)
        local result = 1.0
        for _, value in pairs(tab) do
            result = result * value
        end
        return result
    end,
    identity = 1.0, -- Default speed multiplier
    apply = function(speed, player)
        local override = player:get_physics_override()
        override.speed = speed
        player:set_physics_override(override)
    end,
})
end
-- Function to start sprinting
local function start_sprinting(player)
    if not player then return end
    sprint_monoid:add_change(player, 2.0, "aio_double_tap_run:sprinting") -- Double the player's speed
end

-- Function to stop sprinting
local function stop_sprinting(player)
    if not player then return end
    sprint_monoid:del_change(player, "aio_double_tap_run:sprinting") -- Remove the sprinting speed change
end

local monoids_is_installed = minetest.get_modpath("player_monoids") ~= nil

-- Function to toggle sprinting
local function set_sprinting(player, enable_sprint)
    if enable_sprint then
        if monoids_is_installed then
            start_sprinting(player)
        else
            player:set_physics_override({ speed = 2 }) 
        end
    else
        if monoids_is_installed then
            stop_sprinting(player)
        else
            player:set_physics_override({ speed = 1 }) 
        end
    end
end
    
-- Return the functions for external use
return set_sprinting
