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
        if stamina and type(stamina.change_saturation) == "function" then
            mod = "sofar_stamina"
            count = count + 1
        elseif stamina and type(stamina.change) == "function" then
            mod = "tenplus1_stamina"
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