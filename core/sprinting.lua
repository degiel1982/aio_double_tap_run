local mod_name = aio_double_tap_run.mod_name
local aio = aio_double_tap_run.physics
local EXTRA_SPEED = aio_double_tap_run.settings.extra_speed
local EXTRA_JUMP = tonumber(core.settings:get("aio_double_tap_run.extra_jump")) or 0.1
aio_double_tap_run.register_callback(function(player, data, dtime)
    if not aio_double_tap_run.is_player(player) then return nil end
    if not data.cancel_sprint then
        if data.detected then
            aio.sprint(player, true, EXTRA_SPEED, EXTRA_JUMP)
           if not data.is_sprinting then
               data.is_sprinting = true
           end
        else
           if aio.pova_is_installed then
                aio.sprint(player, false,0)
            end
            if data.is_sprinting then
                data.is_sprinting = false
            end
        end
    else
        if aio.pova_is_installed then
            aio.sprint(player, false,0)
        end
        if data.is_sprinting then
            data.is_sprinting = false
        end
    end
    return data
end)
---- 1. Get the current value of a HUD bar for a player
--function get_hudbar_value(player, identifier)
--    local state = hb.get_hudbar_state(player, identifier)
--    return state and state.value or nil
--end
--
---- 2. Set the bar image (workaround for "position" as HUD bars API does not support position directly)
--function set_hudbar_bar_image(player, identifier, bar_image)
--    -- Only the bar image can be changed, not the position
--    hb.change_hudbar(player, identifier, nil, nil, nil, nil, bar_image)
--end
--
---- 3. Per-player exhaust/drain function using dtime
--local exhaust_timers = {}
--
--function exhaust_hudbar(player, identifier, drain_per_second, interval, dtime)
--    local name = player:get_player_name()
--    exhaust_timers[name] = (exhaust_timers[name] or 0) + dtime
--    if exhaust_timers[name] >= interval then
--        exhaust_timers[name] = exhaust_timers[name] - interval
--        local state = hb.get_hudbar_state(player, identifier)
--        if state and state.value > 0 then
--            local drain_amount = drain_per_second * interval
--            local new_value = math.max(0, state.value - drain_amount)
--            hb.change_hudbar(player, identifier, new_value)
--        end
--    end
--end
--
---- 4. Register a new HUD bar
--function register_hudbar(identifier, text_color, label, textures, default_start_value, default_start_max, default_start_hidden, format_string, format_string_config)
--    hb.register_hudbar(
--        identifier,
--        text_color,
--        label,
--        textures,
--        default_start_value,
--        default_start_max,
--        default_start_hidden,
--        format_string,
--        format_string_config
--    )
--end
---- Register a new HUD bar (call once, e.g. at mod init)
--register_hudbar(
--    "stamina",                -- unique identifier
--    0xFFFFFF,                 -- text color (white)
--    "Stamina",                -- label
--    {icon="stamina_icon.png", bar="stamina_bar.png"}, -- textures
--    100,                      -- default start value
--    100,                      -- default max value
--    false                     -- default start hidden
--)
--
---- Initialize the HUD bar for a player (e.g. on join)
--minetest.register_on_joinplayer(function(player)
--    hb.init_hudbar(player, "stamina")
--end)
--
---- Get the current value of the HUD bar for a player
--local value = get_hudbar_value(player, "stamina")
--
---- Change the bar image (no direct position support)
--set_hudbar_bar_image(player, "stamina", "new_stamina_bar.png")
--
---- Drain the HUD bar over time (in globalstep)
--minetest.register_globalstep(function(dtime)
--    for _, player in ipairs(minetest.get_connected_players()) do
--        exhaust_hudbar(player, "stamina", 2, 1, dtime) -- drains 2 per second, every 1 second
--    end
--end)
