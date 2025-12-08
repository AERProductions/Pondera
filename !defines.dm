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

#define CONT_STORY    "story"        // Kingdom of Freedom (procedural with story)
#define CONT_SANDBOX  "sandbox"      // Creative Sandbox (peaceful building)
#define CONT_PVP      "pvp"          // Battlelands (competitive survival)

// Soil System Constants
#define SOIL_DEPLETED 0
#define SOIL_BASIC 1
#define SOIL_RICH 2

// Compost Types
#define COMPOST_BASIC 1
#define COMPOST_BONE_MEAL 2
#define COMPOST_KELP 3