// ============================================================================
// DIRECTIONAL LIGHTING - QUICK INTEGRATION GUIDE
// ============================================================================
// This file shows copy-paste examples for adding directional lighting to:
// 1. Lanterns (equippable lighting)
// 2. Forges/Ovens (stationary active lighting)
// 3. Spells (temporary cast lighting)
// ============================================================================

// ============================================================================
// INTEGRATION 1: LANTERN/TORCH LIGHTING (Equippable)
// ============================================================================

/*
FIND THIS in dm/Light.dm or wherever your lantern is defined:

  ironhandlamp
    density = 1
    layer = 6
    luminosity = 1
    icon = 'dmi/64/build.dmi'
    icon_state = "ironhandlamp"
    state = "Empty Torch"
    name = "Iron Hand Lamp"
    New()
      ..()

REPLACE WITH THIS:

  ironhandlamp
    density = 1
    layer = 6
    luminosity = 1
    icon = 'dmi/64/build.dmi'
    icon_state = "ironhandlamp"
    state = "Empty Torch"
    name = "Iron Hand Lamp"
    New()
      ..()

THEN ADD THESE PROCS TO THE LANTERN TYPE:

  mob/players
    proc
      light_lantern(obj/lantern)
        if(!lantern) return
        
        // Attach forward-facing warm light
        attach_directional_light(
          cone_type = "forward",
          hex_color = "#FFAA00",
          intens = 0.9,
          rad = 3.5,
          shadows = 1  // Enable shadows!
        )
        
        src << "The [lantern] glows brightly, casting warm light!"
      
      snuff_lantern(obj/lantern)
        if(!lantern) return
        
        remove_directional_light()
        src << "The light fades to darkness."

  // Now add equip/unequip hooks:
  obj/items/lantern
    var
      lit = 0
    
    proc
      light()
        if(lit) return
        lit = 1
        if(usr)
          usr.light_lantern(src)
      
      snuff()
        if(!lit) return
        lit = 0
        if(usr)
          usr.snuff_lantern(src)
*/

// ============================================================================
// INTEGRATION 2: FORGE/OVEN ACTIVE LIGHTING (Stationary)
// ============================================================================

/*
FIND THIS in dm/Light.dm (around line 1700+):

  obj/forge
    icon = 'dmi/64/anvil.dmi'
    icon_state = "forgelow"
    name = "Forge"
    New()
      ..()

ADD THIS PROC:

  proc/ignite_forge()
    // Create omnidirectional warm light
    var/obj/directional_cone/light = new(owner=src, cone_type="omnidirectional", hex="#FF6600", intens=0.85, rad=4, shadows=1)
    light.start_tracking()
    
    // Store reference for later removal
    src.forge_light = light
  
  proc/extinguish_forge()
    if(forge_light)
      forge_light.cleanup()
      forge_light = null

THEN FIND WHERE YOUR FORGE GETS LIT (likely in a verb or action):

  forge/verb/light_fire()
    if(burning) return
    burning = 1
    ignite_forge()
    src.icon_state = "forge_lit"
    world << "[usr] lights the forge!"
  
  forge/verb/snuff_fire()
    if(!burning) return
    burning = 0
    extinguish_forge()
    src.icon_state = "forge_cold"

  // Add to forge var section:
  var
    burning = 0
    obj/directional_cone/forge_light = null
*/

// ============================================================================
// INTEGRATION 3: SPELL LIGHTING (Temporary magic lights)
// ============================================================================

