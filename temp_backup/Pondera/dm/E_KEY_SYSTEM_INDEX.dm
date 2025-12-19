/**
 * PONDERA E-KEY SYSTEM INDEX
 * ============================
 * 
 * This file serves as a comprehensive guide to the E-key UseObject system.
 * The E-key (keyboard key 'E') is used to interact with objects in the world
 * as an alternative to clicking (Left Mouse) or using explicit verbs/commands.
 * 
 * Core System:
 *   - Macros.dm: E-key verb definition and atom/proc/UseObject base
 * 
 * Extension Files:
 *   - UseObjectExtensions.dm: Doors, NPCs, signs, exits, weapon/armor racks
 *   - GatheringExtensions.dm: Trees, rocks, water, soil, flowers, plants
 *   - SkillExtensions.dm: NPCs, crafting stations, fires, forges, anvils
 *   - FurnitureExtensions.dm: Beds, tables, chairs, crates, containers
 *   - MiscExtensions.dm: Lamps, banners, signs, barricades, decorations
 * 
 * COMPREHENSIVE E-KEY COVERAGE
 * =============================
 */

// ==================== DOORS ====================
// ALL door types support E-key via tryit() delegation
//   - LeftDoor, RightDoor, TopDoor (base doors)
//   - WHLeftDoor, WHRightDoor, WHTopDoor, WHDoor (wooden house doors)
//   - SHLeftDoor, SHRightDoor, SHTopDoor, SHDoor (stone house doors)
//   - SLeftDoor, SRightDoor, STopDoor, SDoor (small doors)
//   - HTLeftDoor, HTRightDoor, HTTopDoor, HTDoor (half-timber doors)
// Usage: Stand in front of door, press E

// ==================== FURNISHINGS ====================
// BEDS
//   - obj/Buildable/Furnishings/bed (single bed)
//   - obj/Buildable/Furnishings/beds (standard bed)
//
// TABLES
//   - obj/Buildable/Furnishings/Table (dining/work table)
//
// CHAIRS (all directional variants)
//   - obj/Buildable/Furnishings/Chairr (right chair)
//   - obj/Buildable/Furnishings/Chairl (left chair)
//   - obj/Buildable/Furnishings/Chairn (north chair)
//   - obj/Buildable/Furnishings/Chairs (south chair)
//   - obj/Buildable/Furnishings/Chairst (south top chair)
//
// STORAGE
//   - obj/Buildable/Furnishings/crate (item storage)
//   - obj/Buildable/Containers/* (fridges, storage boxes)
// Usage: Stand near furniture, press E

// ==================== GATHERING SYSTEMS ====================
// TREES (all variants)
//   - obj/plant/tree/UeikTree, UeikTreeH, UeikTreeA
//   - obj/plant/tree/* (any tree type)
//
// MINING DEPOSITS
//   - obj/Rocks/* (all ore/stone types)
//   - obj/Cliff/* (elevated mining areas)
//
// WATER SOURCES
//   - turf/water (all variants: c1, c2, c3, c4)
//   - Supports: drinking, fishing (if skill available)
//
// PLANTS & FLOWERS
//   - obj/plant/* (herbalism, flowers)
//   - turf/flowers/* (field flowers)
//
// SOIL & DEPOSITS
//   - obj/Soil/* (soil types)
//   - turf/ClayDeposit, ObsidianField, Sand, TarPit
// Usage: Stand near resource, press E to harvest

// ==================== CRAFTING & SKILLS ====================
// COOKING & FIRE
//   - obj/Buildable/Fire (cooking fires, fireplaces)
//   - turf/woodstove (stove surfaces)
//   - obj/Buildable/Oven (ovens)
//
// SMITHING
//   - obj/Buildable/Smithing/Anvil (anvil stations)
//   - obj/Buildable/Smithing/Forge (forge stations)
//
// CRAFTING STATIONS
//   - obj/Buildable/Alchemy (alchemy tables)
//   - obj/Buildable/Herbalism (herbalism stations)
//
// NAVIGATION
//   - obj/Buildable/sundial (time displays)
//   - obj/Navi/Compas (compass markers)
//   - obj/Navi/Arrow (direction arrows)
// Usage: Stand near station, press E

// ==================== NPCs & DIALOGUE ====================
// NPCS (all types)
//   - mob/npc/* (villagers, merchants, quest givers)
//   - mob/npc/Guide (tutorial NPC)
//   - mob/npc/Builder (building advisor)
//
// INTERACTION POINTS
//   - Signs and message boards
//   - Dialog triggers
// Usage: Stand near NPC, press E to interact

