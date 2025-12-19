/*
	unterra.monstoro.SimpleLocks library -- by Gughunter


	Behold! One simple library can handle movement delays, spam protection, time-consuming
	actions like attacking or spell-casting, and imagining world peace.

	The idea is simple. Every mob gets a built-in list of locks. There can be as many or as few
	locks as you like. Whenever the mob tries to do something that it can only do every so often,
	you simply try to set the appropriate lock. If it's already set, well, try again later.

	"Duration" is the number of ticks the lock will be in effect. If you use a duration of 0,
	you will not set the lock -- you will just get a result that indicates whether
	the lock is currently available.

	All procs listed below return 0 to indicate a failure. See the descriptions below for
	information about the return values for successes.

	Please check out the included demo for numerous examples of how you can use this library.


	umsl_ObtainLock(lockName, duration)
		Tries to set a single lock.
		If successful, returns lockName.

	umsl_ClearLock(lockName, duration)
		Removes a single lock.

	umsl_ObtainMultiLock(list/lockNames, duration)
		Tries to set all locks in the list. This is an all-or-nothing operation! No locks
		in the list will be set unless they can all be set.
		If successful, returns the list.

	umsl_ObtainAnyOneLock(list/lockNames, duration)
		Tries to set each lock in the list until one succeeds.
		If successful, returns the name of the lock that succeeded.

*/


mob
	var/list/umsl_locks = list()


	proc/umsl_ObtainLock(lockName, duration)
		var/curStatus = umsl_locks[lockName]

		if(curStatus <= world.time)
			if(duration > 0) //Duration 0 signifies a non-lock-reserving status check
				umsl_locks[lockName] = world.time + duration
			return lockName
		else return 0


	proc/umsl_ClearLock(lockName, duration)
		umsl_locks[lockName] = 0


	proc/umsl_ObtainMultiLock(list/lockNames, duration)
		var/lockName
		for(lockName in lockNames)
			if(!umsl_ObtainLock(lockName, 0)) return 0
		for(lockName in lockNames)
			umsl_ObtainLock(lockName, duration)
		return lockNames


	proc/umsl_ObtainAnyOneLock(list/lockNames, duration)
		var/lockName
		for(lockName in lockNames)
			var/result = umsl_ObtainLock(lockName, duration)
			if(result) return lockName
		return 0
