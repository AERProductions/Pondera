/**
 * DAMASCUS STEEL VISUALIZATION & TUTORIAL SYSTEM
 * ===============================================
 * Interactive damascus pattern learning and visualization
 * Shows pattern types, crafting requirements, and aesthetic variations
 * 
 * Started: 12-11-25 7:00PM
 * Focus: Damascus steel as visual art + crafting mastery milestone
 */

// Damascus pattern types
#define PATTERN_WILD "Wild"
#define PATTERN_TWIST "Twist"
#define PATTERN_LADDER "Ladder"
#define PATTERN_RAINDROP "Raindrop"
#define PATTERN_HERRINGBONE "Herringbone"
#define PATTERN_PYRAMIDS "Pyramids"
#define PATTERN_MOSAIC "Mosaic"
#define PATTERN_FEATHER "Feather"

/datum/damascus_pattern
	var
		name = ""                 // Display name
		key = ""                  // Unique identifier
		description = ""          // How it's made
		visual_description = ""   // What it looks like
		difficulty = 1            // 1-5 (1=easy, 5=legendary)
		technique = ""            // Folding/etching technique
		chemical_required = ""    // Acid type needed
		folds_required = 0        // Number of folds
		icon_variant = ""         // Visual variant name

/datum/damascus_pattern/New(name_input, key_input, desc, visual, diff, tech, chem, folds, icon)
	name = name_input
	key = key_input
	description = desc
	visual_description = visual
	difficulty = diff
	technique = tech
	chemical_required = chem
	folds_required = folds
	icon_variant = icon

/datum/damascus_tutorial
	var
		list/all_patterns = list()    // All damascus patterns
		list/discovered_patterns = list()  // What player has learned
		current_pattern = null        // Currently viewing

/datum/damascus_tutorial/New()
	PopulatePatterns()

