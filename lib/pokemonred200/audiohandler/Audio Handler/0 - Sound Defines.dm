#define issound(S) istype(S,/sound)
#define ismusic(S) (issound(S) && S:music)
#define GLOBAL_MUTE 0x0001
#define SEPERATE_MUSIC_VOLUME 0x0002
