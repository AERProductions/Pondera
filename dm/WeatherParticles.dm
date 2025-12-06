// WeatherParticles.dm — Dynamic weather particle effects integrated with biomes and elevation

// ==================== PARTICLE DEFINITIONS ====================

particles/fog
	width = 1500
	height = 1500
	count = 800
	spawning = 4
	bound1 = list(-1000, -300, -1000)
	lifespan = 1000
	fade = 100
	color = "d3d3d3"
	position = generator("box", list(-600, 200, 0), list(600, 350, 30))
	gravity = list(0, -0.05)
	friction = 0.1
	drift = generator("sphere", 0, 1.5)

particles/mist
	width = 1500
	height = 1500
	count = 400
	spawning = 2
	bound1 = list(-1000, -300, -1000)
	lifespan = 1200
	fade = 120
	color = "e8e8e8"
	position = generator("box", list(-600, 250, 0), list(600, 380, 50))
	gravity = list(0, -0.02)
	friction = 0.05
	drift = generator("sphere", 0, 1)

particles/dust_storm
	width = 1500
	height = 1500
	count = 3000
	spawning = 20
	bound1 = list(-1000, -300, -1000)
	lifespan = 500
	fade = 40
	color = "d2b48c"
	position = generator("box", list(-600, 100, 0), list(600, 450, 80))
	gravity = list(0, 0)
	friction = 0.2
	drift = generator("sphere", 0, 4)

particles/hail
	width = 1500
	height = 1500
	count = 2000
	spawning = 15
	bound1 = list(-1000, -300, -1000)
	lifespan = 400
	fade = 30
	color = "ffffff"
	position = generator("box", list(-600, 350, 0), list(600, 400, 50))
	gravity = list(0, -1)
	friction = 0.5
	drift = generator("sphere", 0, 3)

particles/drizzle
	width = 1500
	height = 1500
	count = 2000
	spawning = 10
	bound1 = list(-1000, -300, -1000)
	lifespan = 600
	fade = 50
	color = "b0c4de"
	position = generator("box", list(-600, 350, 0), list(600, 400, 50))
	gravity = list(0, -0.3)
	friction = 0.15

particles/clear_weather
	width = 0
	height = 0
	count = 0
	spawning = 0
	bound1 = list(-1000, -300, -1000)
	lifespan = 1
	fade = 0
	position = generator("box", list(-600, 350, 0), list(600, 400, 50))
	gravity = list(0, 0)

// ==================== WEATHER EFFECT OBJECTS ====================

obj/weather_fx
	screen_loc = "CENTER"
	var/weather_type = "clear"
	var/zone_id = 0
	var/zone_elevation = 1.0
	var/zone_temperature = 15

	proc/SetWeatherType(type)
		weather_type = type
		UpdateParticles()

	proc/UpdateParticles()
		// Spawn new particles based on weather type
		switch(weather_type)
			if("fog")
				particles = new/particles/fog
			if("mist")
				particles = new/particles/mist
			if("dust_storm")
				particles = new/particles/dust_storm
			if("hail")
				particles = new/particles/hail
			if("drizzle")
				particles = new/particles/drizzle
			else
				particles = new/particles/clear_weather

	proc/PlayWeatherSound()
		set waitfor = 0
		switch(weather_type)
			if("fog", "mist")
				ApplyWeatherSounds("fog", src)
			if("dust_storm")
				ApplyWeatherSounds("dust_storm", src)
			if("hail")
				ApplyWeatherSounds("hail", src)
			if("drizzle", "rain")
				ApplyWeatherSounds("rain", src)

	New(mob/player)
		if(!player) return
		..()

		// Register with player client
		particles = new/particles/clear_weather

	Del()
		..()

// ==================== ELEVATION-AWARE WEATHER SYSTEM ====================

