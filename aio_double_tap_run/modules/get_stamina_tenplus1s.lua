local function get_player_stamina(player)
    if not player or not player:is_player() then
        return nil
    end
    local meta = player:get_meta()
    local stamina_level = meta:get_string("stamina:level")
    if stamina_level and stamina_level ~= "" then
        return tonumber(stamina_level)
    end
    return nil
end
return get_player_stamina