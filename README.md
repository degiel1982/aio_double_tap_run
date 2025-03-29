# AIO - Double Tap Run

This mod adds a double-tap-to-run feature to Minetest, enhancing gameplay by providing a seamless way to toggle between walking and running. Whether you're exploring vast terrains or escaping danger, this mod ensures smooth and intuitive movement control.

## Features

- **Double-Tap Forward to Run**: Activate running mode by quickly double-tapping the forward movement key (`W`).
- **Automatic Integration with Stamina Mods**: If supported stamina mods (e.g., Sofar's or TenPlus1's stamina mods) are installed, the mod will automatically adjust sprinting behavior based on stamina levels.
- **Liquid Interaction**: Automatically disables sprinting when the player is in liquid, ensuring realistic movement.
- **Lightweight and Efficient**: Designed to integrate seamlessly with Minetest without impacting performance.
- **API Support**: Provides an API for developers to enable or disable sprinting programmatically.

## How to Use

1. **Double-Tap to Sprint**: Quickly press the forward movement key (`W`) twice to activate sprinting mode. Sprinting will increase your movement speed.
2. **Stop Sprinting**:
   - Release the forward key (`W`) to stop sprinting.
3. **Stamina Integration**:
   - If Sofar's or TenPlus1's stamina mods are installed, stamina will drain while sprinting and regenerate when walking or standing still.
4. **Liquid Behavior**: Sprinting is automatically disabled when you enter liquid (e.g., water or lava), and your movement speed will return to normal.

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