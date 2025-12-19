# Pondera File Index & Quick Reference

**Purpose**: Fast lookup for file locations by category, system, or function  
**Total Files Indexed**: 699 DM files, organized by subsystem  
**Build Status**: 0 errors, 40 warnings

---

## Quick Navigation by System

### **CORE SYSTEMS**

#### Persistence (SQLite v2.0)
| File | Lines | Purpose |
|------|-------|---------|
| `dm/SQLiteUtils.dm` | 430 | SQL escaping, JSON parsing |
| `dm/SQLitePersistenceLayer.dm` | 626 | Character save/load, transactions |
| `dm/SQLiteIntegration.dm` | 176 | Login/logout hooks |
| `db/schema.sql` | 200+ | Database schema, 20+ tables |

#### Initialization & Boot
| File | Purpose |
|------|---------|
| `dm/InitializationManager.dm` | Phase system orchestrator (5 phases, 400 ticks) |
| `dm/CrashRecovery.dm` | Orphaned player restoration (Phase 1B) |
| `Pondera.dme` | Compile order (critical!) |
| `!defines.dm` | Global constants |

#### Movement & Physics
| File | Purpose |
|------|---------|
| `dm/movement.dm` | Direction input, sprint, speed calculation |
| `dm/Phase13D_MovementSystem.dm` | Modern movement (553 lines) |
| `libs/movement.dm` | Movement utility functions |
| `libs/Fl_ElevationSystem.dm` | Multi-level vertical system |

---

### **COMBAT & PROGRESSION**

#### Combat
| File | Lines | Purpose |
|------|-------|---------|
| `dm/CombatSystem.dm` | - | Core damage/hit system |
| `dm/CombatProgression.dm` | - | XP/leveling |
| `dm/EnvironmentalCombatModifiers.dm` | - | Weather effects on damage |
| `dm/DamascusSteelTutorialSystem.dm` | - | Combat tutorials |

#### Skills & Ranks
| File | Purpose |
|------|---------|
| `dm/UnifiedRankSystem.dm` | 8 rank types (fishing, mining, crafting, etc.) |
| `dm/CookingSkillProgression.dm` | Recipe unlock by skill level |
| `dm/CelestialTierProgressionSystem.dm` | Tier progression |
| `dm/AscensionModeSystem.dm` | End-game progression |

---

### **SURVIVAL & ECONOMY**

#### Consumption System
| File | Purpose |
|------|---------|
| `dm/ConsumptionManager.dm` | CONSUMABLES registry |
| `dm/HungerThirstSystem.dm` | Hunger/thirst tick system |
| `dm/EnvironmentalTemperatureSystem.dm` | Temperature affects consumption |
| `dm/PlantSeasonalIntegration.dm` | Season gates consumption items |

#### Cooking & Recipes
| File | Purpose |
|------|---------|
| `dm/CookingSystem.dm` | RECIPES registry, cooking mechanics |
| `dm/CookingSkillProgression.dm` | Skill-based unlock |
| `dm/SkillRecipeUnlock.dm` | Dual-unlock (skill + inspection) |
| `dm/NPCRecipeHandlers.dm` | NPC teaching integration |

#### Economy & Markets
| File | Purpose |
|------|---------|
| `dm/DualCurrencySystem.dm` | Lucre vs Materials |
| `dm/DynamicMarketPricingSystem.dm` | Supply/demand pricing |
| `dm/DynamicZoneManager.dm` | Territory price modifiers |
| `dm/EconomicGovernanceSystem.dm` | Kingdom treasury |
| `dm/KingdomMaterialExchange.dm` | Kingdom trading |
| `dm/MarketBoardUI.dm` | Player trading interface |

#### Crafting
| File | Purpose |
|------|---------|
| `dm/AnvilCraftingSystem.dm` | Smithing |
| `dm/CarvingKnifeSystem.dm` | Carving recipes |
| `dm/CompostSystem.dm` | Composting |
| `dm/CraftingIntegration.dm` | Cross-system linking |

---

### **TERRITORY & PERMISSIONS**

#### Deeds
| File | Purpose |
|------|---------|
| `dm/deed.dm` | Deed region definitions |
| `dm/DeedPermissionSystem.dm` | Zone-based access control |
| `dm/DeedPermissionCache.dm` | Permission caching |
| `dm/DeedDataManager.dm` | Deed data persistence |
| `dm/DeedEconomySystem.dm` | Maintenance, freezing |
| `dm/DeedAntiGriefingSystem.dm` | Abuse prevention |
| `dm/DeedFreezeFunctionality.dm` | 24-hour grace period system |

#### Building
| File | Purpose |
|------|---------|
| `dm/jb.dm` | Building system (600+ lines) |
| `dm/BuildingMenuSystem.dm` | Build UI menu |
| `dm/BuildSystemEKeyIntegration.dm` | E-key building integration |

---

### **EQUIPMENT & INVENTORY**

