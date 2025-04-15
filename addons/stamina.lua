local mod_name = aio_double_tap_run.mod_name
local functions = dofile(core.get_modpath(mod_name) .. "/core/functions.lua")
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

local stamina_is_installed = aio_double_tap_run.stamina

local mod_author = ""
if stamina_is_installed then
    mod_author = get_mod_author("stamina")
    if mod_author == "TenPlus1" then
        mod_settings.enable_drain = core.settings:get_bool("enable_stamina", true)
        mod_settings.sprint_exhaust = tonumber(core.settings:get("stamina_sprint_drain")) or 0.35
        mod_settings.sprint_exhaust = mod_settings.sprint_exhaust * 100
        mod_settings.treshold = tonumber(core.settings:get("aio_double_tap_run.stamina_treshold")) or 6 
        stamina.enable_sprint = false
        stamina.enable_sprint_particles = false
    elseif mod_author == "sofar" then
        mod_settings.enable_drain = core.settings:get_bool("stamina.enabled", true)
        mod_settings.sprint_exhaust = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28
        mod_settings.sprint_exhaust = mod_settings.sprint_exhaust * 2
        mod_settings.treshold = tonumber(core.settings:get("stamina.starve_lvl")) or 3
        mod_settings.treshold = mod_settings.treshold * 2
        mod_settings.enable_sprint = core.settings:get_bool("stamina.sprint", true)
        aio_double_tap_run.settings.extra_speed = tonumber(core.settings:get("stamina.sprint_speed")) or 0.8
        aio_double_tap_run.settings.enable_aux = false
        aio_double_tap_run.settings.particles = core.settings:get_bool("stamina.sprint_particles", true)
     
    end
end



-- Register callback for double-tap detection
aio_double_tap_run.register_callback(function(player, data, dtime)
    if not aio_double_tap_run.is_player(player) then return nil end
    local player_name = player:get_player_name()
    local control = player:get_player_control()

    local current_saturation = stamina.get_saturation(player) or 0  -- Fallback if nil
    if (current_saturation <= mod_settings.treshold) then
        data.cancel_sprint = true
    end

    if data.cancel_sprint then
        stamina.set_sprinting(player, false)
        return data
    end

    if mod_author == "sofar" then
        if mod_settings.enable_drain then
            if data.is_sprinting and not functions.in_air(player,1) and not functions.wall_bump(player) then
                stamina.exhaust_player(player, (mod_settings.sprint_exhaust) * dtime) 
            end
        end
    elseif mod_author == "TenPlus1" and not functions.in_air(player,1) and not functions.wall_bump(player) then
        if mod_settings.enable_drain then
            if data.is_sprinting then
                stamina.exhaust_player(player, (mod_settings.sprint_exhaust) * dtime) 
            end
        end
    end
    local control = player:get_player_control()
    if control.down and mod_author == "sofar" then
        stamina.set_sprinting(player, false)
    end
    return nil
end)

