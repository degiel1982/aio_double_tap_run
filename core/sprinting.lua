local mod_name = aio_double_tap_run.mod_name
local aio = aio_double_tap_run.physics
local EXTRA_SPEED = aio_double_tap_run.settings.extra_speed

aio_double_tap_run.register_callback(function(player, data, dtime)
    if not aio_double_tap_run.is_player(player) then return nil end
    if not data.cancel_sprint then
        if data.detected then
            aio.sprint(player, true, EXTRA_SPEED)
           if not data.is_sprinting then
               data.is_sprinting = true
           end
        else
           if aio.pova_is_installed then
                aio.sprint(player, false)
            end
            if data.is_sprinting then
                data.is_sprinting = false
            end
        end
    else
        if aio.pova_is_installed then
            aio.sprint(player, false)
        end
        if data.is_sprinting then
            data.is_sprinting = false
        end
    end
    return data
end)

