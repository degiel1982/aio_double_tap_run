--[[
    CORE ESSENTIALS
]]

local mod_name = core.get_current_modname()

aio_double_tap_run = {
    mod_name = core.get_current_modname(),
    physics = dofile(core.get_modpath(mod_name) .. "/core/physics.lua"),
    is_player = function(player)
        if player and type(player) == "userdata" and core.is_player(player) then
            return true
        end 
    end,
    settings = {
        extra_speed = tonumber(core.settings:get(mod_name .. ".extra_speed")) or 0.8,
        liquid_check = core.settings:get_bool(mod_name ..".liquid_check", true),
        wall_check = core.settings:get_bool(mod_name ..".wall_check", true),
        climbable_check = core.settings:get_bool(mod_name ..".climbable_check", true),
        snow_check= core.settings:get_bool(mod_name ..".snow_check", true),
        fly_check = core.settings:get_bool(mod_name ..".fly_check", false),
        health_check = core.settings:get_bool(mod_name ..".health_check", true),
        health_threshold = tonumber(core.settings:get(mod_name ..".health_threshold")) or 6,
        swim_enable = core.settings:get_bool(mod_name ..".enable_swim", true),
        crouch_check = core.settings:get_bool(mod_name ..".crouch_check", false),
        backward_check = core.settings:get_bool(mod_name ..".disable_backwards_sprint", true),
        enable_aux = core.settings:get_bool(mod_name..".enable_aux", false),
        enable_tap = core.settings:get_bool(mod_name..".enable_dt", true),
        walk_speed = tonumber(core.settings:get(mod_name ..".walk_framespeed")) or 15,
        sprint_speed= tonumber(core.settings:get(mod_name ..".sprint_framespeed")) or 30,
        animations = core.settings:get_bool(mod_name ..".enable_animations", true),
        particles = core.settings:get_bool(mod_name ..".particles", true),
    }
}

dofile(core.get_modpath(mod_name) .. "/core/keyboard.lua")
dofile(core.get_modpath(mod_name) .. "/core/sprint_particles.lua")
dofile(core.get_modpath(mod_name) .. "/core/cancelations.lua")
dofile(core.get_modpath(mod_name) .. "/core/sprinting.lua")


--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--  ADDONS: Modules that extends the core


--[[
    STAMINA
]]
aio_double_tap_run.hbhunger = core.get_modpath("hbhunger") and core.global_exists("hbhunger") ~= nil
aio_double_tap_run.hunger_ng = core.get_modpath("hunger_ng") and core.global_exists("hunger_ng") ~= nil
aio_double_tap_run.stamina = core.get_modpath("stamina") and core.global_exists("stamina") ~= nil
aio_double_tap_run.wuzzy = core.get_modpath("hudbars") and core.global_exists("hudbars") ~= nil
if aio_double_tap_run.stamina then
    dofile(core.get_modpath(mod_name) .. "/addons/stamina.lua")
elseif aio_double_tap_run.hunger_ng then
    dofile(core.get_modpath(mod_name) .. "/addons/hunger_ng.lua")
elseif aio_double_tap_run.hbhunger then
    dofile(core.get_modpath(mod_name) .. "/addons/hbhunger.lua")
else
    local show_fatigue = core.settings:get_bool(mod_name .. ".enable_fatigue", true)
    if show_fatigue and not core.settings:get_bool("creative_mode", false) then
        if aio_double_tap_run.wuzzy then
            dofile(core.get_modpath(mod_name) .. "/addons/wuzzy_hudbar.lua")
        else
            dofile(core.get_modpath(mod_name) .. "/core/ad_sprint.lua")
        end
    end
end

aio_double_tap_run.character_anim = core.get_modpath("character_anim") ~= nil
if aio_double_tap_run.character_anim then
    dofile(core.get_modpath(mod_name) .. "/addons/character_anim.lua")
end




if core.get_modpath("beds") and core.global_exists("beds") ~= nil then
    local bed_nodes = {
        "beds:bed",
        "beds:fancy_bed",
    }

    for _, bed_node in ipairs(bed_nodes) do
        local original_on_right_click = core.registered_nodes[bed_node].on_rightclick
        local updated_bed_definition = {
            on_rightclick = function(pos, node, player, itemstack, pointed_thing)
                local ctrl = player:get_player_control()
                if not ctrl.aux1 then
                    if original_on_right_click then
                        original_on_right_click(pos, node, player, itemstack, pointed_thing)
                    end
                else
                    core.chat_send_player(player:get_player_name(), "Release the sprint key first")
                end
            end
        }
        core.override_item(bed_node, updated_bed_definition)
    end
end
