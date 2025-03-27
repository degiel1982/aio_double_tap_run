-- Load the mod_checker module to check for installed mods and retrieve configuration values
local mod, dt_off = dofile(core.get_modpath("aio_double_tap_run").."/modules/mod_checker.lua")

-- If no compatible mod is installed and double-tap is not disabled, load the default no_mod_tap module
if mod == "no_mod" then
    dofile(core.get_modpath("aio_double_tap_run").."/tap_control_per_mod/my_tap.lua")
end

-- If the "sofar_stamina" mod is installed and double-tap is not disabled, load the sofar_tap module
if mod == "stamina" and not dt_off then
    dofile(core.get_modpath("aio_double_tap_run").."/tap_control_per_mod/my_tap.lua")
end

-- If the "hunger_ng" mod is installed and double-tap is not disabled, load the hunger_tap module
if mod == "hunger_ng" and not dt_off then
    dofile(core.get_modpath("aio_double_tap_run").."/tap_control_per_mod/hunger_tap.lua")
end


if dt_off then
    core.log("action", "[AIO] Double-tap has been disabled due to multiple mods being installed.")
end
