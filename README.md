# AIO - Double Tap Run

This mod adds a double-tap-to-run feature to Minetest, enhancing gameplay by providing a seamless way to toggle between walking and running. Whether you're exploring vast terrains or escaping danger, this mod ensures smooth and intuitive movement control.

## Features

- **Double-Tap Forward to Run**: Activate running mode by quickly double-tapping the forward movement key (`W`).
- **Dynamic Animation Speed**: The player's animation speed dynamically adjusts based on their movement speed, providing a more immersive experience.
- **Configurable Sprint Speed**: Customize the sprint speed using the `aio_dt.extra_speed` setting.
- **Aux1 Key Support**: Optionally enable the Aux1 key for sprinting by setting `aio_dt.use_aux` to `true`.
- **Automatic Integration with Stamina Mods**: If supported stamina mods (e.g., Sofar's or TenPlus1's stamina mods) are installed, the mod will automatically adjust sprinting behavior based on stamina levels.
- **Hunger Integration**: Automatically cancels sprinting when the player's hunger level falls below a configurable threshold (requires Hunger NG mod).
- **Pova Integration**: Automatically integrates with the Pova mod to manage sprinting physics overrides.
- **Player Monoids Integration**: Uses Player Monoids to ensure compatibility with other mods that modify player physics.
- **Liquid Interaction**: Automatically disables sprinting when the player is in liquid, ensuring realistic movement.
- **Ladder Interaction**: Sprinting is disabled when the player is on a ladder unless explicitly enabled via configuration.
- **Lightweight and Efficient**: Designed to integrate seamlessly with Minetest without impacting performance.
- **No Required Dependencies**: This mod works out of the box without requiring any additional mods.
- **API Support**: Provides an API for developers to enable or disable sprinting programmatically.

## How to Use

1. **Double-Tap to Sprint**: Quickly press the forward movement key (`W`) twice to activate sprinting mode. Sprinting will increase your movement speed.
2. **Stop Sprinting**:
   - Release the forward key (`W`) to stop sprinting.
3. **Enable Aux1 Key for Sprinting**:
   - Set `aio_dt.use_aux` to `true` in your `minetest.conf` file to enable the Aux1 key for sprinting.
4. **Stamina Integration**:
   - If Sofar's or TenPlus1's stamina mods are installed, stamina will drain while sprinting and regenerate when walking or standing still.
   - **Important**: When using a stamina mod, adjust the sprint speed and exhaustion settings in the stamina mod's configuration to ensure proper integration.
5. **Hunger Integration**:
   - If the Hunger NG mod is installed, sprinting will automatically cancel when the player's hunger level falls below the configured threshold (`aio_dt.hunger_treshold`).
   - Hunger will also drain while sprinting based on the `aio_dt.hunger_drain` setting.
6. **Pova Integration**:
   - If the Pova mod is installed, it will be used to manage sprinting physics overrides, ensuring compatibility with other mods that modify player physics.
7. **Player Monoids Integration**:
   - If the Player Monoids mod is installed, it will be used to manage sprinting physics overrides, ensuring compatibility with other mods that modify player physics.
8. **Ladder Behavior**:
   - By default, sprinting is disabled when the player is on a ladder. You can enable sprinting on ladders by setting `aio_dt.ladder_sprint` to `true` in your `minetest.conf`.

## Configuration

You can customize the mod's behavior using the following settings in your `minetest.conf` file. These settings should only be adjusted if no stamina mod is installed. If a stamina mod is present, use its configuration settings for sprinting behavior.

- `aio_dt.extra_speed` (default: `0.5`): Sets the additional speed multiplier for sprinting. For example, setting it to `0.5` will make sprinting 50% faster than walking.
- `aio_dt.use_aux` (default: `false`): Enables the Aux1 key for sprinting when set to `true`.
- `aio_dt.ladder_sprint` (default: `false`): Enables sprinting while on ladders when set to `true`.
- `aio_dt.hunger_treshold` (default: `6`): Cancels sprinting when the player's hunger level falls below this value (requires Hunger NG mod).
- `aio_dt.hunger_drain` (default: `0.5`): Sets the amount of hunger drained while sprinting (requires Hunger NG mod).

### Example Configuration
```plaintext
aio_dt.extra_speed = 0.7
aio_dt.use_aux = true
aio_dt.ladder_sprint = false
aio_dt.hunger_treshold = 5
aio_dt.hunger_drain = 0.4
```

## API

The mod includes a simple API for developers to integrate sprinting functionality into their own mods:

- `aio_double_tap_run.set_sprinting(player, state)`
  - Enables or disables sprinting for a specific player.
  - **Parameters**:
    - `player`: The player object.
    - `state`: Boolean value (`true` to enable sprinting, `false` to disable`).

### Example Usage
```lua
local player = minetest.get_player_by_name("player_name")
if player then
    -- Enable sprinting for the player
    aio_double_tap_run.set_sprinting(player, true)

    -- Disable sprinting for the player
    aio_double_tap_run.set_sprinting(player, false)
end
```

## Dependencies

### Optional:
- [Sofar's Stamina Mod](https://content.luanti.org/packages/sofar/stamina/?protocol_version=47): Automatically adjusts sprinting behavior based on stamina levels.
- [TenPlus1's Stamina Mod](https://content.luanti.org/packages/TenPlus1/stamina/?protocol_version=47): Supports stamina exhaustion while sprinting.
- [Hunger NG Mod](https://content.minetest.net/packages/TenPlus1/hunger_ng/): Cancels sprinting when hunger is below a threshold and drains hunger while sprinting.
- [Player Monoids](https://content.luanti.org/packages/Byakuren/player_monoids/?protocol_version=47): Ensures compatibility with other mods that modify player physics.
- [Pova](https://content.luanti.org/packages/TenPlus1/pova/): Manages sprinting physics overrides for compatibility with other mods.

## License

- **Code**: MIT License
- **Media**: No media included

Enjoy the enhanced movement mechanics with this mod!
