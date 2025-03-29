# AIO - Double Tap Run

This mod adds a double-tap-to-run feature to Minetest, enhancing gameplay by providing a seamless way to toggle between walking and running. Whether you're exploring vast terrains or escaping danger, this mod ensures smooth and intuitive movement control.

## Features

- **Double-Tap Forward to Run**: Activate running mode by quickly double-tapping the forward movement key (`W`).
- **Dynamic Animation Speed**: The player's animation speed dynamically adjusts based on their movement speed, providing a more immersive experience.
- **Configurable Sprint Speed**: Customize the sprint speed using the `aio_dt.extra_speed` setting.
- **Aux1 Key Support**: Optionally enable the Aux1 key for sprinting by setting `aio_dt.use_aux` to `true`.
- **Automatic Integration with Stamina Mods**: If supported stamina mods (e.g., Sofar's or TenPlus1's stamina mods) are installed, the mod will automatically adjust sprinting behavior based on stamina levels.
- **Liquid Interaction**: Automatically disables sprinting when the player is in liquid, ensuring realistic movement.
- **Lightweight and Efficient**: Designed to integrate seamlessly with Minetest without impacting performance.
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
5. **Liquid Behavior**: Sprinting is automatically disabled when you enter liquid (e.g., water or lava), and your movement speed will return to normal.

## Configuration

You can customize the mod's behavior using the following settings in your `minetest.conf` file. These settings should only be adjusted if no stamina mod is installed. If a stamina mod is present, use its configuration settings for sprinting behavior.

- `aio_dt.extra_speed` (default: `0.5`): Sets the additional speed multiplier for sprinting. For example, setting it to `0.5` will make sprinting 50% faster than walking.
- `aio_dt.use_aux` (default: `false`): Enables the Aux1 key for sprinting when set to `true`.

### Example Configuration
```plaintext
aio_dt.extra_speed = 0.7
aio_dt.use_aux = true
```

## API

The mod includes a simple API for developers to integrate sprinting functionality into their own mods:

- `aio_double_tap_run.set_sprinting(player, state)`
  - Enables or disables sprinting for a specific player.
  - **Parameters**:
    - `player`: The player object.
    - `state`: Boolean value (`true` to enable sprinting, `false` to disable).

## Dependencies

### Optional:
- [Sofar's Stamina Mod](https://content.luanti.org/packages/sofar/stamina/?protocol_version=47)
- [TenPlus1's Stamina Mod](https://content.luanti.org/packages/TenPlus1/stamina/?protocol_version=47)
- [Player Monoids](https://content.luanti.org/packages/Byakuren/player_monoids/?protocol_version=47)
- [Pova](https://content.luanti.org/packages/TenPlus1/pova/)

## License

- **Code**: MIT License
- **Media**: No media included

Enjoy the enhanced movement mechanics with this mod!