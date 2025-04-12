local mod_name = aio_double_tap_run.mod_name

local settings = {
    texture = "smoke_puff.png",
}

if core.get_modpath("xcompat") and core.global_exists("xcompat") then
    if core.get_game_info().id == "minetest" or core.get_game_info().id == "farlands_reloaded" then
        settings.texture = xcompat.textures.grass.dirt
    else
        settings.texture = "smoke_puff.png"
    end
else
    if core.get_game_info().id == "minetest" then
        settings.texture = "default_dirt.png"
    else
        settings.texture = "smoke_puff.png"
    end
end

local function show_particles(player)
    local pos = player:get_pos()
    local node = core.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
    local def = core.registered_nodes[node.name] or {}
    local drawtype = def.drawtype
    if drawtype ~= "airlike" and drawtype ~= "liquid" and drawtype ~= "flowingliquid" then
        core.add_particlespawner({
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
            texture = settings.texture
        })
    end
end

local particle_timers = {} 

aio_double_tap_run.register_callback(function(player, data, dtime)
    if not aio_double_tap_run.is_player(player) then return nil end
        local name = player:get_player_name()

        if not particle_timers[name] then
            particle_timers[name] = 0
        end

        particle_timers[name] = particle_timers[name] + dtime

        if data.is_sprinting and particle_timers[name] >= 0.2 then
            if aio_double_tap_run.settings.particles then
                show_particles(player)
            end
            particle_timers[name] = 0 
        end
    return nil
end)

core.register_on_leaveplayer(function(player)
    local player_name = player:get_player_name()
    particle_timers[player_name] = nil
end)
