-- Register callback for double-tap detection
local mod_name = aio_double_tap_run.mod_name
local functions = dofile(core.get_modpath(mod_name) .. "/core/functions.lua")
local ENABLE_STARVE = core.settings:get_bool(mod_name..".hb_starve_check", true)
local ENABLE_DRAIN = core.settings:get_bool(mod_name..".hb_enable_stamina_drain", true)
local TRESHOLD = tonumber(core.settings:get(mod_name..".hb_treshold")) or 6
local DRAIN_RATE = tonumber(core.settings:get(mod_name..".hb_drain_rate")) or 15.0
DRAIN_RATE = DRAIN_RATE * 10
aio_double_tap_run.register_callback(function(player, data, dtime)
    local player_name = player:get_player_name()
    local current_hunger = hbhunger.hunger[player_name] or hbhunger.SAT_INIT

    if ENABLE_STARVE then
        if current_hunger < TRESHOLD then
            data.cancel_sprint = true
            return data
        end
    end
    if ENABLE_DRAIN then
        if data.is_sprinting and not functions.in_air(player, 1) and not functions.wall_bump(player) then
            hbhunger.exhaustion[player_name] = (hbhunger.exhaustion[player_name] or 0) + dtime * DRAIN_RATE
            if hbhunger.exhaustion[player_name] >= hbhunger.EXHAUST_LVL then
                hbhunger.exhaustion[player_name] = 0
                if current_hunger > 0 then
                    current_hunger = current_hunger - 1
                    hbhunger.hunger[player_name] = current_hunger
                    hbhunger.set_hunger_raw(player)
                end
            end
        end
    end
    return nil
end)