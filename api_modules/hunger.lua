local hunger_ng_treshold = tonumber(core.settings:get("aio_double_tap_run.hunger_treshold")) or 6
local ENABLE_STARVE = core.settings:get_bool("aio_double_tap_run.starve_check", true)
local ENABLE_DRAIN = core.settings:get_bool("aio_double_tap_run.enable_stamina_drain", true)

-- Register callback for double-tap detection
aio_double_tap_run.register_dt_data_callback(function(player, filtered_data, dtime)
    local player_name = player:get_player_name()
    local control = player:get_player_control()
    if ENABLE_STARVE then
        local info = hunger_ng.get_hunger_information(player_name)
        if not info.invalid then
            if info.hunger.exact <= hunger_ng_treshold then
                aio_double_tap_run.add_to_cancel_list(player_name, "HUNGER")
            end
        end

    end
    if filtered_data.dt_detected then
        if ENABLE_DRAIN then
            hunger_ng.alter_hunger(player_name, -(0.5 * dtime), 'Sprinting')
        end 
    end
end)
