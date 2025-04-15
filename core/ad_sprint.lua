-- Place this in your mod's init.lua

local mybar_hud_ids = {}

local function get_mybar_hud_id(player)
    return mybar_hud_ids[player:get_player_name()]
end

local function set_mybar_hud_id(player, hud_id)
    mybar_hud_ids[player:get_player_name()] = hud_id
end
local bar_y = -114
if core.get_modpath("stamina") then
    bar_y = -130
end
-- Register and initialize the custom HUD bar for a player
local function init_mybar(player)
    local max_value = 20
    local value = max_value
    local id = player:hud_add({
        name = "mybar",
        [minetest.features.hud_def_type_field and "type" or "hud_elem_type"] = "statbar",
        position = {x = 0.5, y = 1},
        size = {x = 24, y = 24},
        text = "mybar_fg.png",      -- your bar foreground image
        number = value,
        text2 = "mybar_bg.png",     -- your bar background image
        item = max_value,
        alignment = {x = -1, y = -1},
        offset = {x = -266, y = bar_y}, -- y=-140 is above stamina's y=-110
        max = 0,
    })
    set_mybar_hud_id(player, id)
    player:set_attribute("mybar:value", value)
    player:set_attribute("mybar:max", max_value)
end

minetest.register_on_joinplayer(init_mybar)

-- Helper: Drain the bar for a player
local function drain_mybar(player, amount)
    local value = tonumber(player:get_attribute("mybar:value")) or 0
    local max_value = tonumber(player:get_attribute("mybar:max")) or 20
    value = math.max(0, value - amount)
    player:set_attribute("mybar:value", value)
    player:hud_change(get_mybar_hud_id(player), "number", value)
end

-- Helper: Restore the bar for a player
local function restore_mybar(player, amount)
    local value = tonumber(player:get_attribute("mybar:value")) or 0
    local max_value = tonumber(player:get_attribute("mybar:max")) or 20
    value = math.min(max_value, value + amount)
    player:set_attribute("mybar:value", value)
    player:hud_change(get_mybar_hud_id(player), "number", value)
end


local mod_name = aio_double_tap_run.mod_name
local functions = dofile(core.get_modpath(mod_name) .. "/core/functions.lua")

aio_double_tap_run.register_callback(function(player, data, dtime)
    local player_name = player:get_player_name()
   
   --if data.is_sprinting and not functions.in_air(player,1) and not functions.wall_bump(player) then
   --     local current_value = tonumber(player:get_attribute("mybar:value")) or 0
   --     local max_value = tonumber(player:get_attribute("mybar:max")) or 20
   --     if current_value > 0 then
   --         drain_mybar(player, 1 * dtime) -- drains 1 per second
   --         -- restore_mybar(player, 1) -- uncomment to restore instead
   --     end
--
   --     if current_value <= 0 then
   --         data.cancel_sprint = true
   --         return data
   --     end
   -- else
--
   -- end
end)

---- Example: Drain the bar over time
--local mybar_timer = 0
--minetest.register_globalstep(function(dtime)
--    mybar_timer = mybar_timer + dtime
--    if mybar_timer > 2 then
--        mybar_timer = 0
--        for _, player in ipairs(minetest.get_connected_players()) do
--            drain_mybar(player, 1) -- drains 1 per second
--            -- restore_mybar(player, 1) -- uncomment to restore instead
--        end
--    end
--end)