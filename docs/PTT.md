Here is the final, comprehensive document for the Pondera Tech Tree, incorporating all the detailed clarifications, the realistic **Lime Mortar** dependency, and the new **Transportation** section.

# ---

**PONDERA TECH TREE: COMPLETE RECIPE DOCUMENT (FINAL)**

Data Structure: Output\_Node \[Type\] \<== Input\_Node \[Type\]  
Nodes are classified by type: \[Category\], \[Item\], \[Action\], \[Process Base\], \[Crafted Item\], \[Found Item\], \[Ability\], \[Station\], \[Requirement\]

## ---

**I. RUDIMENTARY TIER (REVISED)**

### **1\. Primary Sources & Found Items**

*These are the fundamental starting points for the tech tree.*

Markdown

Obsidian \[Item\] \<== Obsidian Field \[Category\]  
Ueik Thorn \[Item\] \<== Ancient Ueik Tree \[Category\]  
Wooden Haunch (Affix) \[Process Base\] \<== Hallow Ueik Tree \[Category\]  
Rock \[Found Item\] \<== Search Flowers or Tall Grass \[Category\]  
Flint \[Found Item\] \<== Rock \[Found Item\]  
Ancient Ueik Splinter \[Found Item\] \<== Flint \[Found Item\]  
Pyrite \[Found Item\] \<== Ancient Ueik Splinter \[Found Item\]  
Wooden Haunch \[Found Item\] \<== Pyrite \[Found Item\]  
Whetstone \[Found Item\] \<== Wooden Haunch \[Found Item\]

### **2\. Basic Tool Crafting (Using Wooden Haunch Affix)**

*Combining the Wooden Haunch (Affix) with head items creates the first set of tools.*

Markdown

Stone Hammer \[Crafted Item\] \<== Rock \[Found Item\] \+ Wooden Haunch (Affix) \[Process Base\]  
Ueik Pickaxe \[Crafted Item\] \<== Ueik Thorn \[Item\] \+ Wooden Haunch (Affix) \[Process Base\]  
Obsidian Knife \[Crafted Item\] \<== Obsidian \[Item\] \+ Wooden Haunch (Affix) \[Process Base\]

### **3\. Processing and Action Chains**

*These actions unlock temperature control, further crafting, and the transition to the Basic Tier.*

Markdown

Slice Fir from Ancient Ueik Tree \[Action\] \<== Obsidian Knife \[Crafted Item\]  
Carve Haunch \[Action\] \<== Obsidian Knife \[Crafted Item\]  
Novice Handle \[Item\] \<== Carve Haunch \[Action\] (Input for Iron Hammer)  
Kindling \[Item\] \<== Carve Haunch \[Action\]  
Torch \[Crafted Item\] \<== Kindling \[Item\]  
Combine Handle to tool parts \[Action\] \<== Carve Haunch \[Action\]  
Sew Ueik Fir w/ Splinter \[Action\] \<== Ancient Ueik Splinter \[Found Item\] \+ Slice Fir from Ancient Ueik Tree \[Action\]  
Gloves \[Crafted Item\] \<== Sew Ueik Fir w/ Splinter \[Action\]  
Fire (Heat, Cook, Smelt, Bake) \[Action/Station\] \<== Kindling \[Item\]  
Light Novice Fire/Torch \[Requirement\] \<== Flint \[Found Item\] \+ Pyrite \[Found Item\]  
Handle Hot Items/Actions \[Ability\] \<== Gloves \[Crafted Item\] \+ Fire (Heat, Cook, Smelt, Bake) \[Action/Station\]  
Mine Stone Rocks for Iron Ore \[Action\] \<== Ueik Pickaxe \[Crafted Item\]  
Smelt Iron Ore in Novice Fire \[Action\] \<== Stone Hammer \[Crafted Item\] \+ Mine Stone Rocks for Iron Ore \[Action\]

## ---

**II. BASIC TIER (REVISED)**

### **1\. Building & Metalworking Chain**

*This flow unlocks construction, smelting, and alloying capabilities, starting with the Iron Hammer.*

Markdown