/datum/damascus_tutorial/proc/PopulatePatterns()
	/**
	 * Create all 8 damascus pattern types with full metadata
	 */
	
	var/datum/damascus_pattern/p_wild = new(
		PATTERN_WILD,
		"damascus_wild",
		"The Wild pattern emerges from random folding with high carbon steel and mild steel. " + \
			"Steel is folded 5-7 times, creating an asymmetrical, unpredictable wavy pattern. " + \
			"This pattern is sought after by those who embrace chaos and unpredictability in their work.",
		"Chaotic wavy lines that flow unpredictably across the blade surface. " + \
			"Some waves are sharp, others rounded. The pattern looks organic, almost alive. " + \
			"Colors shift between dark and light gray with silvery highlights.",
		1,
		"Controlled Random Folding",
		"Mild Acid Etch",
		6,
		"wild"
	)
	all_patterns += p_wild
	
	var/datum/damascus_pattern/p_twist = new(
		PATTERN_TWIST,
		"damascus_twist",
		"Twist pattern created by rotating twisted steel rods before folding. " + \
			"Requires careful alignment: twisted bar rotated 90 degrees, then folded 4-6 times. " + \
			"The result is helical lines spiraling across the blade like a DNA strand.",
		"Diagonal spiral lines running from spine to edge in elegant helical curves. " + \
			"The spirals create a sense of motion and energy. " + \
			"Light and dark layers create strong visual contrast.",
		2,
		"Rotation + Folding",
		"Medium Acid Etch",
		5,
		"twist"
	)
	all_patterns += p_twist
	
	var/datum/damascus_pattern/p_ladder = new(
		PATTERN_LADDER,
		"damascus_ladder",
		"Ladder pattern created by stacking thin layers of alternating steel types. " + \
			"Each layer is folded perpendicular to the previous fold, creating a grid-like pattern. " + \
			"Requires 3-4 folding cycles with careful orientation control.",
		"Precise horizontal and vertical lines forming a ladder or grid pattern. " + \
			"Very geometric and orderly. Perfect for those who value precision and control. " + \
			"Layers create strong contrast: light rungs, dark spaces between.",
		2,
		"Perpendicular Layer Folding",
		"Medium Acid Etch",
		4,
		"ladder"
	)
	all_patterns += p_ladder
	
	var/datum/damascus_pattern/p_raindrop = new(
		PATTERN_RAINDROP,
		"damascus_raindrop",
		"Raindrop pattern created by placing domed high-carbon steel caps on mild steel base. " + \
			"When etched, the caps create circular or teardrop shapes. " + \
			"Named for resemblance to raindrops scattered across a surface.",
		"Circular or teardrop-shaped light spots scattered across dark background. " + \
			"Some drops are perfectly round, others slightly oval. " + \
			"Creates impression of movement and emotion, like rain on a surface.",
		3,
		"Domed Cap Attachment",
		"Strong Acid Etch",
		3,
		"raindrop"
	)
	all_patterns += p_raindrop
	
	var/datum/damascus_pattern/p_herringbone = new(
		PATTERN_HERRINGBONE,
		"damascus_herringbone",
		"Herringbone pattern created by stacking V-shaped channels or angled layers. " + \
			"Each layer is rotated 180 degrees from the previous, creating opposing diagonals. " + \
			"Requires high precision: even one degree off ruins the pattern.",
		"Diagonal lines alternating direction: up-left, down-right, up-left, down-right. " + \
			"Like fish bones or herring skeletons arranged in rows. " + \
			"Creates powerful directional flow and optical illusion of movement.",
		3,
		"V-Channel Stacking",
		"Medium Acid Etch",
		6,
		"herringbone"
	)
	all_patterns += p_herringbone
	
	var/datum/damascus_pattern/p_pyramids = new(
		PATTERN_PYRAMIDS,
		"damascus_pyramids",
		"Pyramid pattern created by grinding and etching three-sided channels. " + \
			"When acid etches the channels, they appear as small pyramids or pointed mountains. " + \
			"Requires grinding skills and precise chemical etching.",
		"Small pyramid or mountain shapes arranged in rows across the blade. " + \
			"Each pyramid creates shadow and depth, giving 3D appearance. " + \
			"Light hits pyramid peaks, creating silvery highlights on dark background.",
		4,
		"Channel Grinding + Etching",
		"Strong Acid Etch",
		4,
		"pyramids"
	)
	all_patterns += p_pyramids
	
	var/datum/damascus_pattern/p_mosaic = new(
		PATTERN_MOSAIC,
		"damascus_mosaic",
		"Mosaic pattern created by welding 10+ different steel pieces together. " + \
			"Each piece is a small rod or block, carefully arranged in artistic formation. " + \
			"When etched, reveals a miniature picture or complex geometric design.",
		"Complex multi-piece design: geometric shapes, abstract art, or representational images. " + \
			"Each small piece etches differently based on carbon content. " + \
			"Creates intricate visual story, like stained glass window on steel.",
		4,
		"Multi-Piece Mosaic Assembly",
		"Variable Acid Etch",
		2,
		"mosaic"
	)
	all_patterns += p_mosaic
	
	var/datum/damascus_pattern/p_feather = new(
		PATTERN_FEATHER,
		"damascus_feather",
		"Feather pattern created by high-carbon rods placed in mild steel matrix. " + \
			"Rods are arranged in offset rows, creating alternating peaks and valleys. " + \
			"When folded and etched, resembles feather barbs.",
		"Flowing feather-like lines with central spine and alternating branches. " + \
			"Looks like actual bird feather captured on steel. " + \
			"Creates sense of elegance, grace, and natural artistry.",
		5,
		"Rod-Matrix Arrangement + Folding",
		"Strong Acid Etch",
		7,
		"feather"
	)
	all_patterns += p_feather

