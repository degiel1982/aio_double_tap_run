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

return get_mod_author