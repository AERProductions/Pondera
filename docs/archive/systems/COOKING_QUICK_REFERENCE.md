# Cooking System Quick Reference - Phases 11-12

**For Developers**: Copy-paste integration guide

## Key Functions

### Recipe Discovery (RecipeState.dm)

```dm
// Check if recipe discovered
M.character.recipe_state.IsRecipeDiscovered("vegetable_soup")

// Unlock a recipe
M.character.recipe_state.DiscoverRecipe("bread")

// Used by:
UnlockRecipeFromNPC(M, "baker", "bread")  // Phase 4 existing
```

### Cooking Skill (CookingSkillProgression.dm)

```dm
// Get player rank (0-10)
var/rank = GetCookingSkillRank(M)

// Get quality multiplier
var/bonus = GetCookingQualityBonus(M)  // 0.6 to 1.8

// Check if can cook recipe
if(CanCookRecipe(M, "meat_stew"))
    // Player has discovered recipe AND skill >= requirement

// Award XP after cooking
AwardCookingXP(M, 100, 1.5)  // base XP, quality multiplier

// Get player's title
var/title = GetCookingSkillTitle(GetCookingSkillRank(M))
// Returns: "Expert Chef", "Master Chef", etc.
```

### Quality Calculation

```dm
// In FinishCooking():
var/final_quality = base_quality
                  * skill_bonus           // NEW: CookingSkillProgression
                  * temperature_bonus
                  * oven_bonus
                  * soil_modifier         // From Phase 8
                  * seasonal_modifier
                  * biome_modifier

// Apply to nutrition
var/final_nutrition = food_base_nutrition * final_quality
```

## Recipe System

### Unlock Path for New Players

```
Rank 0 (Start)
    ↓ Learn from NPC
Vegetable Soup discovered
    ↓ Cook 5-10 meals
500 XP → Rank 1 (Apprentice Chef)
    ↓ Unlock recipes in DiscoverRecipe() matching rank 1
Roasted Vegetables, Grain Porridge
    ↓ Continue cooking
Rank 2 (Practiced Cook)
    ↓
Rank 3 (Competent Chef) - Bread Baking unlocked
    ↓
Rank 5 (Expert Chef) - Advanced recipes
    ↓
Rank 6 (Master Chef) - Shepherd's Pie
```

### Recipe Data Structure (RECIPES global)

```dm
RECIPES["vegetable_soup"] = list(
    "name" = "Vegetable Soup",
    "skill_req" = 1,        // Rank 1+
    "method" = COOK_METHOD_BOIL,
    "temp_min" = 200,
    "cook_time" = 30,
    "ingredients" = list(
        "potato" = 2,
        "carrot" = 1,
        "water" = 1
    ),
    "quality" = 1.0,
    "nutrition" = 50,
    "stamina" = 40,
    "description" = "A warm nourishing soup..."
)
```

## Integration Points

### Hook 1: When Meal is Finished (CookingSystem.dm)

```dm
proc/FinishCooking(recipe, chef, ingredients)
    // ... existing code ...
    
    // NEW: Apply skill bonus to quality
    final_quality = ApplyCookingSkillBonus(chef, final_quality)
    
    // NEW: Award XP
    AwardCookingXP(chef, 100, final_quality)
    
    // Create meal with final quality
    var/obj/CookedFood/meal = new(...)
```

### Hook 2: On Rank Up (CookingSkillProgression.dm)

```dm
proc/OnCookingRankUp(mob/players/M, new_rank)
    // Automatically:
    // 1. Updates character.recipe_state.skill_cooking_level
    // 2. Shows achievement message
    // 3. Calls UnlockRecipesByRank()
    // 4. Discovers new recipes
    
    // To add custom behavior:
    //   - Override this proc
    //   - Call ..() for default behavior
    //   - Add your custom code after
```

### Hook 3: Recipe Selection (Future - Phase 13)