/datum/damascus_tutorial/proc/ShowOverview(mob/player)
	/**
	 * Display damascus steel overview and pattern gallery
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Damascus Steel Mastery</title></head><body>"
	output += "<h1>DAMASCUS STEEL: THE LEGENDARY CRAFT</h1><hr>"
	output += "<i>Ultimate milestone in smithing craftsmanship</i><br><br>"
	
	output += "<b>What is Damascus Steel?</b><br>"
	output += "Damascus steel is the pinnacle of smithing achievement. " + \
		"Created by layering and folding two different steel types repeatedly, " + \
		"then acid-etching to reveal the internal structure.<br><br>"
	
	output += "Legend says Damascus steel was forged in the city of Damascus, Syria, " + \
		"where master smiths created unbreakable blades with beautiful natural patterns.<br><br>"
	
	output += "<b>Why Damascus Steel?</b><br>"
	output += "- Legendary durability and edge retention<br>" + \
		"- Unique pattern impossible to forge a duplicate of<br>" + \
		"- Symbol of master craftsman's skill<br>" + \
		"- Each blade tells a story through its pattern<br><br>"
	
	output += "<b>Pattern Types</b><br>"
	output += "There are 8 distinct Damascus patterns, each with unique creation method and aesthetic:<br><br>"
	
	// Show pattern gallery
	for(var/datum/damascus_pattern/pattern in all_patterns)
		var/is_discovered = (pattern.key in discovered_patterns)
		var/icon_text = is_discovered ? "✓" : "?"
		output += "<a href='?damascus_pattern=[pattern.key]'>"
		output += "[icon_text] [pattern.name]</a>"
		output += " <font color='#888'>(Difficulty: [pattern.difficulty]/5)</font><br>"
	
	output += "<hr>"
	output += "Click on any pattern to learn how it's made.<br>"
	output += "Visit the Tech Tree (F2) to see Damascus crafting requirements."
	output += "</body></html>"
	player << output

/datum/damascus_tutorial/proc/ShowPattern(mob/player, pattern_key)
	/**
	 * Display detailed pattern information
	 */
	
	if(!ismob(player))
		return
	
	var/datum/damascus_pattern/pattern = null
	for(var/datum/damascus_pattern/p in all_patterns)
		if(p.key == pattern_key)
			pattern = p
			break
	
	if(!pattern)
		player << "Pattern not found."
		return
	
	// Mark as discovered
	if(!(pattern.key in discovered_patterns))
		discovered_patterns += pattern.key
	
	var/output = "<html><head><title>[pattern.name] Pattern</title></head><body>"
	output += "<h2>[pattern.name] PATTERN</h2>"
	output += "<i>Difficulty: " + pattern.difficulty + "/5</i><hr>"
	
	output += "<b>Visual Appearance:</b><br>"
	output += pattern.visual_description + "<br><br>"
	
	output += "<b>How It's Made:</b><br>"
	output += pattern.description + "<br><br>"
	
	output += "<b>Crafting Parameters:</b><br>"
	output += "Technique: " + pattern.technique + "<br>"
	output += "Etching Agent: " + pattern.chemical_required + "<br>"
	output += "Total Folds: " + pattern.folds_required + "<br>"
	
	// Calculate layers from folds
	var/layer_count_final = 1
	for(var/i = 0; i < pattern.folds_required; i++)
		layer_count_final *= 2
	output += "Steel Layers After Folding: " + layer_count_final + " layers<br><br>"
	
	// Explain folding mechanics
	output += "<b>Understanding the Fold Count:</b><br>"
	output += "Each fold DOUBLES the number of layers:<br>"
	output += "- 3 folds = 8 layers<br>"
	output += "- 4 folds = 16 layers<br>"
	output += "- 5 folds = 32 layers<br>"
	output += "- 6 folds = 64 layers<br>"
	output += "- 7 folds = 128 layers (!)<br>"
	
	// Calculate actual layers for pattern
	var/layer_count = 1
	for(var/i = 0; i < pattern.folds_required; i++)
		layer_count *= 2
	output += "<i>Your pattern will have [layer_count] layers after [pattern.folds_required] folds.</i><br><br>"
	
	// Technique explanation
	output += "<b>Technique Breakdown:</b><br>"
	
	if(pattern.technique == "Controlled Random Folding")
		output += "1. Start with 2kg of high-carbon and mild steel bars<br>" + \
			"2. Heat to cherry red (not too hot!)<br>" + \
			"3. Stack and weld together<br>" + \
			"4. Fold with slight rotation each time (controlled chaos)<br>" + \
			"5. Repeat 6-7 times, reheating between folds<br>" + \
			"6. Final grinding to reveal pattern<br>" + \
			"7. Acid etch to darken soft steel layers<br>"
	else if(pattern.technique == "Rotation + Folding")
		output += "1. Twist high-carbon rod 2-3 times to create helical structure<br>" + \
			"2. Weld twisted rod into mild steel surround<br>" + \
			"3. Rotate assembled bar 90 degrees<br>" + \
			"4. Fold 4-6 times, maintaining rotation at 90-degree angles<br>" + \
			"5. Grind and polish blade shape<br>" + \
			"6. Acid etch to reveal spiral pattern<br>"
	else if(pattern.technique == "Perpendicular Layer Folding")
		output += "1. Layer high-carbon and mild steel alternately (at least 8 layers)<br>" + \
			"2. Fold 90 degrees (perpendicular to first fold)<br>" + \
			"3. Repeat folding in alternating directions<br>" + \
			"4. Each fold creates grid intersection points<br>" + \
			"5. Grind blade flat to see ladder pattern<br>" + \
			"6. Acid etch for contrast<br>"
	else if(pattern.technique == "Domed Cap Attachment")
		output += "1. Create mild steel blade base<br>" + \
			"2. Craft high-carbon steel domed caps<br>" + \
			"3. Weld caps to blade surface at strategic points<br>" + \
			"4. Caps should be evenly spaced (1-2 inches apart)<br>" + \
			"5. Grind blade surface smooth<br>" + \
			"6. Strong acid etch darkens surrounding mild steel<br>" + \
			"7. Caps remain light, creating raindrop effect<br>"
	else if(pattern.technique == "V-Channel Stacking")
		output += "1. Grind V-shaped channels into steel slabs<br>" + \
			"2. Stack slabs alternating direction (V pointing up, then down)<br>" + \
			"3. Weld stack together<br>" + \
			"4. Fold 4-5 times to multiply the layers<br>" + \
			"5. When etched, alternating channels create zigzag pattern<br>" + \
			"6. Pattern flow is powerful and directional<br>"
	else if(pattern.technique == "Channel Grinding + Etching")
		output += "1. Create flat blade blank<br>" + \
			"2. Carefully grind 3-sided pyramidal channels into surface<br>" + \
			"3. Channels must be precise angle (30-45 degrees)<br>" + \
			"4. Space channels evenly across blade<br>" + \
			"5. Polish blade smooth between channels<br>" + \
			"6. Use strong acid to etch channel bottoms darker<br>" + \
			"7. Light reflects off pyramid peaks, creating 3D effect<br>"
	else if(pattern.technique == "Multi-Piece Mosaic Assembly")
		output += "1. Design your mosaic pattern on paper first<br>" + \
			"2. Cut 10-50 small steel rods/pieces to match design<br>" + \
			"3. Arrange pieces like puzzle (geometric or representational)<br>" + \
			"4. Weld pieces together in groups, then weld groups together<br>" + \
			"5. The assembled billet becomes your final pattern<br>" + \
			"6. Forge and grind blade shape<br>" + \
			"7. Etch reveals each piece's unique carbon content<br>"
	else if(pattern.technique == "Rod-Matrix Arrangement + Folding")
		output += "1. Arrange high-carbon rods in offset rows<br>" + \
			"2. Rods are staggered (up, down, up, down pattern)<br>" + \
			"3. Surround with mild steel matrix<br>" + \
			"4. Weld entire assembly<br>" + \
			"5. Fold 5-7 times, always parallel to rod arrangement<br>" + \
			"6. Grind blade to expose the rods running lengthwise<br>" + \
			"7. Etch creates feather-like appearance with central spine<br>"
	
	output += "<hr><b>Crafting Requirements:</b><br>"
	output += "- Rank 5 Smithing (Master level)<br>"
	output += "- 1kg High-Carbon Steel Ingot<br>"
	output += "- 1kg Mild Steel Ingot<br>"
	output += "- " + pattern.chemical_required + "<br>"
	output += "- Access to Legendary Forge<br>"
	output += "- 30+ minutes real time (immersive crafting)<br><br>"
	
	output += "<b>Result:</b><br>"
	output += "Legendary Damascus Steel Sword<br>" + \
		"- Damage: 50 (highest in game)<br>" + \
		"- Durability: Infinite (never breaks)<br>" + \
		"- Resale Value: 5,000 Lucre<br>" + \
		"- Uniqueness: This exact pattern cannot exist twice<br><br>"
	
	output += "<a href='?damascus_overview'>BACK TO PATTERN GALLERY</a>"
	output += "</body></html>"
	player << output