/*
FIND THIS in dm/Spells.dm around where spells are cast:

  mob/players/proc/cast_spell(spell_name, ...)
    var/obj/spells/spell_effect = new /obj/spells/heat(src.loc)
    // ... spell execution code ...

ADD THIS AFTER SPELL CREATION:

  mob/players/proc/cast_spell(spell_name, ...)
    var/obj/spells/spell_effect = new /obj/spells/heat(src.loc)
    
    // Add lighting to spell if it's a light-producing spell
    if(time_of_day == NIGHT)
      switch(spell_name)
        if("heat", "fireball", "inferno")
          // Orange glow for fire spells
          var/spell_light = new /obj/spell_light(spell_effect, cone_type="omnidirectional", hex="#FF6600", intens=0.8, duration_ticks=150)
        
        if("chainlightning", "lightning_bolt")
          // Blue glow for lightning spells
          var/spell_light = new /obj/spell_light(spell_effect, cone_type="omnidirectional", hex="#0088FF", intens=0.9, duration_ticks=100)
        
        if("frostbolt", "icestorm")
          // Cool blue for ice spells
          var/spell_light = new /obj/spell_light(spell_effect, cone_type="omnidirectional", hex="#00CCFF", intens=0.7, duration_ticks=100)
        
        if("arcane_missiles")
          // Purple glow for arcane
          var/spell_light = new /obj/spell_light(spell_effect, cone_type="omnidirectional", hex="#BB00FF", intens=0.7, duration_ticks=80)

ALTERNATIVELY, ADD THIS HELPER PROC:

  proc/cast_spell_with_lighting(spell_name)
    var/obj/spells/spell = new /obj/spells/spell_type(src.loc)
    
    // Only light spells at night for immersion
    if(time_of_day == NIGHT)
      var/light_color = _get_spell_light_color(spell_name)
      if(light_color)
        var/spell_light = new /obj/spell_light(spell, cone_type="omnidirectional", hex=light_color, intens=0.8, duration_ticks=120)
  
  proc/_get_spell_light_color(spell_name)
    switch(spell_name)
      if("heat", "fireball", "inferno")
        return "#FF6600"
      if("chainlightning")
        return "#0088FF"
      if("frostbolt", "icestorm")
        return "#00CCFF"
      if("arcane_missiles")
        return "#BB00FF"
      else
        return null
*/

// ============================================================================
// INTEGRATION 4: PLAYER TORCH (Crafted Item)
// ============================================================================

/*
If you want players to be able to light torches they're holding:

  obj/items/torches/wooden_torch
    icon = 'dmi/64/torch.dmi'
    icon_state = "torch_unlit"
    var
      lit = 0
    
    proc
      light_it(mob/player)
        if(lit) return
        lit = 1
        icon_state = "torch_lit"
        
        // Attach small forward-facing light
        player.attach_directional_light(
          cone_type = "forward",
          hex_color = "#FFCC00",
          intens = 0.75,
          rad = 2.5,
          shadows = 1
        )
      
      extinguish_it(mob/player)
        if(!lit) return
        lit = 0
        icon_state = "torch_unlit"
        player.remove_directional_light()
    
    verb/ignite()
      set src in usr.contents
      light_it(usr)
      usr << "You light the torch!"
    
    verb/extinguish()
      set src in usr.contents
      extinguish_it(usr)
      usr << "You extinguish the torch."
*/

// ============================================================================
// CONE TYPE QUICK REFERENCE
// ============================================================================

/*
"forward" - 90 degree cone pointing in owner's direction
  Best for: Lanterns, torches, held items
  Spread: Narrow cone
  Use: cone_type = "forward"

"wide120" - 120 degree cone spread
  Best for: Wider light sources like lamps on walls
  Spread: Moderate
  Use: cone_type = "wide120"

"wide180" - 180 degree semicircle
  Best for: Light on ceiling, light against walls
  Spread: Wide half-circle
  Use: cone_type = "wide180"

"omnidirectional" - Full circle in all directions
  Best for: Spells, explosions, forges, fires
  Spread: Omnidirectional
  Use: cone_type = "omnidirectional"
*/

// ============================================================================
// COLOR QUICK REFERENCE
// ============================================================================

/*
Warm colors (natural fire/wood):
  "#FFAA00" - Torch/wood fire (warm orange)
  "#FF8800" - Intense fire (orange-red)
  "#FF6600" - Hot forge (red-orange)
  "#FFCC00" - Lantern light (warm yellow)

Cool colors (magic):
  "#0088FF" - Lightning/energy (bright blue)
  "#00CCFF" - Ice/frost (cyan)
  "#BB00FF" - Arcane/magic (purple)
  "#00FF00" - Poison/acid (green)
  "#FF0088" - Void/dark magic (magenta)

Neutral:
  "#FFFFFF" - Pure white light
  "#CCCCCC" - Pale/dim light
*/

