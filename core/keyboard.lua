local mod_name = core.get_current_modname()

--Settings
local settings = {
    ENABLE_TAP = aio_double_tap_run.settings.enable_tap,
    ENABLE_AUX = aio_double_tap_run.settings.enable_aux,
}

local player_sprint_data = {}
local data_callbacks = {}

local function create_player_data()
    return {
        detected  = false,
        last_tap_time = 0,
        is_holding    = false,
        aux_pressed   = false,
        key           = "NO_KEY",
        cancel_sprint = false,
        is_sprinting = false,
    }
end

-- Invoke all registered callbacks for the given player using filtered data
local function invoke_callbacks(player, data, dtime)
    local player_name = player:get_player_name()
    local data = player_sprint_data[player_name]
    if data then
        for _, callback in ipairs(data_callbacks) do
            callback(player, data, dtime)
        end
    end
end

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    player_sprint_data[player_name] = nil
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    local current_time = core.get_us_time() / 1000000  -- Convert microseconds to seconds

    for _, player in ipairs(players) do
        if not aio_double_tap_run.is_player(player) then return nil end
        local player_name = player:get_player_name()

        -- Initialize player data if not present
        if not player_sprint_data[player_name] then
            player_sprint_data[player_name] = create_player_data()
        end

        local player_control = player:get_player_control_bits()
        local player_data = player_sprint_data[player_name]

        -- Check if player is currently canceled (e.g. due to low saturation)
        if player_data.cancel_sprint then
            player_data.detected = false
            player_data.is_holding = false
            player_data.key = "CANCELLED"
        else
            if player_control == 33 and settings.ENABLE_AUX then
                player_data.detected = true
                player_data.is_holding = false
                player_data.aux_pressed = true
                player_data.key = "AUX1"
            elseif player_control == 1 then
                if settings.ENABLE_TAP then
                    if not player_data.is_holding then
                        if current_time - player_data.last_tap_time < 0.5 then
                            player_data.detected = true
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
                    player_data.detected = false
                    player_data.is_holding = false
                    player_data.key = "FORWARD_DISABLED"
                end

            -- No key pressed
            elseif player_control == 0 then
                player_data.detected = false
                player_data.is_holding = false
                player_data.aux_pressed = false
                player_data.key = "NO_KEY"
                player_data.is_sprinting = false
            end
        end
        local results = invoke_callbacks(player, player_data, dtime)
        if results ~= nil and results ~= player_data then
            player_data = results
        end
    end
end)

-- Register a callback function to be called later with filtered dt data
function aio_double_tap_run.register_callback(callback)
    table.insert(data_callbacks, callback)
end

