local set_sprinting = dofile(core.get_modpath("aio_double_tap_run") .. "/functions/physics.lua")
local mod_settings = dofile(core.get_modpath("aio_double_tap_run") .. "/functions/mod_settings.lua")
local player_double_tap = {}
local dt_data = {}
local function is_player_fully_submerged_in_water(player)
    local pos = player:get_pos()
    local props = player:get_properties()
    local cb = props.collisionbox 
    local minp = vector.floor(vector.add(pos, { x = cb[1], y = cb[2], z = cb[3] }))
    local maxp = vector.ceil(vector.add(pos, { x = cb[4], y = cb[5], z = cb[6] }))

    for x = minp.x, maxp.x do
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                local npos = { x = x, y = y, z = z }
                local node = minetest.get_node_or_nil(npos)
                if not node then
                    
                    return false
                end

                local nodedef = minetest.registered_nodes[node.name]

                if not nodedef or not nodedef.liquidtype or nodedef.liquidtype == "none" then
                    return false
                end
            end
        end
    end

    return true
end
local function cancel_run(p_pos, player)
    local name = player:get_player_name()
    --[[ LIQUID CHECK ]]
    if mod_settings.fly_swim then
        if mod_settings.tools.player_is_in_liquid(p_pos,player) then
            if not is_player_fully_submerged_in_water(player) then
                return true
            end
        end
    elseif mod_settings.tools.player_is_in_liquid(p_pos,player) and not mod_settings.liquid_sprint then
        return true
    end
    --[[ STARVE CHECK ]]
    --STAMINA
    if mod_settings.stamina_drain then
        if stamina then
            local treshold = 0
            local curent_saturation = stamina.get_saturation(player)
            if mod_settings.stamina.sofar.installed then
                treshold = mod_settings.stamina.sofar.treshold * 2
            elseif mod_settings.stamina.tenplus.installed then
                treshold = stamina.STARVE_LVL * 2
            end
            if treshold ~= nil then
                player_double_tap[name].starving = mod_settings.tools.is_player_starving(curent_saturation, treshold)
            end
            if player_double_tap[name].starving then
                return true
            end        
        end
        --HUNGER_NG
        if mod_settings.hunger_ng.installed and mod_settings.stamina_drain then
            local info = hunger_ng.get_hunger_information(name)
            if not info.invalid then
                if info.hunger.exact <= mod_settings.hunger_ng.treshold then
                    return true
                end
            end
        end
    end

    --[[LADDER CHECK]]
    if mod_settings.tools.is_player_on_ladder(player) and not mod_settings.ladder_sprint then
        return true
    end
    --[[WALL CHECK]]
    if mod_settings.tools.is_player_running_against_wall(player) then
        return true
    end

    --[[RETURN VALUE: FALSE]]
    return false
end

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil  
end)


core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name = player:get_player_name()
        if not player_double_tap[name] then
            player_double_tap[name] = mod_settings.player_data
        end
        local control_bits = player:get_player_control_bits()
        local pos = player:get_pos()
        local cancel_run = cancel_run(pos, player)
        player_double_tap[name].running = mod_settings.tools.sprint_key_activated( mod_settings.use_aux, mod_settings.use_dt,control_bits, player_double_tap[name], dtime, mod_settings.tap_interval, mod_settings.tools.dt_sensor, name) and not cancel_run and not player_double_tap[name].running
        if player_double_tap[name].running then
            set_sprinting(player, true, mod_settings.extra_speed)
            if mod_settings.enable_particles and not mod_settings.stamina.sofar.installed then
                mod_settings.tools.sprint_particles(player)
            end
            if mod_settings.stamina_drain then
                if mod_settings.stamina.sofar.installed then
                      stamina.exhaust_player(player, (mod_settings.stamina.sofar.exhaust_sprint*2) * dtime)
                elseif mod_settings.stamina.tenplus.installed then
                      stamina.exhaust_player(player, (stamina.SPRINT_DRAIN * 100) * dtime)
                elseif mod_settings.hunger_ng.installed then
                      hunger_ng.alter_hunger(name, -mod_settings.hunger_ng.exhaust_sprint * dtime, 'Sprinting') 
                end
            end
            if mod_settings.enable_animation and mod_settings.character_anim then
                  local current_animation = player:get_animation()
                  local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
                  local sprint_speed = mod_settings.sprint_framespeed + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
                  player:set_animation(animation_range, sprint_speed, 0)
            end
        else
            if mod_settings.pova.installed then
                set_sprinting(player, false)
            end
            if mod_settings.enable_animation and mod_settings.character_anim then
                local current_animation = player:get_animation()
                local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
                local sprint_speed = mod_settings.walk_framespeed + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
                player:set_animation(animation_range, sprint_speed, 0)
            end
            if mod_settings.stamina_drain then
                if mod_settings.stamina.sofar.installed then
                    stamina.exhaust_player(player, mod_settings.stamina.sofar.exhaust_move * dtime)
                elseif mod_settings.stamina.tenplus.installed then
                    stamina.exhaust_player(player, mod_settings.stamina.tenplus.exhaust_move * dtime)
                end
            end
        end
    end
end)