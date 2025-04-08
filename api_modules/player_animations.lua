local ENABLE_ANIMATION = core.settings:get_bool("aio_double_tap_run.enable_animations", true) 
local SPRINT_FRAMESPEED = tonumber(core.settings:get("aio_double_tap_run.sprint_framespeed")) or 30
local WALK_FRAMESPEED = tonumber(core.settings:get("aio_double_tap_run.walk_framespeed")) or 15


-- Register callback for double-tap detection
aio_double_tap_run.register_dt_data_callback(function(player, filtered_data, dtime)
    local player_name = player:get_player_name()
    local control = player:get_player_control()
    if filtered_data.dt_detected then
        if ENABLE_ANIMATION then
            local current_animation = player:get_animation()
            local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
            local sprint_speed = SPRINT_FRAMESPEED + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
            player:set_animation(animation_range, sprint_speed, 0)
        end
    else
        if ENABLE_ANIMATION then
            local current_animation = player:get_animation()
            local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
            local walk_speed = WALK_FRAMESPEED + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
            player:set_animation(animation_range, walk_speed, 0)
        end
    end
end)


