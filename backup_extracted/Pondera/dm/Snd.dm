/*
================================================================================
  LEGACY: Pondera Sound System (by Fushimi)
================================================================================

DEPRECATED: This file is superseded by SoundEngine.dm (Phase 6+)

This file is retained for reference/historical purposes but is no longer
included in the build. The SoundEngine.dm provides the active sound management
implementation with:
- Location-based positional sound
- Automatic volume attenuation with distance
- Music channel management with smooth fade transitions
- Sound repetition with range-based lifecycle
- Altitude-aware 3D positioning

USE SoundEngine.dm INSTEAD for new audio features.

================================================================================
*/
// --- Channel and Music Configuration ---

// --- Debug Configuration ---
// Uncomment to enable SE_DEBUG mode for verbose console logging during sound operations
// #define SE_DEBUG

// --- Music Channel Association ---
// Maps music channels 1-4 to fade channels for smooth crossfading
#define MUSIC_CHANNELS_ASSOC list("1" = 2, "2" = 1, "3" = 4, "4" = 3)

// --- Reserved Channels for Background Music ---
#define MUSIC_CHANNEL_1 1024  // Primary music channel
#define MUSIC_CHANNEL_2 1023  // Secondary music channel (fades with MUSIC_CHANNEL_1)
#define MUSIC_CHANNEL_3 1022  // Alternate music channel
#define MUSIC_CHANNEL_4 1021  // Alternate music channel (fades with MUSIC_CHANNEL_3)
#if DM_VERSION < 400
    #error This compiler is outdated. Please upgrade to atleast BYOND 4.0
#else
/**
 * Client extension for sound system management.
 */
client
    var/tmp
        sound_channels[1]        // List of active sound channels for this client
        music_channels[4]        // List of 4 music channels
        music_playing[2]         // Track which channel pairs are currently playing

    /**
     * Allocates a music channel for playback, handling crossfading between channel pairs.
     * Music channels are organized in pairs: (1,2) and (3,4), with automatic fading.
     * @param sound Sound datum to allocate
     * @param channel Target channel (MUSIC_CHANNEL_1/2/3/4)
     * @param replace Replacement flag (unused)
     * @return Allocated channel index
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
     * Finds and allocates the first available sound channel.
     * Dynamically expands the channel list when necessary.
     * @param sound Sound datum to allocate a channel for
     * @return Allocated channel index
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

// --- Extended Sound Object ---
/**
 * Extended /sound type with additional fields for engine management and lifecycle.
 */
/sound
    var/tmp
        timesToRepeat = null // Repeat limit (null=infinite repeats)
        range = 0 // Audible radius in tiles
        die = FALSE // Deletion flag

    proc
        /**
         * Updates sound position and volume based on listener location.
         * Handles 3D positioning, repetition, range-based cleanup, and channel allocation.
         * @param client Target client to update sound for
         * @param location Sound source location atom
         * @param interval Update interval between repeats (ticks)
         * @param altitude_var Height variable ('layer', 'elevel', etc.)
         * @param needsChannel If TRUE, allocate a channel for this sound
         */
        update(client/client, atom/location, interval = 10, altitude_var = "layer", needsChannel = FALSE)
            ASSERT(client)
            if(needsChannel == TRUE)
                src.channel = (client.firstChannel(src) * 10)
            #ifdef SE_DEBUG
                world<<"[src.channel*10] channel"
            #endif
            if(location && location!=client)                                        // This part sets the distance from within the sound will be heard by the player.
            #ifdef SE_DEBUG
                world<<"[src.x], [src.y], [src.z]"
            #endif
//              src.falloff = src.range
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
                    client << sound(null,0, wait = 1, channel = src.channel)      // Stops playing the sound in THIS channel. (Other's systems just stops ALL sounds)
                    client.sound_channels[(src.channel/10)] = null
                #ifdef SE_DEBUG
                    world<<"[src.channel*10] channel"
                #endif
                    if((src.channel/10) == client.sound_channels.len)
                        client.sound_channels.len--
                    del src

            src.status |= SOUND_UPDATE
            client << src
            if(src.repeat)  spawn(interval)
                src.update(client, location, interval, altitude_var, FALSE)
            #ifdef SE_DEBUG
                world<<"called update([client], [location], [interval])"
            #endif
            if(!isnull(src.timesToRepeat))
                if(!timesToRepeat--)
                    src.repeat = 0
                    src.timesToRepeat = null
                    src.die = TRUE

