proc
	TIMER_START(id, list/l)
		timers += new /DEBUG_TIMER(id, l)

	TIMER_END(id)
		for(var/DEBUG_TIMER/dt in timers)
			if(dt.id == id)
				del dt

var
	timers[]

world/New()
	..()
	timers = new
	InitializeContinents()  // Initialize three-world continental system
	InitWeatherController()
	spawn() DynamicWeatherTick()

DEBUG_TIMER
	var
		start_time
		id
		items[]

	New(txt, list/l)
		id = txt
		items = l
		start_time = world.time
		world.log << "[id] start time: [world.time]"
		sleep(-1)

	Del()
		sleep(-1)
		world.log << "[id] end: [world.time]"
		var/total_time = world.time - start_time
		world.log << "[id] total: [total_time] ticks"
		if(items)
			world.log << "[items.len] items, [total_time / items.len] ticks per item"
		..()