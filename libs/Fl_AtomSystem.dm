// libs/Fl_AtomSystem.dm — Core atom/elevation collision helpers and directional blocking system.

var
	NOCC = 0
	NOC  = 0
	SINV = 1

// Bitflag list: maps dir index to bitmask for tbit/ntbit entrance/exit block checks.
var/list/dir_to_bitflag = list(1,16,0,4,2,8,0,64,128,32)

// Elevation location placeholder on movable atoms.
atom/movable/var/elevation/eloc	= null

atom
	var
		elevel = 1
		tbit = 0
		ntbit = 0
		hide = 1

	proc
		// Convert layer number to elevation level (4 layers per elevel).
		FindElevation(var/layer) return round(layer / 4,0.25)

		// Convert elevation level to layer base (4 layers per elevel).
		FindLayer(var/elevel) return (round(elevel-1,0.25) * 4)

		// Return invisibility level from elevel (higher elevel = higher invisibility).
		FindInvis(var/elevel) return round(elevel)

		// Return true if movable atom 'a' is within ±0.5 elevel of src (can interact).
		Chk_LevelRange(var/atom/movable/a)
			return (a.elevel <= src.elevel + 0.5 && a.elevel >= src.elevel - 0.5)

		// Hook: return dense blocking object. Override in elevation/turf systems.
		GetDenseObject()

		// Corner-cut check: return 0 if diagonal move to 'a' is blocked by corner rules.
		Chk_CC(atom/movable/a)
			var/d = get_dir(src,a)
			if( NOC  && (d&(d-1)) ) return 0
			if( NOCC && (d&(d-1)) )
				var/turf/T = get_step(src,d)
				return T.Check_CC(d,a)
			else return 1

		// Determine if atom A can enter src (checks density, corner rules, elevel range, dense objects).
		Chk_Enter(atom/movable/A)
			if(!A) return 0
			if(!A.density) return 1
			if(!Chk_CC(A)) return 0
			if(!Chk_LevelRange(A)) return 0
			var/atom/D = GetDenseObject(A)
			return (!D || D == A) ? 1 : 0

		// Like Chk_Enter, but also check contained elevations if src is not in range.
		Chk_EnterCC(atom/movable/A,d as null)
			if(!A) return 0
			if(!A.density) return 1
			if(!src.Chk_LevelRange(A))
				var/chk = 0
				for(var/elevation/e in src)
					if(e.Chk_Enter(A))
						chk = 1
						break
				if(!chk) return 0
			var/atom/D = GetDenseObject(A,d)
			return (!D || D == A) ? 1 : 0

		// Determine if atom A can exit src (checks directional exit blocking).
		Chk_Exit(atom/movable/A)
			var/d = A.dir
			if(Chk_NTbit(d)) return 0
			else return 1

		// Test if direction d is blocked by tbit entrance block.
		Chk_Tbit(d)
			if(tbit && (d && (dir_to_bitflag[d] & tbit))) return 1
			else return 0

		// Test if direction d is blocked by ntbit exit block (defaults to tbit if not set).
		Chk_NTbit(d)
			if(!ntbit) ntbit = tbit
			if(ntbit && (d && (dir_to_bitflag[d] & ntbit))) return 1
			else return 0

// Opposite direction lookup and diagonal component extraction for corner-cut logic.
var/list/OppD = list(2,1,0,8,10,9,0,4,6,5)

proc
	// Return opposite direction for a given dir (0=none, 1=south, 2=north, etc).
	Odir(d) return (d?OppD[d]:d)

	// Extract one component of a diagonal direction.
	G_ADiag(d) return d&(d-1)

	// Extract the other component of a diagonal direction.
	G_NDiag(d) return (d&(d-1))^d


atom
	proc
		// Return the turf in the opposite direction of d.
		get_ostep(d) return get_step(src,Odir(d))

		// Return 1 if moving diagonally in dir would NOT cut corners (both sides enterable).
		Check_CC(dir,atom/movable/a)
			var/d1=G_NDiag(dir)
			var/d2=G_ADiag(dir)
			return Check_Step(d1,a)&Check_Step(d2,a)

		// Check if the turf adjacent in direction d is enterable for movable atom a.
		Check_Step(d,atom/movable/a)
			var/turf/t=get_ostep(d)
			return t.Chk_EnterCC(a,d)