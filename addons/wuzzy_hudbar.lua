local mod_name = aio_double_tap_run.mod_name
local bar_id = "fatigue"
local BAR_BGICON = "server_favorite.png"         -- Change to your background icon if needed
local BAR = "[fill:2x16:0,0:#056608"
local S = core.get_translator("aio_double_tap_run") -- Use your mod name here

-- Register the fatigue HUD bar
hb.register_hudbar(
    bar_id,
    0xFFFFFF, 
    S("Fatigue"), -- Label
    { icon = BAR_BGICON, bgicon = nil, bar = BAR },
    20, -- default_start_value
    20, -- default_start_max
    false -- default_start_hidden
)

-- Initialize the HUD bar for each player
core.register_on_joinplayer(function(player)
    hb.init_hudbar(player, bar_id, 20, 20, false)
end)

-- Helper functions to get/set fatigue values
local function get_fatigue(player)
    local state = hb.get_hudbar_state(player, bar_id)
    return state and state.value or 0, state and state.max or 20
end

local function set_fatigue(player, value, max)
    hb.change_hudbar(player, bar_id, value, max)
end

-- Integration with AIO Double Tap Run logic
local functions = dofile(core.get_modpath(mod_name) .. "/core/functions.lua")
local storage = core.get_mod_storage()
local sprint_timer = {}

aio_double_tap_run.register_callback(function(player, data, dtime)
    local player_name = player:get_player_name()
    local value, max_value = get_fatigue(player)
    if max_value == 0 then max_value = 20 end

    -- Get the player's health
    local player_health = player:get_hp()
    local health_threshold = tonumber(core.settings:get(mod_name .. ".restore_threshold")) or 6

    if value <= 1 then
        data.cancel_sprint = true
        set_fatigue(player, 0, max_value)
        return data
    end

    if data.is_sprinting and not functions.in_air(player, 2) and not functions.wall_bump(player) then
        sprint_timer[player_name] = nil
        if value > 0 then
            set_fatigue(player, math.max(0, value - 0.5 * dtime), max_value)
        end
    else
        sprint_timer[player_name] = (sprint_timer[player_name] or 0) + dtime
        if sprint_timer[player_name] >= 2 and player_health > health_threshold then
            if value < max_value then
                set_fatigue(player, math.min(max_value, value + 1 * dtime), max_value)
            end
        end
    end
end)
