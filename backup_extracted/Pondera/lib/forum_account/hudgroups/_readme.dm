/*

  -- Introduction --

My goal is to provide simple, useful tools for creating HUDs.
The library doesn't do the heavy lifting for you, it just
makes it easier. You're still the one creating the HUDs, so
you have complete control over how things look and work.

The library provides you with objects and procs that can be
used to create and manage screen objects. You don't have to
set the screen_loc var yourself or add objects to client.screen,
that's all handled for you. Instead of worrying about those
details you can get right into creating functional HUDs.


  -- Running Demos --

To run a demo, pick a demo folder (ex: health-bar-demo) and
include all of the files in the folder. Then recompile and
run the library to see the demo.

I recommend looking at health-bar-demo first, it's the simplest
one.


  -- Version History --

Version 8 (posted 04-21-2012)
 * Added support for maptext. You can call the
   HudObject.set_maptext(maptext, width, height) proc to set the screen object's
   maptext. The last two arguments are used to set maptext_width and maptext_height,
   which are both 32 by default. Each argument defaults to null and the values are
   only updated if the parameters aren't null.
 * Updated the party-demo to show how you can use maptext.
 * Updated the chat-demo to contain an implementation of an on-screen chat log that
   uses maptext.
 * Updated the text-demo to show how you can use maptext.

Version 7 (posted 02-26-2012)
 * Made the HudInput control in the interface-demo play nice with the
   Keyboard library's NO_KEY_REPEAT flag.
 * Fixed a bug in the Font object's wrap_text() proc. Previously it hadn't
   been taking into account line breaks in the string you passed to the proc.
 * Added the minimap-demo which shows how to create a minimap that tracks and
   shows the positions of mobs.

Version 6 (posted 12-07-2011)
 * Added the DragAndDrop() proc to the HudGroup object, which is called
   when a HudObject's MouseDrop() proc is called. You can override the
   group's DragAndDrop proc to create custom behavior for the group. The
   proc takes two arguments - the first is the HudObject you're dragging,
   the second is the object you dropped it on (which might not be a HudObject).
 * Added the "inventory-demo", which contains an on-screen inventory
   system. Walk over items to pick them up. Use the "toggle inventory"
   verb to hide or show your inventory, and drag items to move them,
   equip them, or unequip them.
 * Changed the px and py vars on the HudObject object to "sx" and "sy" so
   they don't conflict with other libraries of mine.
 * Changed the __px and __py vars of the HudGroup object to be called "sx"
   and "sy". These vars can be used to reference the group's current position
   but shouldn't be modified. To change the group's position use its pos()
   proc.
 * Made some internal changes to how HudGroups hide and show HudObjects, which
   makes use of the new __hide_object() and __show_object() procs.
 * Added the ability to type spaces to input.dm in interface-demo.
 * Added the #define statement to include the Keyboard library only if you have
   input.dm included in the interface-demo.
 * Added demo-form.dm to interface-demo. This file defines the "game form" verb
   which brings up a game creation form. You can type a name, select a level, and
   click submit, which calls the form's submit() proc which prints out the values
   you selected.

Version 5 (posted 12-03-2011)
 * Added the HudInput control to the interface-demo. This is an on-screen
   textbox that players can type in. The demo was updated to include one
   on screen text box whose value is output when you click the "ok" button.
   This demo now requires the Forum_account.Keyboard library which can be
   found here: http://www.byond.com/developer/Forum_account/Keyboard

Version 4 (posted 11-30-2011)
 * Added the width and height named parameters to the HudGroup's
   add proc. These specify the width and height of the screen object
   just like you would by calling the HudObject's size() proc.
 * Added the "chat-demo", which shows how to create and use an on-screen
   chat log.
 * Added some procs to the Font object which are just aliases of
   other procs. The original procs had misleaning names because
   the name said "word" but you didn't have to pass just one word
   to the proc, you could pass a multi-word string. The aliases say
   "text" instead, but the original procs are kept anyway.
    - Added the text_width() proc to the Font object which is just an
      alias of the word_width proc.
    - Added the cut_text() proc to the Font object which is just an alias
      of the cut_word() proc.
 * Added the "interface-demo", which contains HUD-based implementations
   of some interface controls. Each control is implemented as its own type
   of HudGroup, which means you just have to instantiate the object type to
   create the control and can use its pos() proc to move it. The demo
   currently contains:
    - Labels: labels can display text and capture click events, so they can
      also be used as buttons. You can set the background color, size, text
      alignment, action (the proc that's called when clicked), and position.
    - Buttons: they're a child type of the label object that have some
      different default values (ex: size, background color, border, etc.)
    - Option Groups: you can define a set of options and the selection mode.
      The selection mode determines if the list uses radio buttons (you select
      a single value) or check boxes (you select any combination of values).

Version 3 (posted 11-17-2011)
 * Changed how objects are added to HudGroups. The HudGroup's add
   proc can be used in one of three forms. Parameters written in
   square brackets are optional named parameters you can set.
    - add(client/c) - adds a client to the list of players viewing
      the hud group. Returns 0 or 1.
    - add(mob/m) - adds the mob's client to the list of viewers.
      Returns 0 or 1.
    - add(x, y, ...) - creates a screen object at the specified
      location and returns the HudObject that was created. There are
      many named arguments you can also use to set properties of the
      new object: icon_state, text, layer, and value.
 * Changed how objects are removed from HudGroups. The HudGroup's remove()
   proc can now be used in one of four forms. All return 1 or 0 to
   indicate success or failure:
    - remove(client/c) - removes a client from the list of viewers
    - remove(mob/m) - removes the mob's client from the list of viewers
    - remove(HudObject/h) - removes the object from the group
    - remove(index) - removes the object at the specified index in the
      group's "objects" list from the group.
    - remove() - removes the last object in the group.
 * Added the cut_word() proc to the Font object. The proc takes a
   string and a width (in pixels) and returns the part of the string
   that fits inside that width. For example, calling cut_word("testing", 16)
   might return "test", because that's all that can fit inside 16 pixels.
 * Added the "border-demo" which shows how to create a border around the
   edge of the player's screen that can be updated as the player's screen
   size changes.
 * Added the "party-demo", which shows how to create an on-screen
   indicator of where your allies are located.

Version 2 (posted 11-16-2011)
 * Added support for text - call the HudGroup's add_text() proc
   to create a screen object with text attached to it. You can
   also call the HudObject's set_text() proc to set or udpate
   its text.
 * Added support for fonts. Font objects are necessary for writing
   text on a screen object. They can also be used to make text that
   wraps to fit inside a specified width. See the Font object in
   fonts.dm for more details.
 * Added two new demos:
    - text-demo shows the bare minimum that's required to draw
      text on the screen using a font.
    - message-box-demo shows how to create an on-screen message
      box, the message is dynamically updated and the box is
      closed by clicking an "Ok" button.

Version 1 (posted 11-15-2011)
 * Initial post.
 * Contains the HudGroup and HudObject objects.
 * Contains three demos: flyout-menu-demo, health-bar-demo,
   and menu-demo.


  -- Using the Library --

The library provides you with the HudGroup object that is used
to create screen objects. For example:

  var/HudGroup/group = new(mob, 'hud.dmi')
  group.add(0, 0, "heart")

That creates a group which will be shown to the specified mob
and adds a screen object. The first two arguments to add()
are the position - they're specified in pixels and are measured
from the bottom-left corner of the screen. The last argument
is the icon state of the object. All screen objects use the
HudGroup's icon.

The call to group.add() creates an instance of the /HudObject
type. Both the HudObject and HudGroup objects have procs to
set their position:

  group.pos(0, 32)
  object = group.add(...)
  object.pos(8, 8)

That will set the group's position to be 32 pixels up from the
bottom-left corner of the screen. The object is set to 8, 8
within the group, so it's absolute position is 8 pixels over
and 40 pixels up from the bottom-left corner of the screen.

You never have to compute, set, or parse screen_loc values, the
library does this for you inside the pos() proc. The HudObject
object is the actual screen object, so you can set properties
like icon, icon_state, and layer directly if you need to.

The HudGroup object also has procs called hide, show, and toggle
that can be used to hide or show the entire group.


  -- Handling Click Events --

When a HudObject is clicked the event is passed to the HudGroup's
Click proc and the object you clicked is passed as a parameter.
It's done this way because you'll often override the HudGroup to
create your own custom group types that'll each need to handle
events different ways.

You may find that you need to associate information with each
screen object. For example, suppose we create an on-screen
inventory:

  var/InventoryGroup/group = new(mob)
  var/px = 0
  for(var/obj/o in mob.contents)
      group.add(px, 0, o.icon_state)
      px += 32

We'll have a problem in the group's Click proc:

  InventoryGroup
      Click(HudObject/object)
          // equip the item

The Click proc only has a reference to the screen object, not to
the item it represents, so there's no way to know which item to
equip. We can fix this by assigning a value to the screen object
when we create it:

  for(var/obj/o in mob.contents)
      group.add(px, 0, o.icon_state, value = o)

  Click(HudObject/object)
      var/obj/item = object.value
      item.equip()

By setting the value when we create the object we have the
reference to the item when the object is clicked.

*/