/*
================================================================================
  Advanced Sound Engine - Music Channels & Positional Audio Updates
================================================================================

This engine provides advanced sound management with:
- Location-based sounds with positional audio (updates as player moves)
- Smooth fading in/out between music tracks
- Dual music channel pairs (channels 1-2 and 3-4) with automatic crossfading
- Dynamic sound channel allocation for repeated sounds
- Per-sound volume, frequency, environment, and falloff control

Key Procs:
- _SoundEngine(): Play positional effect sounds with range-based lifecycle
- _MusicEngine(): Play background music with smooth fade transitions
- musicChannel(): Allocate music channels in pairs for crossfading
- firstChannel(): Dynamically allocate sound effect channels
- /sound/update(): Handle 3D positioning and lifecycle management

Music Channel Architecture:
- Channels 1-2: First music pair (MUSIC_CHANNEL_1=1024, MUSIC_CHANNEL_2=1023)
- Channels 3-4: Second music pair (MUSIC_CHANNEL_3=1022, MUSIC_CHANNEL_4=1021)
- Fade channels: Automatically paired for crossfading (see MUSIC_CHANNELS_ASSOC)

SoundEngine: Programmed by Fushimi (Skype: live:fushimi_1)
Updated with documentation and cleanup.

================================================================================
*/

// Debug flag: uncomment to enable debug output
// #define SE_DEBUG

// Music channel associations for smooth crossfading
// Maps each music channel to its fade channel pair
#define MUSIC_CHANNELS_ASSOC list("1" = 2, "2" = 1, "3" = 4, "4" = 3)

// Reserved channels for background music playback
// Channels 1-2: First music pair
// Channels 3-4: Second music pair
// Fade channels (2 and 4) handle smooth transitions
#define MUSIC_CHANNEL_1 1024
#define MUSIC_CHANNEL_2 1023
#define MUSIC_CHANNEL_3 1022
#define MUSIC_CHANNEL_4 1021
#if DM_VERSION < 400
    #error This compiler is outdated. Please upgrade to atleast BYOND 4.0
#else
client
    var/tmp
        sound_channels[1]        // Initializes a list with a single null index.
        music_channels[4]        // List of 4 channels. (4 channels is more than enough for background music)
        music_playing[2]         // Can play two songs at the same time. (In four channels, two channels for music, two for fades.

    /**
     * musicChannel() - Allocate music channels in pairs for crossfading
     * 
     * Finds an available channel within the music channel pair associated with the
     * given channel ID. Maintains two separate music channel pairs for simultaneous
     * playback and smooth crossfading.
     *
     * @param sound/sound - The sound to allocate a channel for
     * @param channel - Target music channel (MUSIC_CHANNEL_1, 2, 3, or 4)
     * @param replace - Whether to replace an existing sound (not currently used)
     * @return The allocated channel index (1-4) or existing channel if occupied
     */
    proc/musicChannel(sound/sound, channel, replace=0)
        if(channel == MUSIC_CHANNEL_1 || channel == MUSIC_CHANNEL_2)
            var/i = music_playing[1]
            if(i)
                music_channels[(i==1 ? 2 : 1)] = "\ref[sound]"
            else if(isnull(music_channels[1]))
                music_channels[1] = "\ref[sound]"
                . = 1
            else if(isnull(music_channels[2]))
                music_channels[2] = "\ref[sound]"
                . = 2
            if(!.)
                . = i

        if(channel == MUSIC_CHANNEL_3 || channel == MUSIC_CHANNEL_4)
            var/i = music_playing[2]
            if(i)
                music_channels[(i==3 ? 4 : 3)] = "\ref[sound]"
            else if(isnull(music_channels[3]))
                music_channels[3] = "\ref[sound]"
                . = 3
            else if(isnull(music_channels[4]))
                music_channels[4] = "\ref[sound]"
                . = 4
            if(!.)
                . = i

    /**
     * firstChannel() - Find and allocate an available sound effect channel
     *
     * Searches the sound_channels list for an available slot. If no slots exist,
     * dynamically expands the list. Stores a reference to the sound for tracking.
     * Channels 1-100 are reserved for dynamic sounds; repeated sounds use 100+.
     *
     * @param sound/sound - The sound to allocate a channel for
     * @return The allocated channel index, or new index if list expanded
     */
    proc/firstChannel(sound/sound)
        if(sound_channels.len==1 && isnull(sound_channels[1]))
            sound_channels[1] = "\ref[sound]"
            return 1

        for(var/i in 1 to sound_channels.len)
            if(isnull(sound_channels[i]))
                sound_channels[i] = "\ref[sound]"
                return i

        . = ++sound_channels.len
        sound_channels[sound_channels.len] = "\ref[sound]"
        return .