// ==================== WORLD INTERACTIONS ====================
// CHESTS & CONTAINERS
//   - obj/chest/* (all chest types: regular, ornate, locked)
//
// BARRICADES
//   - obj/Buildable/Barricade (defensive structures)
//
// DECORATIONS
//   - obj/Buildable/Banner (banners and flags)
//   - obj/Buildable/Sign (wall signs)
//   - obj/Buildable/Flowers (decorative flowers)
//   - obj/Buildable/Decoration (misc decorations)
//   - obj/Buildable/Bookshelf (libraries)
//   - obj/Buildable/Library (book storage)
//
// LIGHTING
//   - obj/Buildable/Lamps/* (all lamp types)
//   - obj/Buildable/lamps/* (lamp variants)
//   - obj/items/Buildable/lamps/* (portable lamps)
// Usage: Stand near object, press E

// ==================== DESIGN PATTERNS ====================
// 
// Pattern 1: Simple Delegation
//   UseObject(mob/user)
//       if(user in range(1, src))
//           user.Click(src)
//           return 1
//       return 0
// 
// Use when: Object already has working Click() handler
// 
// Pattern 2: Proc Delegation
//   UseObject(mob/user)
//       if(user in range(1, src))
//           call(src, /path/to/proc)(user, src)
//           return 1
//       return 0
//
// Use when: Object has specific interaction proc (e.g., door.tryit)
//
// Pattern 3: DblClick Delegation
//   UseObject(mob/user)
//       if(user in range(1, src))
//           set waitfor = 0
//           user.DblClick(src)
//           return 1
//       return 0
//
// Use when: Object handles harvesting/interaction via DblClick
//
// Pattern 4: Status Display
//   UseObject(mob/user)
//       if(user in range(2, src))
//           user << "<center>Status information here"
//           return 1
//       return 0
//
// Use when: E-key shows status rather than triggering action

// ==================== ADDING NEW OBJECTS ====================
//
// To add E-key support to a new object:
//
// 1. Determine the appropriate extension file:
//    - Doors/Exits → UseObjectExtensions.dm
//    - Gathering → GatheringExtensions.dm
//    - Crafting/Skills → SkillExtensions.dm
//    - Furniture/Containers → FurnitureExtensions.dm
//    - Everything else → MiscExtensions.dm
//
// 2. Add UseObject override to the object type:
//    
//    obj/YourObject
//        UseObject(mob/user)
//            if(user in range(1, src))
//                // Your interaction logic here
//                return 1
//            return 0
//
// 3. Add file include to Pondera.dme (if creating new extension file)
//
// 4. Build and test (E key should now work on your object)

// ==================== COMPILATION ORDER ====================
// 
// CRITICAL: Include order matters for atom/proc/UseObject definitions
// Current order in Pondera.dme:
//
// 1. Macros.dm (defines atom/proc/UseObject base)
// 2. UseObjectExtensions.dm (overrides on objects)
// 3. GatheringExtensions.dm (gathering objects)
// 4. SkillExtensions.dm (crafting/NPC objects)
// 5. FurnitureExtensions.dm (furniture)
// 6. MiscExtensions.dm (misc objects)
//
// If adding new extension files, insert them after Macros.dm
// but before other system files (obj.dm, Basics.dm, etc.)

// ==================== TROUBLESHOOTING ====================
//
// Q: E-key doesn't work on my object
// A: 1) Check UseObject is defined on the object type
//    2) Verify the object is in range (typically 1 tile)
//    3) Check that UseObject returns 1 on success
//    4) Rebuild with 'dm: build - Pondera.dme'
//
// Q: E-key works but doesn't do anything
// A: 1) Verify the Click/DblClick handler exists
//    2) Check for range() issues (user might be too far)
//    3) Confirm object is not blocked by density/layer
//
// Q: I get "undefined var" errors when building
// A: 1) Check variable scoping (use src.varname)
//    2) Verify variables exist on the object type
//    3) Check file include order in Pondera.dme
//
// Q: Should UseObject return 1 or 0?
// A: Return 1 if interaction succeeded (object handled it)
//    Return 0 if interaction failed (object ignored it)
//    This allows fallback behavior if needed

// ==================== STATISTICS ====================
//
// Total Interactive Object Types with E-Key Support: 100+
// Extension Files: 5
// Supported Interactions: 
//    - Entry/Exit (doors, exits)
//    - Storage (containers, crates, chests)
//    - Crafting (anvils, forges, cooking, alchemy)
//    - Gathering (trees, rocks, water, plants)
//    - NPCs (dialogue, trading)
//    - Furniture (beds, tables, chairs)
//    - Decoration (lamps, signs, banners)
//    - Navigation (compasses, sundials)
//
// Build Status: ✓ ZERO ERRORS, ZERO WARNINGS

