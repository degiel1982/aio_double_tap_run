local optional_mods = {}

-- Check for stamina mod
local stamina_is_installed = minetest.get_modpath("stamina") ~= nil

if stamina_is_installed then
    -- Check for Tenplus1s' stamina fork module
    if stamina and type(stamina.change) == "function" then
        optional_mods.tenplus1_stamina = {
            change_saturation = stamina.change,
            stamina_drain_points = 0.3
        }
    end
    -- Check for Sofar's stamina module
    if stamina and type(stamina.change_saturation) == "function" then
        optional_mods.sofar_stamina = {
            is_sprinting_enabled = core.settings:get_bool("stamina.sprint", true),
            is_stamina_enabled = core.settings:get_bool("stamina.enabled", true),
            change_saturation = stamina.exhaust_player,
            stamina_drain_points = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28.0,
            set_sprinting = stamina.set_sprinting,
            get_saturation = stamina.get_saturation,
            stamina_starve_lvl = tonumber(core.settings:get("stamina.starve_lvl")) or 3
        }
    end
end

local hungerNG_is_installed = minetest.get_modpath("hunger_ng") ~= nil
if hungerNG_is_installed then
    optional_mods.hunger_ng = {
        change = hunger_ng.alter_hunger,
        get_hunger_info = hunger_ng.get_hunger_information,
        treshold = 3,
    }
end

return optional_mods