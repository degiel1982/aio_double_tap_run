local stamina_is_installed = core.get_modpath("stamina") ~= nil
if stamina_is_installed then
    return {
        player_data = {
            dt = {
                count = 0,
                timer = 0, 
                was_up = false,
                sprinting = false,
            }
        }
    }
end