local stamina_is_installed = core.get_modpath("stamina") ~= nil
local hunger_is_installed = core.get_modpath("hunger_ng") ~= nil
local settings = {}



if stamina_is_installed then
    settings = {
        trigger_delay = 0.5,
        stamina_sprint_drain = tonumber(core.settings:get("stamina_sprint_drain")) or 0.35,
        move_exhaust = 1.5,
        enable_stamina = core.settings:get_bool("enable_stamina", true),
        treshold = 6
    }
elseif hunger_is_installed then

end

        
end