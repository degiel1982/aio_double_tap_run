local DEBUG = false

-- Helper function to get a unique key code for pressed keys
local function get_keycode(player)
    local control = player:get_player_control()

    -- Map each key to a unique power of 2
    local key_map = {
        up = 1,          -- 2^0 = 1
        down = 2,        -- 2^1 = 2
        left = 4,        -- 2^2 = 4
        right = 8,       -- 2^3 = 8
        sneak = 16,      -- 2^4 = 16
        aux1 = 32,       -- 2^5 = 32
        jump = 64,       -- 2^6 = 64
        dig = 128,       -- 2^7 = 128
        place = 256,     -- 2^8 = 256
        zoom = 512,      -- 2^9 = 512 (if zoom is supported)
        inventory = 1024 -- 2^10 = 1024 (if inventory key is supported)
    }

    -- Calculate the unique key code
    local key_code = 0
    if control.up then
        key_code = key_code + key_map.up
    end
    if control.down then
        key_code = key_code + key_map.down
    end
    if control.left then
        key_code = key_code + key_map.left
    end
    if control.right then
        key_code = key_code + key_map.right
    end
    if control.sneak then
        key_code = key_code + key_map.sneak
    end
    if control.aux1 then
        key_code = key_code + key_map.aux1
    end
    if control.jump then
        key_code = key_code + key_map.jump
    end
    if control.dig then
        key_code = key_code + key_map.dig
    end
    if control.place then
        key_code = key_code + key_map.place
    end
    if control.zoom then
        key_code = key_code + key_map.zoom
    end
    if control.inventory then
        key_code = key_code + key_map.inventory
    end
    if DEBUG then
        if key_code and key_code ~= 0 then
            core.chat_send_player(player:get_player_name(), "Key code is: " .. key_code)
        end
    end
    return key_code
end

return get_keycode