# Product Context

Describe the product.

## Overview

Provide a high-level overview of the project.

## Core Features

- Feature 1
- Feature 2

## Technical Stack

- Tech 1
- Tech 2

## Project Description

Pondera is an open-source BYOND survival MMO featuring procedural infinite terrain, multi-level vertical gameplay via elevation system, deed-based territory control, NPC-driven economy, and three distinct game modes. Players progress through skill ranks, craft recipes, manage survival (hunger/thirst/stamina), and compete or cooperate across continents.



## Architecture

150KB+ DM codebase across 85+ system files using HudGroups library (production-ready screen object management). Architecture: (1) Centralized initialization orchestrator, (2) Elevation system for vertical gameplay, (3) Procedural map generation with lazy-loaded chunks, (4) Movement & sprint with deed cache invalidation, (5) Deed system for territory control, (6) Consumption ecosystem (hunger/thirst/stamina), (7) Unified rank system (8 skills: fishing/crafting/mining/smithing/building/gardening/woodcutting/digging), (8) Recipes & crafting discovery, (9) Equipment with overlay system, (10) Three-continent architecture (Story/Sandbox/PvP)



## Technologies

- BYOND DM (Dream Maker language)
- Binary chunk saves for procedural map persistence
- HUD subsystem pattern (6 independent HudGroup-based panels)
- Dynamic property access via : operator (type-agnostic variable access)
- Maptext rendering for on-screen text display
- Screen object management via HudGroup.add()



## Libraries and Dependencies

- HudGroups (professional UI management with screen object batching)
- F0laks Debug Messager (logging/debug output)
- ToolbeltHotbarSystem (existing toolbelt inventory, 2-9 slots)
- DynamicMarketPricingSystem (supply/demand economy)
- UnifiedRankSystem (8 skills + level progression)
- ConsumptionManager (hunger/thirst/stamina integration)
- ElevationSystem (decimal elevation levels 1.0-2.5)
- AtomSystem (automatic layer/invisibility calculation)

