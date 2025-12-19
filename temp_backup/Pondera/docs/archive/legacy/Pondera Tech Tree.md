Absolutely\! That is the most efficient way to prepare this data for a coding agent.

Here is the complete, consolidated Pondera Tech Tree document, combining the **Rudimentary, Basic, Intermediate, and Advanced Tiers** into a single, cohesive file. The structure remains consistent across all tiers for easy parsing.

# ---

**PONDERA TECH TREE: COMPLETE RECIPE DOCUMENT**

Data Structure: Output\_Node \[Type\] \<== Input\_Node \[Type\]  
Nodes are classified by type: \[Category\], \[Item\], \[Action\], \[Process Base\], \[Crafted Item\], \[Found Item\], \[Ability\], \[Station\], \[Requirement\]

## ---

**I. RUDIMENTARY TIER**

### **Primary Sources & Scavenging Chain**

Obsidian \[Item\] \<== Obsidian Field \[Category\]  
Ueik Thorn \[Item\] \<== Ancient Ueik Tree \[Category\]  
Wooden Haunch (Affix) \[Process Base\] \<== Hallow Ueik Tree \[Category\]  
Rock \[Found Item\] \<== Search Flowers or Tall Grass \[Category\]  
Flint \[Found Item\] \<== Rock \[Found Item\]  
Ancient Ueik Splinter \[Found Item\] \<== Flint \[Found Item\]  
Pyrite \[Found Item\] \<== Ancient Ueik Splinter \[Found Item\]  
Wooden Haunch \[Found Item\] \<== Pyrite \[Found Item\]  
Whetstone \[Found Item\] \<== Wooden Haunch \[Found Item\]

### **Basic Tool Crafting**

Stone Hammer \[Crafted Item\] \<== Rock \[Found Item\] \+ Wooden Haunch (Affix) \[Process Base\]  
Ueik Pickaxe \[Crafted Item\] \<== Ueik Thorn \[Item\] \+ Wooden Haunch (Affix) \[Process Base\]  
Obsidian Knife \[Crafted Item\] \<== Obsidian \[Item\] \+ Wooden Haunch (Affix) \[Process Base\]

### **Processing & Actions**

Slice Fir from Ancient Ueik Tree \[Action\] \<== Obsidian Knife \[Crafted Item\]  
Carve Haunch \[Action\] \<== Slice Fir from Ancient Ueik Tree \[Action\]  
Novice Handle \[Item\] \<== Carve Haunch \[Action\]  
Kindling \[Item\] \<== Carve Haunch \[Action\]  
Combine Handle to tool parts \[Action\] \<== Carve Haunch \[Action\]  
Torch \[Crafted Item\] \<== Kindling \[Item\]  
Mine Stone Rocks for Iron Ore \[Action\] \<== Ueik Pickaxe \[Crafted Item\]  
Smelt Iron Ore in Novice Fire \[Action\] \<== Stone Hammer \[Crafted Item\] \+ Mine Stone Rocks for Iron Ore \[Action\]  
Sew Ueik Fir w/ Splinter \[Action\] \<== Ancient Ueik Splinter \[Found Item\]  
Gloves \[Crafted Item\] \<== Sew Ueik Fir w/ Splinter \[Action\]  
Handle Hot Items/Actions \[Ability\] \<== Gloves \[Crafted Item\] \+ Fire (Heat, Cook, Smelt, Bake) \[Action/Station\]  
Fire (Heat, Cook, Smelt, Bake) \[Action/Station\] \<== Kindling \[Item\]  
Light Novice Fire/Torch \[Requirement\] \<== Flint \[Found Item\] \+ Pyrite \[Found Item\]

## ---

**II. BASIC TIER**

### **External/Misc Inputs & Construction**

Iron Hammer Head \[Item\] \<== (Precursor)  
Misc \[Category\] \<== (External Source)  
Barricade \[Item\] \<== Misc \[Category\]  
Sundial \[Item\] \<== Misc \[Category\]  
Wood Fort \[Category\] \<== Barricade \[Item\]  
Tools \[Crafted Item\] \<== Wood Fort \[Category\]  
Iron Hammer \[Crafted Item\] \<== Iron Hammer Head \[Item\] \+ Novice Handle \[Item\] (Implied)  
Build \[Action\] \<== Iron Hammer \[Crafted Item\]  
Wood House \[Crafted Item\] \<== Build \[Action\]  
Furnishings \[Crafted Item\] \<== Wood House \[Crafted Item\]

