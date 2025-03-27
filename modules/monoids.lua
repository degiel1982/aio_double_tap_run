local player_monoid = {}
local monoids_is_installed = minetest.get_modpath("player_monoids") ~= nil
local NORMAL_SPEED = 1
local SPRINT_MONOID = {}
--[[
    When monoids is installed then create a monoid
]]
if monoids_is_installed then
    SPRINT_MONOID = player_monoids.make_monoid({
        combine = function(a, b)
            return a * b
        end,
        fold = function(tab)
            local result = 1.0
            for _, value in pairs(tab) do
            result = result * value
            end
            return result
        end,
        identity = 1.0, 
        apply = function(speed, player)
            local override = player:get_physics_override()
            override.speed = speed
            player:set_physics_override(override)
        end,
    })
end

--[[
    Helper functions
    The functions that start or stop a sprint
]]

-- Start sprint
local function start_sprinting(player, extra_speed)
    if not player then return end
    if monoids_is_installed then
        speed = 
        SPRINT_MONOID:add_change(player, (NORMAL_SPEED + extra_speed), "aio_double_tap_run:sprinting")
    else
        player:set_physics_override({ speed = (NORMAL_SPEED + extra_speed) })
    end
end

-- Stop sprint
local function stop_sprinting(player)
    if not player then return end
    if monoids_is_installed then
        sprint_monoid:del_change(player, "aio_double_tap_run:sprinting")
    else
        player:set_physics_override({ speed = NORMAL_SPEED })
    end
end

--[[
    Function to use in code
]]

local sprinting_states = {}

local function set_sprinting(player, enable_sprint, extra_speed)
    if not player then return end
    local player_name = player:get_player_name()
    if not player_name then return end

    if enable_sprint then
        -- Check if the player is already sprinting
        if sprinting_states[player_name] then
            return -- Do nothing if already sprinting
        end

        -- Start sprinting
        sprinting_states[player_name] = true
        if monoids_is_installed then
            SPRINT_MONOID:add_change(player, (NORMAL_SPEED + extra_speed), "aio_double_tap_run:sprinting")
        else
            player:set_physics_override({ speed = (NORMAL_SPEED + extra_speed) })
        end
    else
        -- Check if the player is not sprinting
        if not sprinting_states[player_name] then
            return -- Do nothing if not sprinting
        end

        -- Stop sprinting
        sprinting_states[player_name] = false
        if monoids_is_installed then
            SPRINT_MONOID:del_change(player, "aio_double_tap_run:sprinting")
        else
            player:set_physics_override({ speed = NORMAL_SPEED })
        end
    end
end

return set_sprinting
