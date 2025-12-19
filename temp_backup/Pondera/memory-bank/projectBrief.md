# Pondera MMO - HUD & Toolbelt Integration Phase

## Purpose

Define the main purpose of this project.

## Target Users

Describe who will use this.


## Project Summary

Open-source BYOND survival MMO with procedural terrain, vertical elevation, deed-based territory control across 3 continents. Currently implementing professional HUD system with toolbelt hotbar integration.



## Goals

- Integrate professional HudGroups-based UI system
- Create persistent toolbelt hotbar (2-9 slots, dynamic scaling)
- Implement 6 extended HUD panels (Inventory, Skills, Deeds, Market, Customization)
- Dynamic hotbar scaling based on toolbelt tier upgrades
- Wire toolbelt notification hooks to HUD updates
- Maintain clean build status and code quality



## Constraints

- BYOND DM language limitations (no native capitalize proc)
- HudGroup client registration requires proper mob/client parameter handling
- Toolbelt tier system: 2 slots base, +2 per tier (0→2, 1→4, 2→6, 3→8, 4→9)
- Must maintain backward compatibility with existing ToolbeltHotbarSystem
- Build must stay at 0 errors



## Stakeholders

- AERProductions (repo owner)
- Current developer (implementation)
- Pondera MMO community

