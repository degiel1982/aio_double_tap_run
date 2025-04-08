--------------------------------------------------------------------------------
-- Global Settings and Functions for AUX, FORWARD, and Sprint Speed Behavior
--------------------------------------------------------------------------------

-- Ensure the main table exists
aio_double_tap_run = aio_double_tap_run or {}

local CROUCH_CHECK = core.settings:get_bool("aio_double_tap_run.crouch_check", false)

-- Global toggle for AUX functionality (default: enabled)
aio_double_tap_run.aux_enabled = core.settings:get_bool("aio_double_tap_run.enable_aux", false)

aio_double_tap_run.disable_backwards_sprint = core.settings:get_bool("aio_double_tap_run.disable_backwards_sprint", true)

-- Global toggle for FORWARD functionality (default: enabled)
aio_double_tap_run.forward_enabled = core.settings:get_bool("aio_double_tap_run.enable_dt", true)

-- Global sprint speed multiplier (default: 1)

-- Global function to set AUX behavior (true = enabled, false = disabled)
function aio_double_tap_run.set_aux_enabled(state)
    aio_double_tap_run.aux_enabled = state and true or false
end

-- Global function to set FORWARD behavior (true = enabled, false = disabled)
function aio_double_tap_run.set_forward_enabled(state)
    aio_double_tap_run.forward_enabled = state and true or false
end

-- Global function to set sprint speed (multiplier)
function aio_double_tap_run.set_sprint_speed(speed)
    aio_double_tap_run.sprint_speed = speed
end

--------------------------------------------------------------------------------
-- Double Tap Detection & Sprinting Logic
--------------------------------------------------------------------------------

-- Table to hold each player's double tap data
local dt_data = {}

-- Table to hold registered dt data callback functions
local dt_data_callbacks = {}

-- Helper function to create a new player data copy
local function create_player_data()
    return {
        dt_detected  = false,
        last_tap_time = 0,
        is_holding    = false,
        aux_pressed   = false,
        key           = "NO_KEY",
    }
end

-- Clean up player data and cancel flags when they leave
core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    dt_data[player_name] = nil
    aio_double_tap_run.cancel_list[player_name] = nil
end)

--------------------------------------------------------------------------------
-- Cancel List Mechanism (Player-Specific)
--------------------------------------------------------------------------------

-- Initialize the cancel list as an empty table keyed by player names
aio_double_tap_run.cancel_list = {}

-- Function to add a cancellation flag for a specific player
function aio_double_tap_run.add_to_cancel_list(player_name, item)
    aio_double_tap_run.cancel_list[player_name] = item
end

-- Function to remove the cancellation flag for a specific player
function aio_double_tap_run.remove_from_cancel_list(player_name)
    aio_double_tap_run.cancel_list[player_name] = nil
end

-- Function to check if the cancel list is empty (not used directly in dt logic)
function aio_double_tap_run.is_cancel_list_empty()
    return next(aio_double_tap_run.cancel_list) == nil
end

--------------------------------------------------------------------------------
-- Double Tap Detection Globalstep
--------------------------------------------------------------------------------
core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    local current_time = core.get_us_time() / 1000000  -- Convert microseconds to seconds

    for _, player in ipairs(players) do
        local player_name = player:get_player_name()

        -- Initialize player data if not present
        if not dt_data[player_name] then
            dt_data[player_name] = create_player_data()
        end

        local player_control = player:get_player_control_bits()
        local player_data = dt_data[player_name]

        -- Check if player is currently canceled (e.g. due to low saturation)
        if aio_double_tap_run.cancel_list[player_name] then
            player_data.dt_detected = false
            player_data.is_holding = false
            player_data.key = "CANCELLED"
            aio_double_tap_run.remove_from_cancel_list(player_name)
        else
            -- Process SHIFT or BACKWARD key
            if (player_control == 65 and CROUCH_CHECK) or ((player_control == 34 or player_control == 2) and aio_double_tap_run.disable_backwards_sprint) then
                player_data.dt_detected = false
                player_data.is_holding = false
                player_data.key = ""
            -- Process AUX + FORWARD key only if AUX is enabled
            elseif aio_double_tap_run.aux_enabled and player_control == 33 then
                player_data.dt_detected = true
                player_data.is_holding = false
                player_data.aux_pressed = true
                player_data.key = "AUX1"
            elseif player_control == 1 then
                if aio_double_tap_run.forward_enabled then
                    if not player_data.is_holding then
                        if current_time - player_data.last_tap_time < 0.5 then
                            player_data.dt_detected = true
                            player_data.key = "FORWARD"
                        end
                        player_data.last_tap_time = current_time
                        player_data.is_holding = true
                    end
                    -- If AUX was pressed earlier but now released, adjust the key
                    if player_data.aux_pressed then
                        player_data.key = "FORWARD"
                        player_data.aux_pressed = false
                    end
                else
                    -- If FORWARD functionality is disabled, reset to no dt detection
                    player_data.dt_detected = false
                    player_data.is_holding = false
                    player_data.key = "FORWARD_DISABLED"
                end

            -- No key pressed
            elseif player_control == 0 then
                player_data.dt_detected = false
                player_data.is_holding = false
                player_data.aux_pressed = false
                player_data.key = "NO_KEY"
            end
        end

        -- Invoke any registered callbacks with the filtered dt data
        aio_double_tap_run.invoke_dt_data_callbacks(player, dtime)
    end
end)

--------------------------------------------------------------------------------
-- Callback Registration Mechanism for dt Data
--------------------------------------------------------------------------------

-- Register a callback function to be called later with filtered dt data
function aio_double_tap_run.register_dt_data_callback(callback)
    table.insert(dt_data_callbacks, callback)
end

-- Invoke all registered callbacks for the given player using filtered data
function aio_double_tap_run.invoke_dt_data_callbacks(player, dtime)
    local player_name = player:get_player_name()
    local data = dt_data[player_name]
    if data then
        local filtered_data = {
            dt_detected = data.dt_detected,
            key         = data.key,
            timer       = dtime
        }
        for _, callback in ipairs(dt_data_callbacks) do
            callback(player, filtered_data, dtime)
        end
    end
end