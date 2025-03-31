

# AIO - Double Tap Run

This mod enhances Minetest gameplay by introducing a double-tap-to-run mechanism. It allows players to toggle between walking and running seamlessly, while also incorporating new features such as preventing sprinting on beds and ensuring that running in place does not drain stamina or hunger.

## Features

- **Double-Tap Forward to Sprint:** Activate sprinting mode by quickly pressing the forward movement key (`W`).
- **Particle Effects During Sprinting:** Visual feedback when sprinting, adding depth to the gameplay.
- **Dynamic Animation Speed:** Adjusts animation speed based on movement velocity for a more realistic feel.
- **Configurable Sprint Speed:** Customize sprint speed using `aio_dt.extra_speed`.
- **Aux1 Key Support:** Enable sprinting with the Aux1 key by setting `aio_dt.use_aux` to `true`.
- **Stamina Integration:**
  - Supports both Sofar's and TenPlus1's stamina mods, adjusting sprint behavior based on stamina levels.
  - Configurable exhaustion rates for sprinting (`mod_settings.stamina.sofar.exhaust_sprint` and `mod_settings.stamina.tenplus.exhaust_sprint`).
- **Hunger Integration:** Automatically cancels sprinting when hunger falls below a threshold (`aio_dt.hunger_treshold`) and drains hunger while sprinting (`aio_dt.hunger_drain`), requiring the Hunger NG mod.
- **Pova and Player Monoids Compatibility:** Integrates with these mods to manage physics overrides, ensuring compatibility with other player-physics modifying mods.
- **Liquid Interaction:** Disables sprinting in liquids for realistic movement.
- **Ladder Behavior:** Sprinting can be enabled or disabled on ladders via configuration (`aio_dt.ladder_sprint`).
- **Prevent Sprinting on Beds:** Sprinting is disabled while lying on beds to prevent unintended behavior.
- **Running in Place Does Not Drain Stamina or Hunger:** Pressing the sprint key without moving forward won’t consume stamina or hunger.

## How to Use

1. **Double-Tap to Sprint:** Quickly press `W` twice to activate sprinting, increasing movement speed.
2. **Stop Sprinting:**
   - Release `W` to stop sprinting.
3. **Enable Aux1 Key for Sprinting:**
   - Set `aio_dt.use_aux = true` in your `minetest.conf` file to enable the Aux1 key for sprinting.
4. **Stamina Integration:**
   - If using a stamina mod, adjust sprint speed and exhaustion settings within that mod's configuration.
5. **Hunger Integration:**
   - Sprinting will cancel when hunger is low (`aio_dt.hunger_treshold`) and drain hunger while sprinting (`aio_dt.hunger_drain`), requiring the Hunger NG mod.
6. **Pova and Player Monoids Compatibility:**
   - These mods help manage physics overrides, ensuring compatibility with other player-physics modifying mods.
7. **Ladder Behavior:**
   - By default, sprinting is disabled on ladders. Enable it by setting `aio_dt.ladder_sprint = true`.

## Configuration

Adjust mod behavior using settings in your `minetest.conf` file. These should be set if no stamina mod is installed; otherwise, use the stamina mod's configuration.

- **General Settings:**
  - `aio_dt.extra_speed` (default: `0.5`): Sprint speed multiplier.
  - `aio_dt.use_aux` (default: `false`): Enable Aux1 key for sprinting.
  - `aio_dt.ladder_sprint` (default: `false`): Allow sprinting on ladders.

- **Hunger Integration:**
  - `aio_dt.hunger_treshold` (default: `6`): Hunger level below which sprinting stops.
  - `aio_dt.hunger_drain` (default: `0.5`): Hunger drained per unit time while sprinting.

### Example Configuration
```plaintext
aio_dt.extra_speed = 0.7
aio_dt.use_aux = true
aio_dt.ladder_sprint = false
aio_dt.hunger_treshold = 5
aio_dt.hunger_drain = 0.4
```

## API

The mod provides an API for developers to integrate sprinting functionality:

- `aio_double_tap_run.set_sprinting(player, state)`
  - Controls sprinting state for a player.
  - **Parameters:**
    - `player`: Player object.
    - `state`: Boolean (`true` enables sprinting).

### Example Usage
```lua
local player = minetest.get_player_by_name("player_name")
if player then
    -- Enable sprinting
    aio_double_tap_run.set_sprinting(player, true)
end
```

## Dependencies

- **Optional:**
  - [Sofar's Stamina Mod](https://content.luanti.org/packages/sofar/stamina/?protocol_version=47): Adjusts sprinting based on stamina.
  - [TenPlus1's Stamina Mod](https://content.luanti.org/packages/TenPlus1/stamina/?protocol_version=47): Supports stamina exhaustion while sprinting.
  - [Hunger NG Mod](https://content.minetest.net/packages/TenPlus1/hunger_ng/): Manages hunger-based sprint cancellation and drain.
  - [Player Monoids](https://content.luanti.org/packages/Byakuren/player_monoids/?protocol_version=47): Ensures compatibility with other physics mods.
  - [Pova](https://content.luanti.org/packages/TenPlus1/pova/): Manages physics overrides for sprinting.

## License

- **Code**: MIT License
- **Media**: No media included

Enjoy enhanced movement mechanics with the AIO - Double Tap Run mod!