#define TIME_STEP 5
#define WAKE_REPEAT_DELAY 10
#define IDLE_REPEAT_DELAY 10
#define MAX_WAKE_DISTANCE 11
#define REFLECTION_PLANE -1
#define LIGHTING_PLANE 2
#define EFFECTS_LAYER 15

#define floor(x) round(x)
#define ceil(x) (-round(-x))

#define DAY 1
#define NIGHT 2

#define MOVE_SLIDE 1
#define MOVE_JUMP 2
#define MOVE_TELEPORT 4

#define TILE_WIDTH  32
#define TILE_HEIGHT 32
#define TICK_LAG    4 //set to (10 / world.fps) a define is faster, though

// Continent & World System
#define CONTINENT_PEACEFUL  (1<<0)  // No combat, safe sandbox
#define CONTINENT_CREATIVE  (1<<1)  // Building-focused, no pressure
#define CONTINENT_COMBAT    (1<<2)  // PvP, survival, competition

#define CONT_STORY     "story"        // Kingdom of Freedom (procedural with story)
#define CONT_SANDBOX   "sandbox"     // Creative Sandbox (peaceful building)
#define CONT_PVP       "pvp"         // Battlelands (competitive survival)
#define CONT_ASCENSION "ascension"   // Ascension Realm (peaceful creative mastery)

// Soil System Constants
#define SOIL_DEPLETED 0
#define SOIL_BASIC 1
#define SOIL_RICH 2

// Compost Types
#define COMPOST_BASIC 1
#define COMPOST_BONE_MEAL 2
#define COMPOST_KELP 3

// Rank System Constants
#define RANK_BUILDING "brank"
#define RANK_SMITHING "smirank"
#define RANK_SMELTING "smerank"           // Smelting rank
#define RANK_FISHING "frank"
#define RANK_MINING "mrank"
#define RANK_COOKING "crank"
#define RANK_CRAFTING "crafting_rank"
#define RANK_GARDENING "garden_rank"
#define RANK_FARMING "farming_rank"
#define RANK_WOODWORKING "woodworking_rank"
#define RANK_WOODCUTTING "woodworking_rank"  // Legacy alias for RANK_WOODWORKING
#define RANK_CARVING "whittling_rank"        // Carving renamed to Whittling
#define RANK_DIGGING "drank"
#define RANK_BOTANY "botany_rank"
#define RANK_SPROUTING "botany_rank"        // Legacy alias for RANK_BOTANY (sprout harvesting)
#define RANK_SPROUT_CUTTING "botany_rank"   // Sprout Cutting renamed to Botany
#define RANK_WHITTLING "whittling_rank"
#define RANK_POLE "whittling_rank"           // Legacy alias for RANK_WHITTLING (pole carving)
#define RANK_COMBAT "combat_rank"            // Combat/Melee combat rank
#define RANK_SEARCHING "searching_rank"      // Searching/Item discovery rank
#define RANK_DESTROYING "destroying_rank"    // Destroying/Wall destruction rank
#define MAX_RANK_LEVEL 5

// Temperature Constants
#define TEMP_HOT 3
#define TEMP_WARM 2
#define TEMP_COOL 1

// Refinement Tool Constants
#define REFINE_TOOL_FILE 1
#define REFINE_TOOL_WHETSTONE 2
#define REFINE_TOOL_POLISH_CLOTH 3

// Refinement Stage Constants
#define REFINE_STAGE_UNREFINED 0
#define REFINE_STAGE_FILED 1
#define REFINE_STAGE_SHARPENED 2
#define REFINE_STAGE_POLISHED 3

// Season Constants
#define SEASON_SPRING "Spring"
#define SEASON_SUMMER "Summer"
#define SEASON_AUTUMN "Autumn"
#define SEASON_WINTER "Winter"