Iron Hammer \[Crafted Item\] \<== Iron Hammer Head \[Item\] \+ Novice Handle \[Item\] (Implied)  
Build \[Action\] \<== Iron Hammer \[Crafted Item\]  
Wood House \[Crafted Item\] \<== Build \[Action\]  
Furnishings \[Crafted Item\] \<== Wood House \[Crafted Item\]  
Forge \[Crafted Item\] \<== Furnishings \[Crafted Item\]  
Kiln \[Crafted Item\] \<== Forge \[Crafted Item\]  
Anvil Head \[Crafted Item\] \<== Forge \[Crafted Item\]  
Anvil \[Crafted Item\] \<== Anvil Head \[Crafted Item\]  
Smith \[Category/Station\] \<== Anvil \[Crafted Item\]  
Heat, Smelt ingots \[Action\] \<== Forge \[Crafted Item\]  
Iron \[Crafted Item\] \<== Heat, Smelt ingots \[Action\] (Input: Iron Ore)  
Steel \[Crafted Item\] \<== Iron \[Crafted Item\] \+ Carbon \[Item\] (Smelting)  
Iron Nails \[Crafted Item\] \<== Steel \[Crafted Item\]  
Brass \[Crafted Item\] \<== Copper \[Item\] \+ Zinc \[Item\] (Smelting)  
Bronze \[Crafted Item\] \<== Copper \[Item\] \+ Lead \[Item\] (Smelting)  
Iron Ribbon \[Crafted Item\] \<== Iron Nails \[Crafted Item\] \+ Misc \[Category\]

### **2\. Fire, Processing & Container Chain**

*This flow is unlocked by **Fire** and enables processing and liquid storage.*

Markdown

Cook \[Action\] \<== Fire \[Action/Station\] (Implied)  
Heat \[Action\] \<== Fuel torch with tar \+ Light with Pyrite \+ Flint \[Found Item\]  
Burn \[Action\] \<== Heat \[Action\]  
Gather Clay, form Jar, Bake in Fire \[Action\] \<== Cook \[Action\]  
Jar \[Crafted Item\] \<== Gather Clay, form Jar, Bake in Fire \[Action\]  
Fill, Drink & Store Water, Tar, Oil, etc \[Action\] \<== Jar \[Crafted Item\]

### **3\. Carbon and Miscellaneous Items**

*This section links Rudimentary inputs to advanced materials and general utility items.*

Markdown

Carbon \[Item\] \<== Burn \[Action\]  
Activated Carbon \[Item\] \<== Carbon \[Item\]  
Wood Fort \[Category\] \<== Barricade \[Item\]  
Tools \[Crafted Item\] \<== Wood Fort \[Category\]  
Barricade \[Item\] \<== Misc \[Category\]  
Sundial \[Item\] \<== Misc \[Category\]

## ---

**III. INTERMEDIATE TIER (REVISED)**

### **1\. Item Blanks and Initial Assembly**

*Tool Blanks are combined with handles/poles to create functional tools.*

Markdown

Combine w/ Handle or Pole \[Action\] \<== Smith Iron Tool Parts \[Item\]  
Carving Knife \[Crafted Item\] \<== Carving Knife Blade \[Item\]  
Hammer \[Crafted Item\] \<== Hammer Head \[Item\]  
File \[Crafted Item\] \<== File Blade \[Item\]  
Axe \[Crafted Item\] \<== Axe Blade \[Item\]  
Pickaxe \[Crafted Item\] \<== Pickaxe Head \[Item\]  
Shovel \[Crafted Item\] \<== Shovel Blade \[Item\]  
Hoe \[Crafted Item\] \<== Hoe Blade \[Item\]  
Fishing Pole \[Crafted Item\] \<== Iron Reel \[Item\]  
Saw \[Crafted Item\] \<== Saw Blade \[Item\]  
Sickle \[Crafted Item\] \<== Sickle Blade \[Item\]  
Chisel \[Crafted Item\] \<== Chisel Blade \[Item\] (Requires Steel)  
Trowel \[Crafted Item\] \<== Trowel Blade \[Item\] (Requires Steel)

### **2\. Tool Actions and Outputs (Including Lime Processing)**

*Functional tools unlock core actions and resources for the next tier.*

Markdown

