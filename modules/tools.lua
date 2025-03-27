
-- Liquid check
local function player_is_in_liquid(pos)
    local feet_pos = { x = pos.x, y = pos.y - 0.5, z = pos.z }
    local head_pos = { x = pos.x, y = pos.y + 0.85, z = pos.z }
    local check_positions = { vector.round(feet_pos), vector.round(head_pos) }
    for _, p in ipairs(check_positions) do
        local node = core.get_node_or_nil(p)
        if node then
            local nodedef = core.registered_nodes[node.name]
            if nodedef and nodedef.liquidtype and nodedef.liquidtype ~= "none" then
                return true
            end
        end
    end
    return false
end


local function dt_sensor(dt_state, dtime, key_pressed, trigger_delay)
    if not dt_state.sprinting then
        if dt_state.count > 0 then
            dt_state.timer = dt_state.timer + dtime
        end

        if key_pressed and not dt_state.was_up then
            dt_state.count = dt_state.count + 1
            if dt_state.count == 1 then
                dt_state.timer = 0
            end
        end

        dt_state.was_up = key_pressed

        if dt_state.timer > trigger_delay then
            dt_state.count = 0
            dt_state.timer = 0
        end

        if dt_state.count == 2 and dt_state.timer <= trigger_delay then
            dt_state.sprinting = true
        end
    else
        if not key_pressed then
            dt_state.sprinting = false
            dt_state.count = 0
            dt_state.timer = 0
        end
    end

    return dt_state.sprinting
end

return player_is_in_liquid, dt_sensor