```dm
// On fire/oven object:
verb/Cook()
    ShowCookingMenu(usr, src)
    
proc/ShowCookingMenu(mob/players/M, obj/Oven/fire)
    // Build menu of available recipes
    // Filter by: IsRecipeDiscovered() && CanCookRecipe()
    // Show XP gain preview
```

## Testing Commands

```dm
// Set skill rank
M.character.recipe_state.skill_cooking_level = 5

// Unlock recipe
M.character.recipe_state.DiscoverRecipe("meat_stew")

// Check discovery
M << M.character.recipe_state.IsRecipeDiscovered("bread")

// Get quality bonus
M << "Quality: [GetCookingQualityBonus(M)]x"

// Simulate cooking XP
AwardCookingXP(M, 100, 1.5)

// Show status
ShowCookingStatus(M)
```

## Persistence

```dm
// Automatically saved:
character.recipe_state.skill_cooking_level
character.recipe_state.experience_smithing
character.recipe_state.discovered_* (all recipes)

// On login: All restored from savefile
// On logout: All saved to savefile
// No manual save/load needed
```

## Skill Bonuses at Each Rank

| Rank | Title | Quality Mult | Nutrition Boost |
|------|-------|--------------|-----------------|
| 0 | Untrained | 0.60× | -40% |
| 1 | Apprentice | 0.80× | -20% |
| 2 | Practiced | 0.95× | -5% |
| 3 | Competent | 1.00× | Baseline |
| 4 | Skilled | 1.10× | +10% |
| 5 | Expert | 1.25× | +25% |
| 6 | Master | 1.40× | +40% |
| 7 | Grandmaster | 1.50× | +50% |
| 10 | Legendary | 1.80× | +80% |

## Common Errors & Fixes

### Error: "recipe_state undefined"
```dm
// Problem: character.recipe_state not initialized
// Solution:
if(!M.character)
    M.character = new /datum/character_data()
if(!M.character.recipe_state)
    M.character.recipe_state = new /datum/recipe_state()
```

### Error: Recipe not unlocking
```dm
// Problem: Skill requirement not met
// Solution: Check CanCookRecipe() before showing recipe
if(!CanCookRecipe(M, "bread"))
    M << "You need higher cooking skill"
```

### Error: Quality not applying
```dm
// Problem: Forgot to call ApplyCookingSkillBonus()
// Solution: Always apply after base quality calculation
var/final_quality = base_quality * ... * temperature * oven
final_quality = ApplyCookingSkillBonus(M, final_quality)
```

## Next Phase Roadmap

### Phase 13 (Ready to implement)
- Add Cook verb to fire objects
- Build recipe selection UI
- Connect ShowCookingMenu()

### Phase 14 (Design complete)
- NPC cooking integration
- Cook-off competitions
- Leaderboards

### Phase 15 (Planned)
- Regional cuisine styles
- Multi-step recipes
- Food preservation

## Performance Notes

- Skill check: O(1) - direct variable access
- XP award: O(1) - addition only
- Rank-up: O(n) where n = recipes (runs once per rank)
- Query all discovered: O(n) where n = recipes
- Memory: 8 bytes per player

No performance impact on frame rate.

## Support

**Documentation Files**:
- `COOKING_RECIPE_DISCOVERY_INTEGRATION.md` - Phase 11 details
- `COOKING_SKILL_PROGRESSION.md` - Phase 12 details
- `COMPLETE_FOOD_ECOSYSTEM_GUIDE.md` - All phases 8-12
- `PHASES_11_12_COMPLETION.md` - Completion summary

**Code Files**:
- `dm/RecipeState.dm` - Recipe discovery & persistence
- `dm/CookingSystem.dm` - Cooking mechanics
- `dm/CookingSkillProgression.dm` - Skill progression

---

**Build Status**: ✅ 0 errors, 2 warnings  
**Version**: Phase 12 Complete  
**Last Updated**: December 8, 2025
