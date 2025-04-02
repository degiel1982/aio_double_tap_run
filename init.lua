local set_sprinting, mod_settings = dofile(core.get_modpath("aio_double_tap_run") .. "/functions/physics.lua")
local player_double_tap = {}
local dt_data = {}

--[[PRECALCULATE SOME VALUES]]
local stamina_treshold = mod_settings.stamina.sofar.treshold * 2
local tenplus_exhaust = mod_settings.stamina.tenplus.exhaust_sprint * 100

local function cancel_run(p_pos, player)
    local name = player:get_player_name()
    local test = false
    --[[ LIQUID CHECK ]]
    if mod_settings.tools.player_is_in_liquid(p_pos,player) and not mod_settings.liquid_sprint then
        return true
    end

    --[[ STARVE CHECK ]]
    --STAMINA
    if (mod_settings.stamina.sofar.installed or mod_settings.stamina.tenplus.installed) and mod_settings.stamina_drain then
        local treshold = 0
        local curent_saturation = stamina.get_saturation(player)
        if mod_settings.stamina.sofar.installed then
            treshold = stamina_treshold
        end
         if mod_settings.stamina.tenplus.installed then
            treshold = mod_settings.stamina.tenplus.treshold
        end
        player_double_tap[name].starving = mod_settings.tools.is_player_starving(curent_saturation, treshold)
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


--[[
    OVERRIDING RIGHT CLICK BEDS/COLORFUL BEDS
        - A PLAYER MUST STOP SPRINTING BEFORE INTERACTING WITH THE BED 
]]
core.register_on_mods_loaded(function()
    local has_beds = minetest.get_modpath("beds") ~= nil
    
    if has_beds then
        -- List the node names for the bed(s) you want to target.
        local bed_nodes = {
            "beds:bed",
            "beds:fancy_bed"
        }
        local function is_mod_active(mod_name)
            return core.get_modpath(mod_name) ~= nil
        end
        if is_mod_active("beds") then
            for node_name, _ in pairs(core.registered_nodes) do
                if string.find(node_name, "^colorful_beds:") and string.find(node_name, "bed") then
                    table.insert(bed_nodes, node_name)
                end
            end
        end
          -- Add colorful beds to the list if the mod is active
        if is_mod_active("colorful_beds") then
            for node_name, _ in pairs(core.registered_nodes) do
                if string.find(node_name, "^colorful_beds:") and string.find(node_name, "bed") then
                    table.insert(bed_nodes, node_name)
                end
            end
        end
        for _, bed_node in ipairs(bed_nodes) do
            if minetest.registered_nodes[bed_node] then
                local original_on_rightclick = minetest.registered_nodes[bed_node].on_rightclick
                minetest.override_item(bed_node, {
                    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
                        local pname = clicker:get_player_name()
                        if player_double_tap[pname].running then
                            core.chat_send_player(pname, "[AIO] - Stop sprinting before entering a bed")
                        else
                            if original_on_rightclick then
                                return original_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
                            end
                        end
                    end,
                })
            end
        end
    end
end)


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
        
        player_double_tap[name].running = mod_settings.tools.sprint_key_activated( 
                                                                                    mod_settings.use_aux,
                                                                                    mod_settings.use_dt,control_bits,
                                                                                    player_double_tap[name] , 
                                                                                    dtime, mod_settings.tap_interval, 
                                                                                    mod_settings.tools.dt_sensor
                                                                                ) and not cancel_run and not player_double_tap[name].running

        
        
        if player_double_tap[name].running then
            if mod_settings.stamina.sofar.installed then
                stamina.set_sprinting(player, true)
            else
                set_sprinting(player, true, mod_settings.extra_speed)
                mod_settings.tools.sprint_particles(player)
            end
            if mod_settings.stamina.sofar.installed and mod_settings.stamina_drain then
                  stamina.exhaust_player(player, mod_settings.stamina.sofar.exhaust_sprint * dtime)
            end
            if mod_settings.stamina.tenplus.installed and mod_settings.stamina_drain then
                  stamina.exhaust_player(player, tenplus_exhaust * dtime)
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
            if mod_settings.pova.installed then
                set_sprinting(player, false)
            end
            if mod_settings.enable_animation and mod_settings.character_anim then
                local current_animation = player:get_animation()
                local animation_range = current_animation and { x = current_animation.x, y = current_animation.y } or { x = 0, y = 79 }
                local sprint_speed = mod_settings.walk_framespeed + ((player:get_velocity().x^2 + player:get_velocity().z^2)^0.5 * 2)
                player:set_animation(animation_range, sprint_speed, 0)
            end
            if mod_settings.stamina.sofar.installed and mod_settings.stamina_drain then
                stamina.exhaust_player(player, mod_settings.stamina.sofar.exhaust_move * dtime)
            end
            if mod_settings.stamina.tenplus.installed and mod_settings.stamina_drain then
                stamina.exhaust_player(player, mod_settings.stamina.tenplus.exhaust_move * dtime)
            end
        end
    end
end)