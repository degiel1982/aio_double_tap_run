-- Use Mod Storage for saving stamina levels
local mod_storage = core.get_mod_storage()

--[[ GET MOD AUTHOR ]]
local function get_mod_author(modname)
    local modpath = core.get_modpath(modname)
    if not modpath then
        return nil, "Mod not found"
    end

    local mod_conf = Settings(modpath .. "/mod.conf")
    if not mod_conf then
        return nil, "mod.conf not found"
    end

    local author = mod_conf:get("author")
    if author then
        return author
    else
        return nil, "Author field not found in mod.conf"
    end
end

local mod_settings = {} -- Global settings
local stamina_is_installed = core.get_modpath("stamina") ~= nil
local mod_author = ""
if stamina_is_installed then
    mod_author = get_mod_author("stamina")
    if mod_author == "TenPlus1" then
        mod_settings.sprint_speed = tonumber(core.settings:get("stamina_sprint_speed")) or 0.3
        mod_settings.enable_drain = core.settings:get_bool("enable_stamina", true)
        aio_double_tap_run.set_sprint_speed(mod_settings.sprint_speed)
        mod_settings.sprint_exhaust = tonumber(core.settings:get("stamina_sprint_drain")) or 0.35
        mod_settings.sprint_exhaust = mod_settings.sprint_exhaust * 100
        mod_settings.treshold = tonumber(core.settings:get("aio_double_tap_run.stamina_treshold")) or 6 
    elseif mod_author == "sofar" then
        mod_settings.sprint_exhaust = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28
        mod_settings.sprint_exhaust = mod_settings.sprint_exhaust * 2
        mod_settings.treshold = tonumber(core.settings:get("stamina.starve_lvl")) or 3
        mod_settings.treshold = mod_settings.treshold * 2
        mod_settings.enable_drain = core.settings:get_bool("stamina.enabled", true)
        mod_settings.enable_sprint = core.settings:get_bool("stamina.sprint", true)
        mod_settings.should_drain = function(control, sprint_setting)
            if sprint_setting then
                if not control then
                    return true
                end
            else
                return true
            end
            return false
        end
    end
end

-- Register callback for double-tap detection
aio_double_tap_run.register_dt_data_callback(function(player, filtered_data, dtime)
    local player_name = player:get_player_name()
    local control = player:get_player_control()
    local current_saturation = stamina.get_saturation(player) or 0  -- Fallback if nil
    if current_saturation <= mod_settings.treshold then
        aio_double_tap_run.add_to_cancel_list(player_name, "STARVING")
    end
    if mod_author == "sofar" then
        if mod_settings.enable_drain then
            if filtered_data.dt_detected and filtered_data.key == "FORWARD" and mod_settings.should_drain(control.aux1, mod_settings.enable_sprint)  then
                stamina.exhaust_player(player, (mod_settings.sprint_exhaust) * dtime) 
            end
        end
    end
    if filtered_data.dt_detected and mod_settings.enable_drain and  mod_author == "TenPlus1" then
        stamina.exhaust_player(player, (mod_settings.sprint_exhaust) * dtime) 
    end
end)