#### Equipment
| File | Purpose |
|------|---------|
| `dm/CentralizedEquipmentSystem.dm` | Unified slots system |
| `dm/EquipmentOverlayIntegration.dm` | Visual rendering |
| `dm/EquipmentCompatibilityAdapter.dm` | Armor compatibility |
| `dm/EquipmentVisualizationWorkaround.dm` | Display fixes |

#### Inventory & Hotbar
| File | Purpose |
|------|---------|
| `dm/AutoHotbarPickup.dm` | Auto-slot items |
| `dm/ConsumableHotbarSystem.dm` | Quick-use hotbar |
| `Pondera-Recoded/dm/Inventory.dm` | Inventory UI (recoded) |

#### Items & Weapons
| File | Purpose |
|------|---------|
| `dm/obj.dm` | Object base definitions |
| `dm/armors.dm` | Armor definitions |
| `dm/items.dm` | Item definitions |
| `Pondera-Recoded/dm/Objects.dm` | Object classes (recoded) |

---

### **WORLD & TERRAIN**

#### Procedural Generation
| File | Lines | Purpose |
|------|-------|---------|
| `mapgen/backend.dm` | 200+ | Main generator loop |
| `mapgen/_seed.dm` | 50+ | Randomization |
| `mapgen/_water.dm` | 100+ | Water generation |
| `mapgen/BiomeRegistrySystem.dm` | 100+ | Biome registry |

#### Biomes
| File | Purpose |
|------|---------|
| `mapgen/biome_temperate.dm` | Forest/grassland |
| `mapgen/biome_arctic.dm` | Snow/ice |
| `mapgen/biome_desert.dm` | Sand/dune |
| `mapgen/biome_rainforest.dm` | Tropical |
| `mapgen/biome_pyroclastic.dm` | Volcanic |

#### Terrain & Turfs
| File | Purpose |
|------|---------|
| `dm/Turf.dm` | Turf definitions (500+ turfs) |
| `dm/lg.dm` | Grass/terrain |
| `dm/Terrain.dm` | Terrain systems |
| `dm/ElevationTerrainRefactor.dm` | Elevation integration |

#### Lighting & Effects
| File | Purpose |
|------|---------|
| `dm/DayNight.dm` | Day/night cycles |
| `dm/DirectionalLighting.dm` | Dynamic lighting |
| `libs/dynamiclighting/` | Advanced lighting (vendor) |
| `dm/Particles-Weather.dm` | Recoded, weather effects |

---

### **NPCs & DIALOGUE**

#### NPCs
| File | Purpose |
|------|---------|
| `dm/npcs.dm` | NPC spawning/behavior |
| `dm/NPCRecipeHandlers.dm` | Recipe teaching |
| `dm/NPCRecipeIntegration.dm` | Teaching integration |
| `dm/Phase13B_NPCMigrationsAndSupplyChains.dm` | NPC routes, caravans |

#### Dialogue & Factions
| File | Purpose |
|------|---------|
| `dm/FactionSystem.dm` | Faction tracking |
| `dm/FactionQuestIntegrationSystem.dm` | Quest integration |
| `dm/EliteOfficersSystem.dm` | Special NPC types |

---

### **CHARACTER SYSTEMS**

#### Character Data
| File | Purpose |
|------|---------|
| `dm/CharacterData.dm` | Character datum (skills, inventory) |
| `dm/CharacterCreationUI.dm` | Creation flow |
| `dm/CharacterCreationGUI.dm` | GUI (DMF) |
| `dm/CharacterCreationIntegration.dm` | Integration |
| `Pondera-Recoded/dm/Classes.dm` | Class definitions (recoded) |

#### UI & Display
| File | Purpose |
|------|---------|
| `dm/CustomUI.dm` | Main HUD system |
| `dm/CurrencyDisplayUI.dm` | Currency display |
| `dm/ExtendedHUDSubsystems.dm` | HUD extensions |
| `dm/BuildingMenuUI.dm` | Building menu |

---

### **PHASE 13 SYSTEMS** ⭐

| File | Lines | Purpose | Status |
|------|-------|---------|--------|
| `dm/InitializationManager.dm` | 300+ | Boot orchestration | ✅ Complete |
| `dm/Phase13A_WorldEventsAndAuctions.dm` | 200+ | Dynamic events, auctions | ✅ Stub procs |
| `dm/Phase13B_NPCMigrationsAndSupplyChains.dm` | 250+ | NPC routes, logistics | ✅ Stub procs |
| `dm/Phase13C_EconomicCycles.dm` | 200+ | Market cycles | ✅ Stub procs |
| `dm/Phase13D_MovementSystem.dm` | 553 | Modern movement | ✅ Complete |

---

### **ADMIN & DEBUG**

| File | Purpose |
|------|---------|
| `dm/AdminSystemRefactor.dm` | Admin commands |
| `dm/AdminCommandsExpanded.dm` | Expanded verbs |
| `dm/AdminCombatVerbs.dm` | Combat testing |
| `dm/F0laks Debug Messager.dm` | Centralized logging |
| `dm/EditCode.dm` | In-game code editor |
| `mapgen/_debugtimer.dm` | Frame timing |

