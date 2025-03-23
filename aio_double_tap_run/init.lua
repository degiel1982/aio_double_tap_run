--------------------------------------------------
-- Load optional modules and settings for the mod
--------------------------------------------------
local optional_mods = dofile(core.get_modpath("aio_double_tap_run").."/modules/optional_mods.lua")
local settings      = dofile(core.get_modpath("aio_double_tap_run").."/modules/settings.lua")
local update_double_tap = dofile(core.get_modpath("aio_double_tap_run").."/modules/double_tap.lua")

--------------------------------------------------
-- Global Tables for tracking player states
--------------------------------------------------
local player_double_tap = {}    -- Stores double tap details (count, timer, state) for each player.
local player_last_time  = {}    -- Keeps track of the last update timestamp (in microseconds) for each player.
local player_liquid_cache = {}  -- Caches liquid collision information for each player.
local player_is_sprinting = {}  -- Tracks whether players are currently sprinting (for fallback physics override).

--------------------------------------------------
-- Utility Functions
--------------------------------------------------
-- (If not already defined, a simple vector_round function)
local function vector_round(vec)
    return {
        x = math.floor(vec.x + 0.5),
        y = math.floor(vec.y + 0.5),
        z = math.floor(vec.z + 0.5)
    }
end

-- Determines if a position is touching a liquid node.
local function is_touching_liquid(pos)
    local feet_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local head_pos = { x = pos.x, y = pos.y + 0.85, z = pos.z }
    local check_positions = { vector_round(feet_pos), vector_round(head_pos) }
    for _, p in ipairs(check_positions) do
        local node = core.get_node_or_nil(p)
        if node then
            local nodedef = core.registered_nodes[node.name]
            if nodedef and nodedef.liquidtype and nodedef.liquidtype ~= "none" then
                return true
            end
        end
    end
    return false
end

--------------------------------------------------
-- Updated Liquid Cache Function
-- Now uses an accumulated dt (delta-time) to reduce check frequency.
--------------------------------------------------
local function update_liquid_cache(player, dt)
    local name = player:get_player_name()
    local pos = player:get_pos()
    if not player_liquid_cache[name] then
        player_liquid_cache[name] = { is_touching_liquid = false, timer = 0 }
    end

    local cache_entry = player_liquid_cache[name]
    cache_entry.timer = cache_entry.timer + dt
    if cache_entry.timer >= settings.double_tap_run.liquid_update_interval then
        cache_entry.is_touching_liquid = is_touching_liquid(pos)
        cache_entry.timer = 0
    end
end

--------------------------------------------------
-- Optional Mod Presence Check (Stamina Mods)
--------------------------------------------------
local function modcheck()
    local installed = false
    -- Check if the 'sofar_stamina' mod is integrated.
    if optional_mods.sofar_stamina then
        installed = true
    end
    -- Check if the 'tenplus1_stamina' mod is integrated.
    if optional_mods.tenplus1_stamina then
        installed = true
    end
    if optional_mods.hunger_ng then
        installed = true
    end
    -- Note: We do not check for optional_mods.hunger_ng here so Hunger NG functions
    -- can be used even when no stamina mod is present.
    return installed
end

-- Save the result of the mod presence check to decide which sprinting mechanism to use.
local mod_installed = modcheck()

--------------------------------------------------
-- Player Cleanup Handler
--------------------------------------------------
core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil   -- Remove double tap state info.
    player_last_time[name]  = nil   -- Remove timestamp info.
    player_liquid_cache[name] = nil -- Remove liquid cache info.
end)