/*
Do not pass a value for repeat times unless you actually want it to repeat X times. (0 enables it too.)
*/
proc/_SoundEngine(sound, atom/location, range=1, channel=-1, volume=100, repeat=0, repeat_times=null, interval=10, falloff=range, environment=-1, frequency=0, altitude_var="layer")//BaseRange=10
    if(channel == null)
        channel = -1

    if(!sound) return null

    var/sound/S = null
    var/list/playersToSend = list()
/*
    if(ismob(location))
        if(hasvar(location, "client"))
            playersToSend.Add(location:client)*/

// Still need a better way to do this.

    for(var/mob/M in hearers(range*2, location))
        if(M.client)
            playersToSend.Add(M.client)


    for(var/i in 1 to playersToSend.len step 1)
        var client/client = playersToSend[i]
        if(!client)continue

        S = sound(sound)

        S.channel = channel
        S.frequency = frequency
        S.environment = environment
        S.volume = volume
        S.repeat = repeat
        S.range = range
        S.timesToRepeat = repeat_times
        S.falloff = falloff             // This will let you specify ranges and falloff separately.\
                                            (By default falloff = range | The passed range is multiplied by 2 to get the real range.)\
                                            So range = 5 = falloff = 5 = real_range = 10 where real_range = range*2
    #ifdef SE_DEBUG
        world<<"calling update()"       // Debugging messages just to know where I am at when testing.
    #endif

        spawn S.update(client, location, interval, altitude_var, (repeat ? TRUE : FALSE))       // Updates once, and if needed, recursively updates until out of range.

    return S


proc/_MusicEngine(sound, client/client, channel=MUSIC_CHANNEL_1, pause=0, repeat=0, wait=0, volume=40, instant = 0, time = 20, increments = 10)
    if(!sound || !client)
        return null

    channel = client.musicChannel(sound, client, 0)
    var sound/S = sound(sound)
    var sound/_fade = null

    var channel_to_fade = MUSIC_CHANNELS_ASSOC["[channel]"]

    if(!isnull(client.music_channels[channel_to_fade]))             // We fade the sound
        _fade = locate(client.music_channels[channel_to_fade])
        if(_fade)
            pause = (pause==1 ? SOUND_PAUSED : (pause==2 ? SOUND_MUTE : 0))

    if(instant)
        pause = 0
        wait = 0

    S.channel = channel
    S.status = (pause ? (SOUND_PAUSED | SOUND_UPDATE) : 0) | (SOUND_UPDATE)
    S.repeat = repeat
    S.wait = wait
    if(instant || !_fade)
        S.volume = volume
    else if(_fade)
        S.volume = 0

    client << S

    if(_fade && !instant)
        var d = _fade.volume / increments
        var inc = d
        time = time / increments

        spawn
            for(var/i = 0; i < increments; i++)
                _fade.volume -= d
                if(!S.volume)
                    S.status = 0
                S.volume += inc

                _fade.status |= SOUND_UPDATE
                S.status |= SOUND_UPDATE
                client << _fade
                client << S
                sleep(time)

            S.volume = volume
            S.status |= SOUND_UPDATE
            client << S
            del(_fade)

    return S


#endif

/*
================================================================================
  Usage Guide: Sound Engine Functions
================================================================================

This file provides two main procs for sound playback:

1. _SoundEngine(): Positional sound effects
   - Plays sounds relative to an atom location
   - Automatic volume attenuation with distance
   - Range-based lifecycle management
   - Returns sound datum for manipulation

2. _MusicEngine(): Background music with fading
   - Manages 4 dedicated music channels
   - Smooth fade transitions between tracks
   - Support for pause/resume
   - Automatic crossfading between channel pairs

Both procs spawn updates asynchronously; use spawn() to avoid blocking execution.

================================================================================
*/

