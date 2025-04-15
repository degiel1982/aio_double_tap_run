
local ENABLE_ANIMATION = aio_double_tap_run.settings.animations
local SPRINT_FRAMESPEED = aio_double_tap_run.settings.sprint_speed
local WALK_FRAMESPEED = aio_double_tap_run.settings.walk_speed

aio_double_tap_run.register_callback(function(player, data, dtime)
    local player_name = player:get_player_name()
   
    if data.is_sprinting then
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
