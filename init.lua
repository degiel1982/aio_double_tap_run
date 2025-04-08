aio_double_tap_run = {}

local SPRINT_STATES = {}

aio_double_tap_run.sprint_speed = tonumber(core.settings:get("aio_double_tap_run.extra_speed")) or 0.8 


core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    SPRINT_STATES[player_name] = nil
end)

dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/sprint_particles.lua")
dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/double_tap_trigger.lua")
dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/cancel_tools.lua")
dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/set_sprinting.lua")


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
local IS_SOFAR_SPRINT_ENABLED = false
local SHOW_SPRINT_PARTICLES = false
if stamina_is_installed then
    mod_author = get_mod_author("stamina")
    if mod_author == "TenPlus1" then
        SHOW_SPRINT_PARTICLES = core.settings:get_bool("sprint_particles", true)
    end    
    if mod_author == "sofar" then
        SHOW_SPRINT_PARTICLES = core.settings:get_bool("sprint_particles", true)
    end
else
    SHOW_SPRINT_PARTICLES = core.settings:get_bool("aio_double_tap_run.particles", true)
end

if stamina_is_installed then
    if mod_author == "TenPlus1" then
        IS_TENPLUS_SPRINT_ENABLED = core.settings:get_bool("sprint", true)
        if IS_TENPLUS_SPRINT_ENABLED then
            aio_double_tap_run.set_aux_enabled(true)
        else
            aio_double_tap_run.set_aux_enabled(false)
        end
        stamina.enable_sprint = false
    end    
    if mod_author == "sofar" then
        IS_SOFAR_SPRINT_ENABLED = core.settings:get_bool("stamina.sprint", true)
    end
end

aio_double_tap_run.register_dt_data_callback(function(player, filtered_data, dtime)
    local player_name = player:get_player_name()
    local control = player:get_player_control()

    if not SPRINT_STATES[player_name] then
        SPRINT_STATES[player_name] = {}
    end
    if mod_author ~= "sofar" then
        if filtered_data.dt_detected and filtered_data.key == "FORWARD" then
                aio_double_tap_run.set_sprinting(player, true, aio_double_tap_run.sprint_speed)
                SPRINT_STATES[player_name] = true
                if SHOW_SPRINT_PARTICLES then
                    aio_double_tap_run.show_particles(player)
                end
        elseif filtered_data.dt_detected and filtered_data.key == "AUX1" then
                aio_double_tap_run.set_sprinting(player, true, aio_double_tap_run.sprint_speed)
                SPRINT_STATES[player_name] = true
                if SHOW_SPRINT_PARTICLES then
                    aio_double_tap_run.show_particles(player)
                end
        elseif not filtered_data.dt_detected and filtered_data.key == "CANCELLED" then
            if SPRINT_STATES[player_name] then
                aio_double_tap_run.set_sprinting(player, false)
                SPRINT_STATES[player_name] = false
            end
        elseif filtered_data.dt_detected and filtered_data.key == "CANCELLED" then
            if SPRINT_STATES[player_name] then
                aio_double_tap_run.set_sprinting(player, false)
                SPRINT_STATES[player_name] = false
            end
        elseif not filtered_data.dt_detected and filtered_data.key == "NO_KEY" then
            if SPRINT_STATES[player_name] then
                aio_double_tap_run.set_sprinting(player, false)
                SPRINT_STATES[player_name] = false
            end
        end
    else
        if filtered_data.dt_detected and filtered_data.key == "FORWARD" then
            stamina.set_sprinting(player, true)
            SPRINT_STATES[player_name] = true
        elseif not filtered_data.dt_detected then
            if not IS_SOFAR_SPRINT_ENABLED then
                if SPRINT_STATES[player_name] then
                    stamina.set_sprinting(player, false)
                    SPRINT_STATES[player_name] = false
                end
            end
        end
    end
end)

if core.get_modpath("stamina") ~= nil then
    dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/stamina.lua")
end
if core.get_modpath("hunger_ng") ~= nil then
    dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/hunger.lua")
end
if core.get_modpath("character_anim") ~= nil then
    dofile(core.get_modpath("aio_double_tap_run") .. "/api_modules/player_animations.lua")
end
