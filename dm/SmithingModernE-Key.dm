// ============================================================================
// SmithingModernE-Key.dm - E-key Support for Smithing Stations
// ============================================================================
// Purpose: Add UseObject() support to anvil objects for E-key macro access
// Status: Phase 1 - E-key handler only (verb refactor deferred to Phase 2)
//
// Note: The main Smithing() verb remains in Objects.dm (lines 5107-8872)
//       This module adds E-key support without requiring major refactoring yet
// ============================================================================

/obj/Buildable/Smithing/Anvil
	// E-key handler for anvil interaction
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Call the Smithing() verb when E-key pressed
			src.Smithing()
			return 1
		return 0

/obj/Buildable/Smithing/Forge
	// E-key handler for forge interaction  
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Call the Smithing() verb when E-key pressed
			src.Smithing()
			return 1
		return 0

// ============================================================================
// END SmithingModernE-Key.dm
// ============================================================================