Carve \[Action\] \<== Carving Knife \[Crafted Item\]  
Chop \[Action\] \<== Carving Knife \[Crafted Item\]  
Vessel, Shingle, Fruit Press \[Crafted Items\] \<== Carve \[Action\] \+ Chop \[Action\]  
Shard \[Item\] \<== Hammer \[Crafted Item\]  
Build \[Action\] \<== Hammer \[Crafted Item\]  
Smith \[Station\] \<== Build \[Action\] \+ Shard \[Item\]  
Smithy Process \[Action\] \<== File \[Crafted Item\]  
Cut \[Action\] \<== Axe \[Crafted Item\]  
Woodwork \[Action\] \<== Cut \[Action\]  
Mine \[Action\] \<== Pickaxe \[Crafted Item\]  
Ore / Gems \[Item\], Limestone \[Item\] \<== Mine \[Action\]  
Processed Lime \[Item\] \<== Limestone \[Item\] \+ Kiln \[Crafted Item\] \+ Burn \[Action\] (Bake at high temperature)  
Dig \[Action\] \<== Shovel \[Crafted Item\]  
Hills, Ditch, Road \[Action/Item\] \<== Dig \[Action\]  
Sow \[Action\] \<== Hoe \[Crafted Item\]  
Gardening \[Action/Station\] \<== Sow \[Action\]  
Fishing \[Action\] \<== Fishing Pole \[Crafted Item\]  
Boards \[Item\] \<== Saw \[Crafted Item\]  
Seeds \[Item\] \<== Boards \[Item\]  
Botany \[Action\] \<== Sickle \[Crafted Item\]  
Harvest \[Action\] \<== Botany \[Action\]  
Sprouts \[Item\] \<== Harvest \[Action\]  
Stonework \[Action\] \<== Chisel \[Crafted Item\] \+ Trowel \[Crafted Item\]

### **3\. Weapons and Lighting Outputs**

Markdown

Weapons \[Category\] \<== (Implied output of Woodwork)  
Broad Sword \[Crafted Item\] \<== Woodwork \[Action\]  
War Sword \[Crafted Item\] \<== Woodwork \[Action\]  
Battle Sword \[Crafted Item\] \<== Woodwork \[Action\]  
Long Sword \[Crafted Item\] \<== Woodwork \[Action\]  
Iron Lamp Head \[Crafted Item\] \<== Lamp Parts \[Item\]  
Copper Lamp Head \[Crafted Item\] \<== Lamp Parts \[Item\]  
Bronze Lamp Head \[Crafted Item\] \<== Lamp Parts \[Item\]  
Brass Lamp Head \[Crafted Item\] \<== Lamp Parts \[Item\]

## ---

**IV. ADVANCED TIER (REVISED)**

### **1\. Advanced Structural Chain (Stone Structures)**

*This flow requires **Steel** tools (Chisel & Trowel) and **Processed Lime** to create durable structures.*

Markdown

Create Bricks from Stone Ore \[Action\] \<== Iron Hammer \[Crafted Item\] \+ Chisel \[Crafted Item\] (Steel Tool)  
Lime Mortar \[Item\] \<== Processed Lime \[Item\] \+ Sand \[Item\] \+ Clay \[Item\] \+ Jar \[Crafted Item\] (For Mixing)  
Stonework (Build) \[Action\] \<== Create Bricks from Stone Ore \[Action\] \+ Lime Mortar \[Item\] \+ Trowel \[Crafted Item\] (Steel Tool)  
Stone Forts \[Crafted Item\] \<== Stonework (Build) \[Action\]  
Stone Houses \[Crafted Item\] \<== Stone Forts \[Crafted Item\]  
Castle Kingdoms \[Crafted Item\] \<== Stone Houses \[Crafted Item\] (Implied Next Step)

### **2\. Transportation & Storage**

*This section addresses the transition from Jar to higher-capacity transport.*

Markdown

Barrels \[Crafted Item\] \<== Woodwork \[Action\]  
Hand Cart \[Crafted Item\] \<== Build \[Action\] \+ Boards \[Item\]  
Cart \[Crafted Item\] \<== Build \[Action\] \+ Boards \[Item\] \+ Smithy Process \[Action\] (Metal Reinforcement)  
Load Barrel onto Cart \[Action\] \<== Barrels \[Crafted Item\] \+ Cart \[Crafted Item\]

### **3\. Advanced Gear and Combat Chain**

Markdown

Steel Lamp Head \[Crafted Item\] \<== (Precursor)  
Armor \[Category/Station\] \<== Steel Lamp Head \[Crafted Item\]  
Evasive \[Item/Ability\] \<== Armor \[Category/Station\]  
Defensive \[Item/Ability\] \<== Armor \[Category/Station\]  
Offensive \[Item/Ability\] \<== Armor \[Category/Station\]  
Battle \[Category/Station\] \<== Armor \[Category/Station\]

### **4\. Advanced Weapons**

Markdown

War Axe \[Crafted Item\] \<== Defensive \[Item/Ability\]  
Battle Axe \[Crafted Item\] \<== War Axe \[Crafted Item\]  
War Maul \[Crafted Item\] \<== Defensive \[Item/Ability\]  
Battle Hammer \[Crafted Item\] \<== Battle \[Category/Station\]  
Battle Scythe \[Crafted Item\] \<== Battle \[Category/Station\]  
War Scythe \[Crafted Item\] \<== Battle Scythe \[Crafted Item\]

This final version is complete. Is there anything else you would like to analyze or refine?