### **Fire, Processing & Containers**

Fire \[Action/Station\] \<== (Kindling \- Implied)  
Cook \[Action\] \<== Fire \[Action/Station\]  
Heat \[Action\] \<== Fuel torch with tar \+ Light with Pyrite \+ Flint \[Found Item\]  
Burn \[Action\] \<== Heat \[Action\]  
Carbon \[Item\] \<== Burn \[Action\]  
Activated Carbon \[Item\] \<== Carbon \[Item\]  
Gather Clay, form Jar, Bake in Fire \[Action\] \<== Cook \[Action\]  
Jar \[Crafted Item\] \<== Gather Clay, form Jar, Bake in Fire \[Action\]  
Fill, Drink & Store Water, Tar, Oil, etc \[Action\] \<== Jar \[Crafted Item\]

### **Smelting & Metalworking**

Forge \[Crafted Item\] \<== Furnishings \[Crafted Item\]  
Anvil Head \[Crafted Item\] \<== Forge \[Crafted Item\]  
Anvil \[Crafted Item\] \<== Anvil Head \[Crafted Item\]  
Heat, Smelt ingots \[Action\] \<== Forge \[Crafted Item\]  
Iron \[Crafted Item\] \<== Heat, Smelt ingots \[Action\]  
Smith \[Category/Station\] \<== Anvil \[Crafted Item\]  
Steel \[Crafted Item\] \<== Iron \[Crafted Item\] \+ Carbon \[Item\] (Implied Smelting)  
Iron Nails \[Crafted Item\] \<== Steel \[Crafted Item\]  
Iron Ribbon \[Crafted Item\] \<== Iron Nails \[Crafted Item\] \+ Misc \[Category\]  
Brass \[Crafted Item\] \<== Copper \[Item\] \+ Zinc \[Item\] (Smelting required)  
Bronze \[Crafted Item\] \<== Copper \[Item\] \+ Lead \[Item\] (Smelting required)

## ---

**III. INTERMEDIATE TIER**

### **Tool Heads and Initial Crafting**

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
Chisel \[Crafted Item\] \<== Chisel Blade \[Item\]  
Trowel \[Crafted Item\] \<== Trowel Blade \[Item\]

### **Tool Actions and Outputs**

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
Ore / Gems \[Item\] \<== Mine \[Action\]  
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

### **Intermediate Weapons and Lighting**

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

**IV. ADVANCED TIER**

### **Advanced Structural Chain (Stone Structures)**

Hammer \+ Chisel, Bricks from Stone Ore \[Action\] \<== (Precursor Action)  
Collect Sand w/ Jar, Combine with Clay for Mortar. Use Trowel with Mortar and Bricks. \[Action\] \<== Hammer \+ Chisel, Bricks from Stone Ore \[Action\]  
Stone Forts \[Crafted Item\] \<== Collect Sand w/ Jar, Combine with Clay for Mortar. Use Trowel with Mortar and Bricks. \[Action\]  
Stone Houses \[Crafted Item\] \<== Stone Forts \[Crafted Item\]

### **Advanced Gear and Combat Chain**

Steel Lamp Head \[Crafted Item\] \<== (Precursor)  
Armor \[Category/Station\] \<== Steel Lamp Head \[Crafted Item\]  
Evasive \[Item/Ability\] \<== Armor \[Category/Station\]  
Defensive \[Item/Ability\] \<== Armor \[Category/Station\]  
Offensive \[Item/Ability\] \<== Armor \[Category/Station\]  
Battle \[Category/Station\] \<== Armor \[Category/Station\]

### **Advanced Weapons**

War Axe \[Crafted Item\] \<== Defensive \[Item/Ability\]  
Battle Axe \[Crafted Item\] \<== War Axe \[Crafted Item\]  
War Maul \[Crafted Item\] \<== Defensive \[Item/Ability\]  
Battle Hammer \[Crafted Item\] \<== Battle \[Category/Station\]  
Battle Scythe \[Crafted Item\] \<== Battle \[Category/Station\]  
War Scythe \[Crafted Item\] \<== Battle Scythe \[Crafted Item\]  
