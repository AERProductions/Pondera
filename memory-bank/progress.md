# Progress (Updated: 2025-12-19)

## Done

- Created Fl_LightingCore.dm - unified lighting system with registries, terrain integration, and time-of-day cycling
- Integrated light_emitter datum with pulsing, falloff, expiration, and dynamic intensity calculations
- Implemented biome-specific lighting (temperate, arctic, desert, swamp, volcanic)
- Added time-of-day lighting integration for day/night cycles
- Resolved compilation errors (% operator syntax, duplicate definitions)
- Successfully integrated with existing Fl_LightEmitters.dm without conflicts

## Doing



## Next

- Integrate lighting system with actual time system for dynamic day/night
- Test lighting visibility at different elevals (elevation system)
- Add dynamic light updates based on weather system changes
