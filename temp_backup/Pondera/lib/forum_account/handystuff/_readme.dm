/*

Version 6
* Fixed some bugs with the icon procs. They should now work
  properly for icons of any size. (Thanks MyNameIsSylar for
  pointing this problem and suggesting the fix!)
* Made a slight change to the return value of the icon procs,
  if an icon_state is specified then the icon returned contains
  a single, unnamed state. This lets you do things like:
    mob.icon = Icon.Rotate('icon.dmi', "mob", 20)
  Previously you'd have to also set the mob's icon_state to "mob".
* Added comments to the library code and demo. Most notably,
  each file has a comment at the top to explain its contents.
  Even if you don't care about how the code works, this info
  is good to know.
* Added support for client mouse procs in mouse.dm.

Version 5
* Updated icon procs (Fade and Rotate) to work for icons of
  any size, not just 32x32.
* Changed the way that keyboard events are handled. Previously
  it used pre-defined macros in keyboard.dmf. Now it dynamically
  adds macros at runtime.
* keyboard.dmf is now only needed for the demo and was moved to
  the demo/ folder and renamed "demo.dmf".

The library code is commented but you should be able to figure out all
of the features from the demo (demo\demo.dm). If you have any questions
about the library, please post on my forum:

    http://www.byond.com/members/Forumaccount/forum


To run the demo, include all files in the "demo" folder (to include a
file, check the box next to it). If you're using this library in a
project of your own make sure the demo files aren't included, otherwise
they can interfere with your code.

*/