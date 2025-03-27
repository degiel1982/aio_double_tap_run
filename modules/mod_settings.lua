local player_is_in_liquid, dt_sensor, sprint, get_mod_author = dofile(core.get_modpath("aio_double_tap_run").."/modules/tools.lua")
local stamina_is_installed = core.get_modpath("stamina") ~= nil
local hunger_is_installed = core.get_modpath("hunger_ng") ~= nil
local settings = {}

if stamina_is_installed then
    local mod_author = get_mod_author("stamina")
    if mod_author == "TenPlus1" then
        settings = {
            trigger_delay = 0.5,
            stamina_sprint_drain = tonumber(core.settings:get("stamina_sprint_drain")) or 0.35,
            move_exhaust = 1.5,
            enable_stamina = core.settings:get_bool("enable_stamina", true),
            treshold = 6,
            extra_speed = 0.3
        }
    else
        settings = {
            trigger_delay = 0.5,
            treshold = (tonumber(core.settings:get("stamina.starve_lvl")) * 2) or 6,
            stamina_sprint_drain = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28,
            move_exhaust = tonumber(core.settings:get("stamina.exhaust_move")) or 0.5,
            enable_stamina = true,
            extra_speed = 0.3
        }
    end
elseif hunger_is_installed then
--need to implent this still
end

        
return settings