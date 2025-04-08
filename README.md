#  AIO - DOUBLE TAP RUN

### **Features List**  

- **Intuitive Double-Tap Sprinting**: Effortlessly activate sprinting by double-tapping the forward key, offering a natural and responsive way to boost your movement speed.  
- **Comprehensive Sprinting Mod**: Built with double-tap sprinting as its flagship feature, providing a refined sprinting experience tailored to all types of players.  
- **Optional AUX1 Sprinting**: Prefer an alternative? Enable sprinting via the AUX1 key for more customization.  
- **Seamless Sprinting Experience**: Enjoy fluid, uninterrupted sprinting without unexpected stops or interruptions.  
- **Enhanced Water Diving**: Sprint even while fully submerged for faster underwater navigation. For an even better experience, pair with the **3D Armor Fly Swim Mod**.  
- **Extensive Customization Options**: Adjust the mod's settings to perfectly align with your personal playstyle.  
- **Controller & Touchscreen Optimization**: Freely move using the D-pad or touchscreen without interruptions—except when moving backward or standing still.  
- **Stamina Integration**: Fully supports stamina mechanics with **stamina/hunger_ng** for an immersive gameplay experience.  
- **Xcompat Sprint Particles**: Utilize sprint particle effects across more supported worlds with Xcompat compatibility.  
- **Hang glider compatible**: Supports sprint gliding with a hang glider when hang glider mod is installed

### **Global Settings**

#### **Change the Player's Speed**
- **aio_double_tap_run.extra_speed**: *Set extra speed*  
  Type: `float`  
  Default: `0.8`  
  _Description_: Sets how much faster the player moves (e.g., `0.5` makes the player 50% faster).  
  **Issues**:  
  - Not compatible with `stamina` by Sofar.  
  **Solution**: Adjust this setting using the mod's configuration.

#### **Enable Double-Tap Sprint**
- **aio_double_tap_run.enable_dt**: *Enable double-tap sprint*  
  Type: `bool`  
  Default: `true`  
  _Description_: Activates double-tap sprint.

#### **Enable AUX1 Sprint**
- **aio_double_tap_run.enable_aux**: *Enable AUX1 sprint*  
  Type: `bool`  
  Default: `false`  
  **Issues**:  
  - Not compatible with `stamina` by Sofar.  
  - Not compatible with `stamina` by Tenplus1.  
  **Solution**: Adjust this setting using the mod's configuration.

#### **Enable Sprint Particle Effects**
- **aio_double_tap_run.particles**: *Enable particles*  
  Type: `bool`  
  Default: `true`  
  **Issues**:  
  - Not compatible with `stamina` by Sofar.  
  - Not compatible with `stamina` by Tenplus1.  
  **Solution**: Adjust this setting using the mod's configuration.

#### **Enable Sprint Swimming**
- **aio_double_tap_run.enable_swim**: *Enable sprint swimming when submerged underwater*  
  Type: `bool`  
  Default: `true`  
  **Note**: Requires liquid cancellation check to function properly.

---

### **Sprint Cancellations**

#### **Cancellation Triggers**
- **aio_double_tap_run.disable_backwards_sprint**: *Cancel when moving backward*  
  Type: `bool`  
  Default: `true`

- **aio_double_tap_run.liquid_check**: *Cancel sprint in water or lava*  
  Type: `bool`  
  Default: `true`

- **aio_double_tap_run.wall_check**: *Cancel sprint when bumping against a wall*  
  Type: `bool`  
  Default: `true`

- **aio_double_tap_run.climbable_check**: *Cancel sprint on climbable surfaces*  
  Type: `bool`  
  Default: `true`

- **aio_double_tap_run.crouch_check**: *Cancel sprint while crouching*  
  Type: `bool`  
  Default: `false`

- **aio_double_tap_run.snow_check**: *Cancel sprint on snowy nodes*  
  Type: `bool`  
  Default: `true`

- **aio_double_tap_run.fly_check**: *Cancel sprint while flying*  
  Type: `bool`  
  Default: `false`

- **aio_double_tap_run.health_check**: *Cancel sprint with low health*  
  Type: `bool`  
  Default: `true`  
  **Threshold**:  
  - **aio_double_tap_run.health_treshold**: *Health threshold*  
    Type: `int`  
    Default: `6`

---

### **Hunger_ng Integration**

#### **Starvation Mechanics**
- **aio_double_tap_run.starve_check**: *Cancel sprint when starving*  
  Type: `bool`  
  Default: `true`

#### **Hunger Threshold**
- **aio_double_tap_run.hunger_treshold**: *Starvation threshold*  
  Type: `int`  
  Default: `6`  
  _Description_: Sprint cancels when player hunger falls below this threshold (if enabled).

#### **Stamina Drain**
- **aio_double_tap_run.enable_stamina_drain**: *Enable stamina drain*  
  Type: `bool`  
  Default: `true`

---

### **Character Animations**

#### **Animation Settings**
- **aio_double_tap_run.enable_animations**: *Enable animations*  
  Type: `bool`  
  Default: `true`

- **aio_double_tap_run.walk_framespeed**: *Walk frame speed*  
  Type: `int`  
  Default: `15`

- **aio_double_tap_run.sprint_framespeed**: *Sprint frame speed*  
  Type: `int`  
  Default: `30`

---


