local player_is_in_liquid, dt_sensor, get_mod_author, is_player_starving,is_player_on_ladder,is_player_on_climbable = dofile(core.get_modpath("aio_double_tap_run").."/functions/tools.lua")

local settings = {
    tap_interval = tonumber(core.settings:get("aio_dt.tap_interval")) or 0.5,
    use_aux = core.settings:get_bool("aio_dt.use_aux", false),
    use_dt = core.settings:get_bool("aio_dt.use_dt", true), 
    walk_framespeed = tonumber(core.settings:get("aio_dt.walk_frames")) or 15,
    sprint_framespeed = tonumber(core.settings:get("aio_dt.sprint_frames")) or 30,
    ladder_sprint =  core.settings:get_bool("aio_dt.ladder_sprint", false),
    tools = {
        player_is_in_liquid = player_is_in_liquid,
        dt_sensor = dt_sensor,
        is_player_starving = is_player_starving,
        is_player_on_ladder = is_player_on_climbable
    },
    extra_speed = tonumber(core.settings:get("aio_dt.extra_speed")) or 0.5,
    character_anim = core.get_modpath("character_anim") ~= nil,
    pova = {
        installed = core.get_modpath("pova") ~= nil
    },
    player_monoids = {
        installed = core.get_modpath("player_monoids") ~= nil
    },
    stamina ={
        tenplus = {
            installed = false,
            exhaust_sprint = tonumber(core.settings:get("stamina_sprint_drain")) or 0.35,
            exhaust_move = 1.5,
            treshold = 6,
            extra_speed = 0.3,
        },
        sofar = {
            installed = false,
            exhaust_sprint = tonumber(core.settings:get("stamina.exhaust_sprint")) or 28,
            exhaust_move = tonumber(core.settings:get("stamina.exhaust_move")) or 0.5,
            extra_speed = tonumber(core.settings:get("stamina.sprint_speed")) or 0.8,
            treshold = tonumber(core.settings:get("stamina.starve_lvl")) or 3,
        }
    },
    hunger_ng = {
        installed = core.get_modpath("hunger_ng") ~= nil
    },
}

local stamina_is_installed = core.get_modpath("stamina") ~= nil
if stamina_is_installed then
    local mod_author = get_mod_author("stamina")
    if mod_author == "TenPlus1" then
        settings.stamina.tenplus.installed = true
    end
    if mod_author == "sofar" then 
        settings.stamina.sofar.installed = true
    end
end

return settings
