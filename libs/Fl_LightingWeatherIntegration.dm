// ============================================================================
// FILE: libs/Fl_LightingWeatherIntegration.dm
// PURPOSE: Integrate lighting system with WeatherSeasonalIntegration callbacks
// INTEGRATION: Responds to weather changes (rain, snow, fog, storms) to create
//              weather-specific ambient lighting and effects
// ============================================================================

// Weather-specific lighting configurations
var/global/list/WEATHER_LIGHTING = list(
	WEATHER_CLEAR = list(
		"color" = "#FFFFFF",
		"intensity" = 1.0,
		"darkness" = 0.0,
		"description" = "Clear skies - neutral daylight"
	),
	WEATHER_RAIN = list(
		"color" = "#8899BB",     // Cool blue-grey
		"intensity" = 0.7,       // Darker under clouds
		"darkness" = 0.15,
		"description" = "Rainy - cool overcast light"
	),
	WEATHER_THUNDERSTORM = list(
		"color" = "#555588",     // Dark stormy blue
		"intensity" = 0.5,       // Very dark
		"darkness" = 0.35,
		"description" = "Thunderstorm - intense darkness"
	),
	WEATHER_SNOW = list(
		"color" = "#F0F8FF",     // Alice blue (cold white)
		"intensity" = 0.8,       // Snow is bright but overcast
		"darkness" = 0.1,
		"description" = "Snowing - bright but cool"
	),
	WEATHER_HAIL = list(
		"color" = "#D0E8FF",     // Bright cold blue
		"intensity" = 0.6,       // Hail blocks some light
		"darkness" = 0.2,
		"description" = "Hailing - cold bright white"
	),
	WEATHER_FOG = list(
		"color" = "#CCCCCC",     // Grey
		"intensity" = 0.4,       // Very limited visibility
		"darkness" = 0.4,
		"description" = "Foggy - muted grey light"
	),
	WEATHER_DUST_STORM = list(
		"color" = "#D4A574",     // Dusty brown
		"intensity" = 0.3,       // Near total darkness from dust
		"darkness" = 0.5,
		"description" = "Dust storm - dark brown haze"
	),
	WEATHER_DRIZZLE = list(
		"color" = "#99AABB",     // Light grey-blue
		"intensity" = 0.85,      // Light rain
		"darkness" = 0.05,
		"description" = "Drizzling - light rain, overcast"
	)
)

// ============================================================================
// WEATHER CHANGE CALLBACK INTEGRATION
// ============================================================================

/datum/seasonal_weather_manager/proc/InitializeLightingCallbacks()
	// Called from InitializationManager.dm during Phase 2 (weather system)
	if(!world_initialization_complete) return
	
	world.log << "LIGHTING SYSTEM: Integrated with weather effects"

// Update lighting when weather changes
/datum/seasonal_weather_manager/proc/OnWeatherChange(old_weather, new_weather)
	// Called whenever current_weather changes
	if(!world_initialization_complete) return
	
	ApplyWeatherLighting(new_weather)

// ============================================================================
// CORE: Apply weather-specific lighting
// ============================================================================

proc/ApplyWeatherLighting(var/weather_type)
	/// Apply ambient lighting based on current weather condition
	/// Creates fog glow for fog, rain shimmer for storms, etc.
	
	if(!world_initialization_complete) return
	
	var/list/weather_config = WEATHER_LIGHTING[weather_type]
	if(!weather_config)
		weather_config = WEATHER_LIGHTING[WEATHER_CLEAR]  // Fallback
	
	// Apply global lighting adjustment
	var/color = weather_config["color"]
	var/intensity = weather_config["intensity"]
	var/darkness = weather_config["darkness"]
	
	set_global_lighting(intensity=intensity, color_hex=color, darkness=darkness)
	
	world.log << "WEATHER_LIGHTING: [weather_config["description"]] (intensity=[intensity], color=[color])"
	
	// Create weather-specific light effects
	switch(weather_type)
		if(WEATHER_RAIN)
			CreateRainLightEffects()
		
		if(WEATHER_THUNDERSTORM)
			CreateStormLightEffects()
		
		if(WEATHER_SNOW)
			CreateSnowLightEffects()
		
		if(WEATHER_FOG)
			CreateFogLightEffects()
		
		if(WEATHER_DUST_STORM)
			CreateDustStormEffects()

// ============================================================================
// WEATHER-SPECIFIC LIGHT EFFECT GENERATORS
// ============================================================================

proc/CreateRainLightEffects()
	/// Create soft rain glow for all locations
	/// Ambient blue-grey light simulating rain droplets
	
	for(var/area/A in world)
		if(!A) continue
		
		// Create subtle rain shimmer lights
		for(var/turf/T in A.contents)
			if(rand(1, 100) > 70) continue  // Only 30% of turfs get effect lights
			
			emit_rain_light(T, intensity=0.2)

proc/CreateStormLightEffects()
	/// Create dramatic storm lighting with periodic lightning flashes
	/// Intense dark blue base + lightning strikes
	
	// Spawn background lightning effects every 2-5 seconds
	spawn()
		set background = 1
		set waitfor = 0
		
		while(1)
			sleep(rand(100, 250))  // 2-5 second intervals
			
			// Random location gets lightning strike
			var/turf/T = locate(rand(1, world.maxx), rand(1, world.maxy), 1)
			if(T)
				emit_weather_lightning(T, intensity=2.0, duration=10)

proc/CreateSnowLightEffects()
	/// Create bright shimmer effect for snow
	/// Snow reflects light, making it bright despite overcast
	
	for(var/area/A in world)
		if(!A) continue
		
		// Create scattered snow shimmer lights
		for(var/turf/T in A.contents)
			if(rand(1, 100) > 60) continue  // 40% coverage
			
			emit_snow_light(T, intensity=0.3)

proc/CreateFogLightEffects()
	/// Create fog mist ambient lighting
	/// Fog diffuses light, creating hazy glow
	
	for(var/area/A in world)
		if(!A) continue
		
		// Fog creates pervasive misting
		for(var/turf/T in A.contents)
			if(rand(1, 100) > 50) continue  // 50% coverage
			
			emit_fog_light(T, intensity=0.2)

proc/CreateDustStormEffects()
	/// Create dark brown haze from dust storm
	/// Low visibility, particles in air
	
	for(var/area/A in world)
		if(!A) continue
		
		// Dense dust cloud lighting
		for(var/turf/T in A.contents)
			// More particles than other weather
			if(rand(1, 100) > 30) continue  // 70% coverage
			
			// Custom dust particle light
			create_light_emitter(T, 8, 0.15, "#B8860B", 2, 0)

// ============================================================================
// CLEANUP WHEN WEATHER CLEARS
// ============================================================================

proc/ClearWeatherLights()
	/// Remove all weather-specific light effects when weather clears
	
	for(var/datum/light_emitter/E in ACTIVE_WEATHER_LIGHTS)
		if(E && E.active)
			E.cleanup()
	
	ACTIVE_WEATHER_LIGHTS = list()
	
	// Reset to clear sky lighting
	ApplyWeatherLighting(WEATHER_CLEAR)

// ============================================================================
// INTEGRATION WITH EXISTING WEATHER SYSTEM
// ============================================================================

// Hook for when weather system changes (from WeatherSeasonalIntegration.dm)
/datum/seasonal_weather_manager/proc/UpdateWeatherLighting(new_weather)
	// Called when weather changes
	
	// Clean up old weather lights
	ClearWeatherLights()
	
	// Apply new weather lighting
	ApplyWeatherLighting(new_weather)
	
	current_weather = new_weather