// ============================================================================
// INTENSITY QUICK REFERENCE
// ============================================================================

/*
0.0 - 0.3:   Very dim (barely visible)
0.4 - 0.6:   Medium light (subtle effect)
0.7 - 0.85:  Standard lighting (natural feel)
0.9 - 1.0:   Bright light (intense effect)

Examples:
  Candle in room:     intens = 0.4
  Standard lantern:   intens = 0.8
  Bright torch:       intens = 0.9
  Forge fire:         intens = 0.85
  Spell effect:       intens = 0.7
*/

// ============================================================================
// RADIUS QUICK REFERENCE
// ============================================================================

/*
1.0 - 2.0:   Small light (nearby only)
2.5 - 3.5:   Standard lantern (personal space)
4.0 - 5.0:   Large light source (room-scale)
6.0+:        Very large (outdoor torch, beacon)

Examples:
  Equipped torch:      rad = 2.5
  Lantern:             rad = 3.5
  Forge/oven:          rad = 4.0
  Campfire:            rad = 4.5
  Spell effect:        rad = 2.0
*/

// ============================================================================
// TESTING / DEBUGGING
// ============================================================================

/*
Test in-game with:

  /obj/test_directional_light
    verb/attach_light()
      usr.attach_directional_light(
        cone_type = "forward",
        hex_color = "#FFAA00",
        intens = 0.8,
        rad = 3,
        shadows = 1
      )
      usr << "Light attached! Turn and move around."
    
    verb/remove_light()
      usr.remove_directional_light()
      usr << "Light removed."
    
    verb/rotate_light()
      if(usr.equipped_light)
        usr.equipped_light.update_direction()
        usr << "Light rotated."
    
    verb/change_intensity()
      set text = "Intensity (0-1)"
      var/val = input(usr, "Set intensity", "Intensity") as num
      if(usr.equipped_light)
        usr.equipped_light.set_intensity(val)
    
    verb/change_color()
      set text = "Color (hex)"
      var/hex = input(usr, "Set color", "Color", "#FFFFFF") as text
      if(usr.equipped_light)
        usr.equipped_light.set_color(hex)

Then:
  /obj/test_directional_light/attach_light  - Creates light on player
  /obj/test_directional_light/remove_light  - Removes light
  /obj/test_directional_light/rotate_light  - Updates direction
  /obj/test_directional_light/change_intensity  - Adjust brightness
  /obj/test_directional_light/change_color  - Change light color
*/

// ============================================================================
// COMMON ISSUES & SOLUTIONS
// ============================================================================

/*
ISSUE: Light not showing up
SOLUTION:
  1. Check obj/directional_cone is using LIGHTING_PLANE
  2. Verify time_of_day is set (lights are most visible at NIGHT)
  3. Check if cone icon states exist in 'l256.dmi'
  4. Verify start_tracking() was called

ISSUE: Light doesn't rotate with player
SOLUTION:
  1. Ensure tracking = 1 (call start_tracking())
  2. Check owner.dir is changing (verify movement system updates dir)
  3. Verify update_direction() is being called each tick
  4. Check transform matrix math (rotation values 0-360)

ISSUE: Shadows not showing
SOLUTION:
  1. Ensure shadows=1 when creating light
  2. Check dmi/shadow.dmi exists and has valid icon
  3. Verify ShadowLighting.dm is included in .dme
  4. Shadow visibility depends on terrain/objects behind light

ISSUE: Performance issues
SOLUTION:
  1. Reduce number of shadows (shadows = 0)
  2. Reduce cone type complexity ("forward" faster than "omnidirectional")
  3. Increase tracking interval in _tracking_loop() (change sleep(1) to sleep(2))
  4. Limit number of spell lights active at once
  5. Remove lights when not needed (cleanup())
*/
