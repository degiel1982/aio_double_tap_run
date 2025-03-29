local player_is_in_liquid, dt_sensor, get_mod_author, is_player_starving = dofile(core.get_modpath("aio_double_tap_run").."/functions/tools.lua")

local aio_double_tap_run = {
    use_aux = core.settings:get_bool("aio_dt.use_aux", false),
    tools = {
        player_is_in_liquid = player_is_in_liquid,
        dt_sensor = dt_sensor,
        is_player_starving = is_player_starving,
    },
    extra_speed = tonumber(core.settings:get("aio_dt.extra_speed")) or 0.5,
    character_anim = core.get_modpath("character_anim") ~= nil,
    mod_settings = {
        pova = {
            installed = false
        },
        player_monoids = {
            installed = false
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
            installed = false
        },
        
    }
}


aio_double_tap_run.mod_settings.hunger_ng.installed = core.get_modpath("hunger_ng") ~= nil

local stamina_is_installed = core.get_modpath("stamina") ~= nil
if stamina_is_installed then
    local mod_author = get_mod_author("stamina")
    if mod_author == "TenPlus1" then
        aio_double_tap_run.mod_settings.stamina.tenplus.installed = true
    end
    if mod_author == "sofar" then 
        aio_double_tap_run.mod_settings.stamina.sofar.installed = true
    end
end

aio_double_tap_run.mod_settings.pova.installed = core.get_modpath("pova") ~= nil
aio_double_tap_run.mod_settings.player_monoids.installed = core.get_modpath("player_monoids") ~= nil


return aio_double_tap_run
