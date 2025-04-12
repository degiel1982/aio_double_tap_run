local mod_name = aio_double_tap_run.mod_name

local hunger_ng_treshold = tonumber(core.settings:get(mod_name..".hunger_treshold")) or 6
local ENABLE_STARVE = core.settings:get_bool(mod_name..".starve_check", true)
local ENABLE_DRAIN = core.settings:get_bool(mod_name..".enable_stamina_drain", true)
local functions = dofile(core.get_modpath(mod_name) .. "/core/functions.lua")

-- Register callback for double-tap detection
aio_double_tap_run.register_callback(function(player, data, dtime)
    if not aio_double_tap_run.is_player(player) then return nil end
    local player_name = player:get_player_name()
    if ENABLE_STARVE then
        local info = hunger_ng.get_hunger_information(player_name)
        if info.hunger.exact <= hunger_ng_treshold then
            data.cancel_sprint = true
            return data
        end
    end
    if ENABLE_DRAIN then
        if data.is_sprinting and not functions.in_air(player,1) and not functions.wall_bump(player) then
            hunger_ng.alter_hunger(player_name, -(0.5 * dtime), 'Sprinting')
        end
    end
    return nil
end)
