#define TIME_STEP 5
#define WAKE_REPEAT_DELAY 10
#define IDLE_REPEAT_DELAY 10
#define MAX_WAKE_DISTANCE 11
#define REFLECTION_PLANE -1
#define LIGHTING_PLANE 2

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