--------------------------------------------------
-- Global Step Function
-- (Handles sprinting, stamina, hunger NG, and now optimized liquid collision updates)
--------------------------------------------------
core.register_globalstep(function(dtime)
    local current_us = core.get_us_time()
    local players = core.get_connected_players()

    for _, player in ipairs(players) do
        local name    = player:get_player_name()
        local control = player:get_player_control()  -- Contains player's control states (e.g., movement keys).

        -- Update the liquid cache for the player using the dt interval.
        update_liquid_cache(player, dtime)
        local is_liquid = player_liquid_cache[name] and player_liquid_cache[name].is_touching_liquid

        -- Initialize the last update time if it doesn't exist.
        if not player_last_time[name] then
            player_last_time[name] = current_us
        end

        -- Calculate the elapsed time (in seconds) since the last update.
        local dt_precise = (current_us - player_last_time[name]) / 1000000
        player_last_time[name] = current_us

        -- Initialize the double tap state if needed.
        if not player_double_tap[name] then
            player_double_tap[name] = {
                count     = 0,      -- Number of consecutive taps.
                timer     = 0,      -- Timer to track time between taps.
                was_up    = false,  -- Whether the "up" key was previously pressed.
                sprinting = false,  -- Current sprinting state.
            }
        end

        -- Update double tap state; returns true if sprinting should be enabled.
        local sprinting = update_double_tap(player_double_tap[name], dt_precise, control.up, settings.double_tap_run.interval)

        -- If the auxiliary (aux1) control is pressed, cancel sprinting.
        local aux1 = control.aux1 or false
        if aux1 and sprinting then
            sprinting = false
        end

        -- Handle liquid interactions:
        -- When the player is in a liquid, force normal (or liquid) speed and disable sprinting.
        if is_liquid and sprinting then
            sprinting = false
            player:set_physics_override({ speed = settings.normal_speed})
            player_is_sprinting[name] = false
        else
            -- No liquid: apply the normal sprint/stamina behavior.
            if not mod_installed then
                -- Default physics override when no stamina mod is installed.
                if sprinting then
                    if not player_is_sprinting[name] then
                        player:set_physics_override({ speed = settings.sprint_speed })
                        player_is_sprinting[name] = true
                    end
                else
                    if player_is_sprinting[name] then
                        player:set_physics_override({ speed = settings.normal_speed })
                        player_is_sprinting[name] = false
                    end
                end
            else
                if optional_mods.sofar_stamina and optional_mods.sofar_stamina.is_sprinting_enabled and not control.aux1 then
                    if sprinting then
                        if optional_mods.sofar_stamina.is_stamina_enabled then
                            local current_saturation = optional_mods.sofar_stamina.get_saturation(player)
                            if current_saturation > optional_mods.sofar_stamina.stamina_starve_lvl then
                                -- Enough stamina: allow sprinting and drain stamina.
                                optional_mods.sofar_stamina.set_sprinting(player, true)
                                optional_mods.sofar_stamina.change_saturation(player,-optional_mods.sofar_stamina.stamina_drain_points * dt_precise,"sprinting")
                            else
                                -- Too low stamina: cancel sprinting.
                                optional_mods.sofar_stamina.set_sprinting(player, false)
                                sprinting = false  -- Disable sprinting.
                            end
                        end
                    end
                end
                if optional_mods.tenplus1_stamina and not control.aux1 then
                    if sprinting then
                        if not player_is_sprinting[name] then
                            player:set_physics_override({ speed = settings.sprint_speed })
                            player_is_sprinting[name] = true
                        end
                        optional_mods.tenplus1_stamina.change_saturation(player, -optional_mods.tenplus1_stamina.stamina_drain_points * dt_precise)
                    else
                        if player_is_sprinting[name] then
                            player:set_physics_override({ speed = settings.normal_speed })
                            player_is_sprinting[name] = false
                        end
                    end
                end
                if optional_mods.hunger_ng or control.aux1 then
                    if sprinting then
                        if not player_is_sprinting[name] then
                            player:set_physics_override({ speed = 1.5 })
                            player_is_sprinting[name] = true
                        end
                        local info = optional_mods.hunger_ng.get_hunger_info(player:get_player_name())
                        if not info.invalid then
                            local current_hunger = info.hunger.exact
                            if current_hunger <= optional_mods.hunger_ng.treshold then
                                if player_is_sprinting[name] then
                                    player:set_physics_override({ speed = settings.normal_speed })
                                    player_is_sprinting[name] = false
                                    optional_mods.hunger_ng.change(player:get_player_name(), -0.1 * dt_precise, dt_precise)
                                end
                            else
                            optional_mods.hunger_ng.change(player:get_player_name(), -0.3 * dt_precise, dt_precise)
                            end
                        end
                    else
                        if player_is_sprinting[name] then
                            player:set_physics_override({ speed = settings.normal_speed })
                            player_is_sprinting[name] = false
                        end
                    end
                end
            end
        end
    end
end)