/datum/damascus_tutorial/proc/ShowCraftingGuide(mob/player)
	/**
	 * Show step-by-step Damascus crafting walkthrough
	 */
	
	if(!ismob(player))
		return
	
	var/output = "<html><head><title>Damascus Steel Crafting Guide</title></head><body>"
	output += "<h1>DAMASCUS STEEL: COMPLETE CRAFTING GUIDE</h1><hr>"
	
	output += "<b>Prerequisites</b><br>"
	output += "Before attempting Damascus steel, ensure you have:<br>"
	output += "✓ Smithing rank 5 (Master)<br>"
	output += "✓ Recipe unlocked from tech tree or NPC teacher<br>"
	output += "✓ Access to Legendary Forge (highest-tier furnace)<br>"
	output += "✓ Required materials gathered<br><br>"
	
	output += "<b>Materials Checklist</b><br>"
	output += "You will need for a single damascus blade:<br>"
	output += "- High-Carbon Steel Ingot (x1)<br>"
	output += "- Mild Steel Ingot (x1)<br>"
	output += "- Acid Etch Solution (type depends on pattern)<br>"
	output += "- Optional: Inlays, gems, rivets for decoration<br><br>"
	
	output += "<b>The Forging Process</b><br>"
	output += "<b>Phase 1: Preparation (5 minutes)</b><br>"
	output += "1. Go to Legendary Forge<br>" + \
		"2. Place steel ingots in forge<br>" + \
		"3. Heat to bright cherry red (critical temperature!)<br>" + \
		"4. Once glowing, proceed to Phase 2<br><br>"
	
	output += "<b>Phase 2: Stacking (10 minutes)</b><br>"
	output += "1. Remove ingots from forge with tongs<br>" + \
		"2. Stack on anvil: Mild → High-Carbon → Mild pattern<br>" + \
		"3. Weld stack together (hammer strikes at joint edges)<br>" + \
		"4. Ensure no gaps (weak welds will fail in next step)<br>" + \
		"5. Allow to cool slightly, then reheat to cherry red<br><br>"
	
	output += "<b>Phase 3: Folding (12 minutes)</b><br>"
	output += "This is where Damascus is born!<br>" + \
		"1. With hot stack on anvil, fold in half with hammer<br>" + \
		"2. Flatten fold with strong hammer strikes<br>" + \
		"3. Weld flat with more hammer strikes on edges<br>" + \
		"4. Reheat and repeat fold (total: 5-7 times depending on pattern)<br>" + \
		"5. Each fold = 2x the layers (doubling effect)<br>" + \
		"6. Final stack has 32-128 thin layers alternating steel types<br>" + \
		"7. Each fold creates micro-mixing at layer boundaries<br><br>"
	
	output += "<b>Phase 4: Blade Forging (8 minutes)</b><br>"
	output += "1. Reheat folded billet<br>" + \
		"2. Begin shaping into sword blade form (point, tang, crossguard)<br>" + \
		"3. Careful hammer control (hard strikes flatten, soft strikes shape)<br>" + \
		"4. Stop frequently to check shape and reheat<br>" + \
		"5. Once shaped, quench in water to harden steel<br><br>"
	
	output += "<b>Phase 5: Grinding & Polishing (5 minutes)</b><br>"
	output += "1. Use grinding wheel to smooth blade surface<br>" + \
		"2. Work from coarse to fine grits<br>" + \
		"3. Sand smooth enough to apply acid etch<br>" + \
		"4. Polish to mirror finish for maximum pattern visibility<br>" + \
		"5. Clean with oil to prevent rust during etching<br><br>"
	
	output += "<b>Phase 6: Acid Etching (5 minutes)</b><br>"
	output += "1. Apply acid etch solution to blade surface<br>" + \
		"2. Acid attacks soft steel (mild) more than hard steel (high-carbon)<br>" + \
		"3. Soft layers darken, hard layers remain silvery<br>" + \
		"4. Etch for 3-5 minutes (longer = darker contrast)<br>" + \
		"5. Rinse thoroughly with water<br>" + \
		"6. Dry and oil blade<br><br>"
	
	output += "<b>Final Step: Revelation!</b><br>"
	output += "Your unique Damascus pattern is now visible!<br>" + \
		"No two Damascus blades ever look identical.<br>" + \
		"You've created a legendary masterpiece.<br><br>"
	
	output += "<hr>"
	output += "<a href='?damascus_overview'>BACK TO OVERVIEW</a>"
	output += "</body></html>"
	player << output

// Global instance
var/datum/damascus_tutorial/damascus_system = null

/proc/InitializeDamascus()
	if(damascus_system)
		return damascus_system
	damascus_system = new /datum/damascus_tutorial()
	return damascus_system

/proc/GetDamascus()
	if(!damascus_system)
		InitializeDamascus()
	return damascus_system