obj/elevation_weather_controller
	var/weather_type = "clear"
	var/last_elevation = 1.0
	var/last_temperature = 15
	var/elevation_check_interval = 10

	New()
		..()
		spawn() CheckElevationWeather()

	proc/CheckElevationWeather()
		set waitfor = 0
		set background = 1
		while(src)
			var/mob/players/M
			for(M in world)
				if(M.client)
					UpdateWeatherForElevation(M)
			sleep(elevation_check_interval)

	proc/UpdateWeatherForElevation(mob/players/M)
		// Get current elevation from zone manager
		var/current_elevel = M.elevel || 1.0
		var/current_temp = 15
		
		// Adjust weather based on elevation
		if(current_elevel < 1.0)
			// Water level - high humidity
			current_temp = 18
			if(prob(40)) weather_type = "mist"
			else if(prob(30)) weather_type = "fog"
			else weather_type = "clear"
			
		else if(current_elevel < 1.5)
			// Lowlands - temperate
			current_temp = 15
			if(prob(30)) weather_type = "drizzle"
			else if(prob(20)) weather_type = "fog"
			else weather_type = "clear"
			
		else if(current_elevel < 2.0)
			// Highlands - variable
			current_temp = 10
			if(prob(40)) weather_type = "drizzle"
			else if(prob(20)) weather_type = "mist"
			else weather_type = "clear"
			
		else if(current_elevel < 2.5)
			// Mountains - harsh
			current_temp = 5
			if(prob(50)) weather_type = "hail"
			else if(prob(30)) weather_type = "mist"
			else weather_type = "clear"
			
		else
			// Peaks - extreme cold
			current_temp = -5
			if(prob(60)) weather_type = "hail"
			else if(prob(25)) weather_type = "mist"
			else weather_type = "clear"
		
		// Apply to player's weather FX
		if(M.weather_fx && M.weather_fx.weather_type != weather_type)
			M.weather_fx.SetWeatherType(weather_type)

// ==================== PLAYER INTEGRATION ====================

mob/players
	var/obj/weather_fx/weather_fx

	proc/InitWeatherFX()
		if(!weather_fx)
			weather_fx = new /obj/weather_fx(src)
			weather_fx.SetWeatherType("clear")
			weather_fx.PlayWeatherSound()

	proc/UpdateWeatherParticles(weather_type)
		if(!weather_fx)
			InitWeatherFX()
		weather_fx.SetWeatherType(weather_type)
		weather_fx.PlayWeatherSound()

	proc/ClearWeather()
		if(weather_fx)
			weather_fx.SetWeatherType("clear")

// ==================== BIOME-WEATHER CONNECTOR ====================

// Called from dynamic_zone whenever weather_type changes
proc/ApplyBiomeWeather(mob/players/M, weather_type)
	if(!M || !M.client) return
	
	switch(weather_type)
		if("fog")
			M.UpdateWeatherParticles("fog")
		if("mist")
			M.UpdateWeatherParticles("mist")
		if("dust_storm")
			M.UpdateWeatherParticles("dust_storm")
		if("hail")
			M.UpdateWeatherParticles("hail")
		if("rain", "drizzle")
			M.UpdateWeatherParticles("drizzle")
		else
			M.UpdateWeatherParticles("clear")

// ==================== LANDSCAPE INTEGRATION ====================

// Enhanced hill/ditch elevation objects with weather effects
elevation/hill
	var/weather_intensity = 1.0
	
	New()
		..()
		// Higher elevation = more extreme weather
		weather_intensity = 1.0 + ((elevel - 1.0) * 0.3)

elevation/ditch
	var/weather_intensity = 0.7
	
	New()
		..()
		// Lower elevation = more moisture/mist
		weather_intensity = 0.7 - ((1.0 - elevel) * 0.2)

// Fog rolls into ditches naturally (lower pressure areas)
elevation/ditch/proc/GenerateFog()
	set waitfor = 0
	var/fog_intensity = clamp(1.0 - ((elevel / 4) * 0.5), 0.3, 1.0)
	
	// Check nearby mobs and apply fog effect
	for(var/mob/players/M in view(10, src))
		if(M.elevel <= elevel + 0.5)
			// Player is in fog zone
			M.UpdateWeatherParticles("fog")

// ==================== WEATHER CYCLE SYSTEM ====================

var/obj/elevation_weather_controller/weather_controller

proc/InitWeatherController()
	if(!weather_controller)
		weather_controller = new /obj/elevation_weather_controller()

proc/UpdateAllPlayersWeather()
	set waitfor = 0
	var/mob/players/M
	for(M in world)
		if(M.client && weather_controller)
			weather_controller.UpdateWeatherForElevation(M)

// Called from world loop to update dynamic weather
proc/DynamicWeatherTick()
	set waitfor = 0
	set background = 1
	
	while(1)
		UpdateAllPlayersWeather()
		sleep(20)  // Update every 1 second game time
