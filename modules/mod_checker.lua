local get_mod_author = dofile(core.get_modpath("aio_double_tap_run").."/modules/get_mod_author.lua")


-- Helper function to check for mod conflicts.
local function check_collision(mod, count)
    return count > 1
end

local function mod_checker()
    local count = 0
    local dt_off = false
    local mod = ""

    -- Check for "stamina" mod compatibility.
    local stamina_is_installed = minetest.get_modpath("stamina") ~= nil
    if stamina_is_installed then
        -- Example: Check the author of the current mod
        local mod_author, err = get_mod_author("stamina")
        if mod_author == "TenPlus1" then
            mod = "stamina"
            count = count + 1
        else
            mod = "stamina"
            count = count + 1
        end
        dt_off = check_collision(mod, count)
        if dt_off then
            return mod, dt_off
        end
    end

    -- Check for "hunger_ng" mod compatibility.
    local hunger_is_installed = minetest.get_modpath("hunger_ng") ~= nil
    if hunger_is_installed then
        mod = "hunger_ng"
        count = count + 1
        dt_off = check_collision(mod, count)
        if dt_off then
            return mod, dt_off
        end
    end

    return mod, dt_off
end

local mod, dt_off = mod_checker()
if mod == "" then
    mod = "no_mod"
end

return mod, dt_off