/sound
    var/tmp
        timesToRepeat = null      // Number of times to repeat before stopping
        range = 0                 // Audible range in tiles
        die = FALSE               // Flag to mark sound for deletion

    /**
     * update() - Update 3D sound position and manage lifecycle
     *
     * Called repeatedly for sounds with range limitations. Updates the sound's
     * 3D position based on client and location, applying isometric coordinate
     * transformations. Handles out-of-range deletion and repeat count tracking.
     *
     * Position Calculation (3D isometric):
     * - Distance X: location.x - client.mob.x
     * - Distance Y: (location.y - client.mob.y + location.z - client.mob.z) * 0.707
     * - Distance Z: (location.y - client.mob.y - location.z + client.mob.z) * 0.707
     *
     * @param client/client - Target player's client
     * @param atom/location - Sound source location
     * @param interval - Sleep interval between updates (default 10 ticks)
     * @param altitude_var - Variable name for vertical positioning (default "layer")
     * @param needsChannel - If TRUE, allocate a channel for this sound
     */
    proc/update(client/client, atom/location, interval = 10, altitude_var = "layer", needsChannel = FALSE)
        ASSERT(client)
        if(needsChannel == TRUE)
            src.channel = (client.firstChannel(src) * 10)
        
        #ifdef SE_DEBUG
            world<<"[src.channel*10] channel"
        #endif
        
        if(location && location!=client)
            #ifdef SE_DEBUG
                world<<"[src.x], [src.y], [src.z]"
            #endif
            src.x = location.x - client.mob.x
            var/sy = location.y - client.mob.y
            var/sz = location.vars[altitude_var] - client.mob.vars[altitude_var]
            src.y = (sy + sz) * 0.70710678118655
            src.z = (sy - sz) * 0.70710678118655
            #ifdef SE_DEBUG
                world<<"[src.x], [src.y], [src.z]  - [src.channel]"
            #endif
        
        if(src.die || src.repeat)
            if(src.die || get_dist(client.mob, location) > src.range*2)
                client << sound(null,0, wait = 1, channel = src.channel)
                client.sound_channels[(src.channel/10)] = null
                #ifdef SE_DEBUG
                    world<<"[src.channel*10] channel"
                #endif
                if((src.channel/10) == client.sound_channels.len)
                    client.sound_channels.len--
                del src

        src.status |= SOUND_UPDATE
        client << src
        if(src.repeat)
            spawn(interval) src.update(client, location, interval, altitude_var, FALSE)
        
        #ifdef SE_DEBUG
            world<<"called update([client], [location], [interval])"
        #endif
        
        if(!isnull(src.timesToRepeat))
            if(!timesToRepeat--)
                src.repeat = 0
                src.timesToRepeat = null
                src.die = TRUE


/**
 * _SoundEngine() - Play positional sound effect with range-based lifecycle
 *
 * Plays a sound to all players within audible range. The sound's 3D position
 * updates continuously until the player moves out of range*2, at which point
 * the sound stops and is deleted. Supports repeated sounds with optional repeat
 * count limits.
 *
 * @param sound - Sound file or sound object to play
 * @param atom/location - Source location of the sound
 * @param range - Audible distance in tiles (real range = range*2)
 * @param channel - Audio channel (-1 for auto-allocation)
 * @param volume - Sound volume (0-100, default 100)
 * @param repeat - Loop continuously (1) or play once (0)
 * @param repeat_times - Repeat this many times, then stop (null = infinite if repeat=1)
 * @param interval - Sleep interval between position updates (default 10 ticks)
 * @param falloff - Falloff distance (default = range, affects audio attenuation)
 * @param environment - Audio environment effect ID (default -1 for none)
 * @param frequency - Audio frequency adjustment (default 0 for no change)
 * @param altitude_var - Variable for vertical positioning (default "layer")
 * @return The sound object created, or null if invalid
 */
proc/_SoundEngine(sound, atom/location, range=1, channel=-1, volume=100, repeat=0, repeat_times=null, interval=10, falloff=range, environment=-1, frequency=0, altitude_var="layer")
    if(channel == null)
        channel = -1

    if(!sound)
        return null

    var/sound/S = null
    var/list/playersToSend = list()

    for(var/mob/M in hearers(range*2, location))
        if(M.client)
            playersToSend.Add(M.client)

    for(var/i in 1 to playersToSend.len step 1)
        var client/client = playersToSend[i]
        if(!client)
            continue

        S = sound(sound)

        S.channel = channel
        S.frequency = frequency
        S.environment = environment
        S.volume = volume
        S.repeat = repeat
        S.range = range
        S.timesToRepeat = repeat_times
        S.falloff = falloff
        
        #ifdef SE_DEBUG
            world<<"calling update()"
        #endif

        spawn S.update(client, location, interval, altitude_var, (repeat ? TRUE : FALSE))

    return S


/*
 * _MusicEngine() - Background music with smooth fade transitions
 * Plays music on specified channel with fade-in/fade-out effects
 * 
 * Parameters:
 * - sound: Music file path (e.g., 'snd/music/ambient.wav')
 * - client: Target client to receive music
 * - channel: Music channel (1-4; paired channels 1-2 and 3-4 for crossfading)
 * - pause: Whether to pause the music (0=play, 1=pause)
 * - repeat: Whether to loop music (0=play once, 1=loop infinitely)
 * - wait: Internal flag (unused)
 * - volume: Volume level (0-100, default 40)
 * - instant: Skip fade-in (0=fade in, 1=instant play)
 * - time: Fade duration in deciseconds (default 20 = 2 seconds)
 * - increments: Number of fade steps (default 10)
 */
proc/_MusicEngine(sound, client/listener_client, channel=MUSIC_CHANNEL_1, pause=0, repeat=0, wait=0, volume=40, instant=0, time=20, increments=10)
	if(!sound || !listener_client)
		return null
	
	var/sound/S = sound(sound)
	
	// Basic setup
	S.channel = channel
	S.volume = instant ? volume : 0  // Start at 0 if fading in
	S.repeat = repeat  // 0=play once, 1=loop
	
	// Send to client
	listener_client << S
	
	// Fade in if not instant
	if(!instant && time > 0 && increments > 0)
		var/step_volume = volume / increments
		var/step_time = time / increments
		
		for(var/i = 1; i <= increments; i++)
			sleep(step_time)
			S.volume = step_volume * i
			listener_client << S
	
	return S
#endif