---

### **MISCELLANEOUS**

#### Specialized Systems
| File | Purpose |
|------|---------|
| `dm/ClimbingSystem.dm` | Climbing mechanics |
| `dm/AudioIntegrationSystem.dm` | Sound spatial audio |
| `dm/ContinentTeleportationSystem.dm` | Continent transport |
| `dm/ContinentSpawnZones.dm` | Spawn zone management |
| `dm/ContinentLobbyHub.dm` | Hub area |
| `dm/BlankAvatarSystem.dm` | Avatar customization |
| `dm/AnimalHusbandrySystem.dm` | Animal management |

#### Recoded System (Parallel)
| File | Purpose |
|------|---------|
| `Pondera-Recoded/dm/Basic.dm` | Basics (recoded) |
| `Pondera-Recoded/dm/Classes.dm` | Classes (recoded) |
| `Pondera-Recoded/dm/DayNight.dm` | Day/night (recoded) |
| `Pondera-Recoded/dm/Lighting.dm` | Lighting (recoded) |
| `Pondera-Recoded/dm/UI.dm` | UI (recoded) |

---

## File Organization by Function

### **Most Critical** (Compilation & Boot)
1. `Pondera.dme` - Must have correct include order
2. `!defines.dm` - Global constants
3. `dm/InitializationManager.dm` - Phase orchestration
4. `dm/SQLitePersistenceLayer.dm` - Persistence

### **Frequently Modified** (Active Development)
1. `dm/Phase13*.dm` - Phase 13 systems
2. `dm/CookingSystem.dm` - Recipe updates
3. `dm/DynamicMarketPricingSystem.dm` - Economy balancing
4. `mapgen/biome_*.dm` - Resource distribution

### **Largest Files** (1000+ lines)
1. `dm/SavingChars.dm` - Character saving (legacy)
2. `dm/jb.dm` - Building system
3. `dm/Phase13A_WorldEventsAndAuctions.dm`
4. `mapgen/backend.dm` - Map generation

---

## By Technology/Concept

### **SQLite Integration**
- Schema: `db/schema.sql`
- Utilities: `dm/SQLiteUtils.dm`
- Layer: `dm/SQLitePersistenceLayer.dm`
- Integration: `dm/SQLiteIntegration.dm`
- **Phases covered**: All 13 phases (tables)

### **Multi-Level Elevation**
- Core: `libs/Fl_ElevationSystem.dm`
- Atoms: `libs/Fl_AtomSystem.dm`
- Terrain integration: `dm/ElevationTerrainRefactor.dm`
- **elevel range**: 1.0-3.0+ (decimal)

### **Dual-Unlock Recipes**
- Registry: `dm/CookingSystem.dm` (RECIPES dict)
- Skill unlock: `dm/CookingSkillProgression.dm`
- Item unlock: `ItemInspectionSystem.dm` (assumed)
- NPC teaching: `dm/NPCRecipeHandlers.dm`

### **Economic Simulation**
- Pricing: `dm/DynamicMarketPricingSystem.dm`
- Dual currency: `dm/DualCurrencySystem.dm`
- Governance: `dm/EconomicGovernanceSystem.dm`
- Cycles: `dm/Phase13C_EconomicCycles.dm`

---

## Compile Order Rules

**Located in**: `Pondera.dme`

### Order Sequence
1. `!defines.dm` (constants)
2. `Interfacemini.dmf` (UI)
3. Library files (`libs/`)
4. Foundation systems (`dm/Basics.dm`, `CharacterData.dm`)
5. Core systems (`movement`, `combat`, `persistence`)
6. Specialized systems (`cooking`, `farming`, `deeds`)
7. NPC & recipe systems
8. Display/UI systems
9. **Mapgen & InitializationManager LAST** (dependencies)

### Critical Rules
- `MapgenManager.dm` must come BEFORE `mapgen/backend.dm`
- `InitializationManager.dm` must come AFTER all system definitions
- `SQLitePersistenceLayer.dm` must come BEFORE `SQLiteIntegration.dm`

---

## Quick Stats

| Metric | Value |
|--------|-------|
| Total DM Files | 699 |
| Core System Files | 85+ |
| Biome Files | 5 |
| Library Files | 15+ |
| Documentation Files | 50+ |
| Lines of Core DM | 150KB+ |
| Database Tables | 20+ |
| Build Time | ~1 second |
| Compilation Status | ✅ 0 errors |
| Warnings | 40 |

---

**Last Updated**: 2025-12-18 via Cappy AI mapping  
**Verification**: File tree + semantic search  
**Completeness**: 95% (edge cases may exist)

---

## Related Notes
- [[Pondera_Codebase_Architecture]] - Full architecture overview
- [[Pondera_Phase13_Status]] - Phase 13 implementation status
- [[Pondera_SQLite_Integration]] - Database details
- [[Pondera_Development_Roadmap]] - Future plans
