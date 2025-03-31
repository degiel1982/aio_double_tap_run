local set_sprinting, mod_settings = dofile(core.get_modpath("aio_double_tap_run") .. "/functions/physics.lua")
local player_double_tap = {}
aio_double_tap_run = {}
aio_double_tap_run.set_sprinting = set_sprinting

local function cancel_run(p_pos, player)
    local cancel_run = false
    local name = player:get_player_name()
    --when in liquid
    if mod_settings.tools.player_is_in_liquid(p_pos,player) then
        cancel_run = true
    end
    --when starving
    if (mod_settings.stamina.sofar.installed or mod_settings.stamina.tenplus.installed) and mod_settings.stamina_drain then
        if mod_settings.stamina.sofar.installed then
            player_double_tap[name].starving = mod_settings.tools.is_player_starving(
                stamina.get_saturation(player),
                mod_settings.stamina.sofar.treshold * 2
            )
        end
        if mod_settings.stamina.tenplus.installed then
            player_double_tap[name].starving = mod_settings.tools.is_player_starving(
                stamina.get_saturation(player),
                mod_settings.stamina.tenplus.treshold
            )
        end

        if player_double_tap[name].starving then
            cancel_run = true
        end
    end
    if mod_settings.hunger_ng.installed then
        local info = hunger_ng.get_hunger_information(name)
        if not info.invalid then
            -- Cancel sprinting if hunger is below the threshold
            if info.hunger.exact <= mod_settings.hunger_ng.treshold then
                if player_double_tap[name].running then
                    player_double_tap[name].running = false
                end
            end
        end
    end
    -- If the player is standing on a ladder, cancel sprinting
    if mod_settings.tools.is_player_on_ladder(player) and not mod_settings.ladder_sprint then
        cancel_run = true
    end

    if mod_settings.tools.is_player_running_against_wall(player) then
        cancel_run = true
    end
    return cancel_run
end

core.register_on_mods_loaded(function()
    local has_beds = minetest.get_modpath("beds") ~= nil
    if has_beds then
        -- List the node names for the bed(s) you want to target.
        local bed_nodes = {
            "beds:bed",
            "beds:fancy_bed"
        }
    
        for _, bed_node in ipairs(bed_nodes) do
            if minetest.registered_nodes[bed_node] then
                local original_on_rightclick = minetest.registered_nodes[bed_node].on_rightclick
    
                minetest.override_item(bed_node, {
                    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
                        local pname = clicker:get_player_name()
                        set_sprinting(clicker, false)
                        if original_on_rightclick then
                            return original_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
                        end
                    end,
                })
            end
        end
    end
end)



local function show_sprint_particles(player)
    local pos = player:get_pos()
    local node = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    local def = minetest.registered_nodes[node.name] or {}
    local drawtype = def.drawtype
    if drawtype ~= "airlike" and drawtype ~= "liquid" and drawtype ~= "flowingliquid" then
        minetest.add_particlespawner({
            amount = 5,
            time = 0.01,
            minpos = {x = pos.x - 0.25, y = pos.y + 0.1, z = pos.z - 0.25},
            maxpos = {x = pos.x + 0.25, y = pos.y + 0.1, z = pos.z + 0.25},
            minvel = {x = -0.5, y = 1, z = -0.5},
            maxvel = {x = 0.5, y = 2, z = 0.5},
            minacc = {x = 0, y = -5, z = 0},
            maxacc = {x = 0, y = -12, z = 0},
            minexptime = 0.25,
            maxexptime = 0.5,
            minsize = 0.5,
            maxsize = 1.0,
            vertical = false,
            collisiondetection = false,
            texture = "default_dirt.png",
        })
    end
end


local player_data = {
    count = 0,
    timer = 0,
    was_up = false,
    sprinting = false,
    wet = false,
    running = false,
    starving = false
}

core.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_double_tap[name] = nil  -- Remove double tap state info.
end)

core.register_globalstep(function(dtime)
    local players = core.get_connected_players()
    for _, player in ipairs(players) do
        local name = player:get_player_name()
        local p_pos = player:get_pos()
    
        if not player_double_tap[name] then
            player_double_tap[name] = player_data
        end

        local pos = player:get_pos()

        if cancel_run(pos, player) == false then
            local control_bits = player:get_player_control_bits()
            local key_is_pressed = control_bits == 1 or control_bits == 17
            if mod_settings.use_dt then
                if mod_settings.use_aux then
                    player_double_tap[name].running = mod_settings.tools.dt_sensor(
                        player_double_tap[name], dtime, key_is_pressed, mod_settings.tap_interval
                    ) or (control_bits == 33 or control_bits == 49)
                else
                    player_double_tap[name].running = mod_settings.tools.dt_sensor(
                        player_double_tap[name], dtime, key_is_pressed, mod_settings.tap_interval
                    )
                end
            else
                if mod_settings.use_aux then
                    local key_press = (control_bits == 33 or control_bits == 49)
                    player_double_tap[name].running = key_press
                end
            end
        else
            player_double_tap[name].running = false
        end
        if player_double_tap[name].running then
            set_sprinting(player, true)
            if not mod_settings.stamina.sofar.installed and not mod_settings.stamina.tenplus.installed and mod_settings.enable_particles then
                show_sprint_particles(player)
            end
            if mod_settings.stamina.sofar.installed and mod_settings.stamina_drain then
                stamina.exhaust_player(player, mod_settings.stamina.sofar.exhaust_sprint * dtime)
            end
            if mod_settings.stamina.tenplus.installed and mod_settings.stamina_drain then
                stamina.exhaust_player(player, (mod_settings.stamina.tenplus.exhaust_sprint * 100) * dtime)
            end
            if mod_settings.hunger_ng.installed then
                hunger_ng.alter_hunger(name, -mod_settings.hunger_ng.exhaust_sprint * dtime, 'Sprinting') 
            end
            if mod_settings.enable_animation and mod_settings.character_anim then
                local current_animation = player:get_animation()
                local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
                local sprint_speed = mod_settings.sprint_framespeed + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
                player:set_animation(animation_range, sprint_speed, 0)
            end
        else
            if not mod_settings.stamina.tenplus.installed then
                if mod_settings.pova.installed or (mod_settings.pova.installed == false and mod_settings.player_monoids.installed == false) then
                    set_sprinting(player, false)
                    if mod_settings.stamina.sofar.installed and mod_settings.stamina_drain then
                        stamina.exhaust_player(player, mod_settings.stamina.sofar.exhaust_move * dtime)
                    end
                    if mod_settings.stamina.tenplus.installed and mod_settings.stamina_drain then
                        stamina.exhaust_player(player, mod_settings.stamina.tenplus.exhaust_move * dtime)
                    end
                end
            end
            if mod_settings.enable_animation and mod_settings.character_anim then
                local current_animation = player:get_animation()
                local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
                local sprint_speed = mod_settings.walk_framespeed + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
                player:set_animation(animation_range, sprint_speed, 0)
            end
        end
    
    end
end)