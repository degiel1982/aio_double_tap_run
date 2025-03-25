local function get_mod_author(modname)
    -- Get the path to the mod's directory
    local modpath = core.get_modpath(modname)
    if not modpath then
        return nil, "Mod not found"
    end

    -- Load the mod.conf file
    local mod_conf = Settings(modpath .. "/mod.conf")
    if not mod_conf then
        return nil, "mod.conf not found"
    end

    -- Get the author field
    local author = mod_conf:get("author")
    if author then
        return author
    else
        return nil, "Author field not found in mod.conf"
    end
end

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
            mod = "tenplus1_stamina"
            count = count + 1
        else
            mod = "sofar_stamina"
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
