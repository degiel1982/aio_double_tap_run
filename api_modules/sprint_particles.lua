--[[
    SPRINT PARTICLES:
]]

local game_textures = {}
local texture = "combine:16x16^[noalpha^[colorize:#563d2d"
if minetest.get_modpath("xcompat") and minetest.global_exists("xcompat") then
    if core.get_game_info().id == "minetest" or core.get_game_info().id == "farlands_reloaded" then
        texture = xcompat.textures.grass.dirt
    else
        texture = "smoke_puff.png"
    end
else
    if core.get_game_info().id == "minetest" or core.get_game_info().id == "farlands_reloaded" then
        texture = "default_dirt.png"
    else
        texture = "smoke_puff.png"
    end
end

function aio_double_tap_run.show_particles(player)
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
            texture = texture
        })
    end
end