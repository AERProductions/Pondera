/*

Version 2.7 (posted 07-12-2012)
 * Fixed some bugs with the Window control. Previously it wouldn't work because
   the library assumed that all controls had both a control_id and window_id, but
   windows only have a window_id.
 * Modified the list parsing object to also support the syntax for hashtables.
 * Added the ability to pass associative lists between DM and JavaScript. Unfortunately
   this requires checking to see if a list is an associative list and the only way
   I've found to do that causes a runtime error if the list is not associative. The
   code still functions - it expects that this error can happen - but it still prints
   a "bad index" error to your output console.
 * Updated the javascript-demo to include examples of passing hashtables back and
   forth between DM and JS. Also cleaned up the code a little.

Version 2.6 (posted 03-13-2012)
 * Added the Link() and Browse() procs to the /Browser object. This proc takes a
   single parameter, a URL, and redirects the browser control to that URL.
 * Updated the New() proc for all controls to be more flexible. The arguments are
   a window ID, control ID, and a mob. The window and control IDs can be passed
   as separate strings or as one string of the form "window.control". If they're
   separate strings, the first string is assumed to be the window ID.
 * Added support for nested lists to be passed from JavaScript to DM.
 * Fixed a bug with object references being parsed incorrectly when they were part
   of a list.
 * Removed some procs from base.dm and made the library require the
   Forum_account.Text library.
 * Changed the name of "html-demo" to "browser-demo" and updated the demo a little.
 * Removed the following demos: lesson-2, lesson-4, stat-demo, and window-demo.

Version 2.5
 * Created the JS2DM proc which is an alias of BROWSER_UPDATE_SCRIPT. It
   does the exact same thing, it just has a shorter name. The BROWSER_UPDATE_SCRIPT
   proc is still in the library for backwards compatibility.
 * Documented the code in the library - added headers to each file and some inline
   comments.
 * Added a list parser (list-parsing.dm) so you can now pass JavaScript arrays to
   DM procs and they'll automatically be converted to DM lists. It doesn't handle
   nested lists or associative arrays (JS objects/hashtables).
 * Added the js-hello-world demo which is a very basic example of calling a DM proc
   from JS.
 * Split the demo that was previously called "demo" into controls-demo and window-demo.
   They're essentially the same. window-demo uses the library to generate code for the
   window based on the .dmf file. controls-demo doesn't do this, it just instantiates
   the /Control objects (/Browser, /Info, /Label, etc.) directly.
 * Added javascript-demo which shows examples of passing different data types from
   JavaScript to DM and from DM to JavaScript.

Version 2.2
 * Worked on JavaScript-to-DM function calls. See the
   "javascript-demo" demo for more details.
 * I worked on the DM-side parsing of arguments from
   JavaScript functions. If you pass a mob to JavaScript
   then back to DM, the DM proc will be passed a reference
   to the mob.
 * Strings, numbers, objects, and arrays can be passed from
   JavaScript to DM.


This "library" provides a nicer way to deal with interface controls. Instead of this:

	winset(player, "window1.label1", "text=Hello+world!")

You can type this:

	player.window1.label1.Text("Hello world!")

The library handles the messy details of dealing with different variable types (booleans,
numbers, colors, text, etc.). This lets you do things like this:

	if(label1.IsVisible())
		world << "label1 is visible!"

	// instead of:

	if(winget(src. "window1.label1", "is-visible") == "true")
		world << "label1 is visible!"

The IsVisible proc knows that the is-visible property is a boolean, so instead of returning the
string "true" or "false", it returns 0 or 1.


The library also caches values that it doesn't expect will change on the client end. If you want
to get the text displayed on a label you'd do this:

	winget(player, "label1", "text")

Normally, the server doesn't keep track of this information. When the server processes this command
it sends a message to the client requesting this information and waits for a response.

Most of the time, at least the way I use interface controls, this wouldn't be necessary. If changes
to the label's text are only issued by the server we can just remember the last value we set it to
and return that immediately (eliminating the need to ask the client).

Some properties can change client-side very easily. If controls are anchored and you resize the
window, the position and size of the control will change. These properties are always requested
from the client using winget.


  -- DEMOS --

The library comes with many demos. Each demo is contained in its own sub-folder. To run a demo,
check off all files in a sub-folder, compile, and run. Make sure you only have the files for one
demo included at a time.

browser-demo
	An example of using the library and a browser control to call a JavaScript function from DM and
	call a DM proc from JavaScript.

controls-demo
	An example of how to use the different types of /Control datums to manipulate interface controls.

javascript-demo
	A simple JavaScript demo that shows the library's ability to pass different data types back and
	forth between DM and JavaScript. You can pass strings, numbers, lists, and even object references.

js-hello-world
	A basic example of calling a DM proc from JavaScript.





Here is the list of properties:

									can change
Name					type		client-side

pos						position	yes
current-cell			position	no
anchor1					position	no
anchor2					position	no

size					size		yes
cells					size		no

text-color				color		no
background-color		color		no
link-color				color		no
visited-color			color		no
line-color				color		no
highlight-color			color		no
tab-text-color			color		no
tab-background-color	color		no
bar-color				color		no

is-visible				boolean		no
is-default				boolean		no
drop-zone				boolean		no
show-names				boolean		no
auto-format				boolean		no
allow-html				boolean		no
multi-line				boolean		no
text-mode				boolean		MAYBE
is-disabled				boolean		no
is-transparent			boolean		no
right-click				boolean		no
keep-aspect				boolean		no
text-wrap				boolean		no
enable-http-images		boolean		no
is-password				boolean		no
no-command				boolean		no
small-icons				boolean		no
is-list					boolean		no
show-history			boolean		no
show-url				boolean		no
use-title				boolean		no
is-slider				boolean		no
is-flat					boolean		no
stretch					boolean		no
is-checked				boolean		no

font-size				number		no
max-lines				number		no
tab-font-size			number		no
width					number		no
angle1					number		no
angle2					number		no
value					number		yes
icon-size				number		no

"bold italic underline strike"
font-style				fontstyle	no
tab-font-style			fontstyle	no

"none line sunken"
border					borderstyle	no

"center stretch tile"
image-mode				imagemode	no

"center left right top bottom top-left top-right bottom-left bottom-right"
align					alignment	no

text					text		no
font-family				text		no
image					text		no
tab-font-family			text		no

"pushbutton pushbox checkbox radio"
button-type				buttontype	no



Label_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","text","image","image-mode","keep-aspect","align","text-wrap")
Output_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","link-color","visited-color","style","enable-http-images","max-lines","image")
Input_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","command","multi-line","is-password","no-command")
Grid_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","cells","current-cell","show-lines","small-icons","show-names","enable-http-images","link-color","visited-color","line-color","style","is-list")
Tab_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","tabs","current-tab","multi-line","on-tab")
Bar_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","bar-color","is-slider","width","dir","angle1","angle2","value","on-change")
Button_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","text","image","command","is-flat","stretch","is-checked","group","button-type")
Map_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","icon-size","text-mode","on-show","on-hide")
Browser_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","show-history","show-url","auto-format","use-title","on-show","on-hide")
Info_members = list("pos","size","anchor1","anchor2","font-family","font-size","font-style","text-color","background-color","is-visible","is-disabled","is-transparent","is-default","border","drop-zone","right-click","saved-params","highlight-color","tab-text-color","tab-background-color","tab-font-family","tab-font-size","tab-font-style","allow-html","multi-line","on-show","on-hide","on-tab")


The properties that don't have "XXXXXXXX" before them are not supported.

XXXXXXXX /Label/proc/Pos = /Pos
XXXXXXXX /Label/proc/Size = /Size
XXXXXXXX /Label/proc/Anchor1 = none
XXXXXXXX /Label/proc/Anchor2 = none
XXXXXXXX /Label/proc/FontFamily =
XXXXXXXX /Label/proc/FontSize = 0
XXXXXXXX /Label/proc/FontStyle =
XXXXXXXX /Label/proc/TextColor = #000000
XXXXXXXX /Label/proc/BackgroundColor = #bbeeff
XXXXXXXX /Label/proc/IsVisible = true
XXXXXXXX /Label/proc/IsDisabled = false
XXXXXXXX /Label/proc/IsTransparent = false
XXXXXXXX /Label/proc/IsDefault = false
XXXXXXXX /Label/proc/Border = none
XXXXXXXX /Label/proc/DropZone = false
XXXXXXXX /Label/proc/RightClick = false
/Label/proc/SavedParams =
XXXXXXXX /Label/proc/Text = hello, world!
XXXXXXXX /Label/proc/Image =
XXXXXXXX /Label/proc/ImageMode = center
XXXXXXXX /Label/proc/KeepAspect = false
XXXXXXXX /Label/proc/Align = center
XXXXXXXX /Label/proc/TextWrap = false

XXXXXXXX /Output/proc/Pos = /Pos
XXXXXXXX /Output/proc/Size = /Size
XXXXXXXX /Output/proc/Anchor1 = none
XXXXXXXX /Output/proc/Anchor2 = none
XXXXXXXX /Output/proc/FontFamily =
XXXXXXXX /Output/proc/FontSize = 0
XXXXXXXX /Output/proc/FontStyle =
XXXXXXXX /Output/proc/TextColor = #000000
XXXXXXXX /Output/proc/BackgroundColor = #ffffff
XXXXXXXX /Output/proc/IsVisible = true
XXXXXXXX /Output/proc/IsDisabled = false
XXXXXXXX /Output/proc/IsTransparent = false
XXXXXXXX /Output/proc/IsDefault = true
XXXXXXXX /Output/proc/Border = none
XXXXXXXX /Output/proc/DropZone = false
XXXXXXXX /Output/proc/RightClick = false
/Output/proc/SavedParams = max-lines
XXXXXXXX /Output/proc/LinkColor = #0000ff
XXXXXXXX /Output/proc/VisitedColor = #ff00ff
/Output/proc/Style =
XXXXXXXX /Output/proc/EnableHttpImages = false
XXXXXXXX /Output/proc/MaxLines = 3000
XXXXXXXX /Output/proc/Image =

XXXXXXXX /Input/proc/Pos = /Pos
XXXXXXXX /Input/proc/Size = /Size
XXXXXXXX /Input/proc/Anchor1 = none
XXXXXXXX /Input/proc/Anchor2 = none
XXXXXXXX /Input/proc/FontFamily =
XXXXXXXX /Input/proc/FontSize = 0
XXXXXXXX /Input/proc/FontStyle =
XXXXXXXX /Input/proc/TextColor = #000000
XXXXXXXX /Input/proc/BackgroundColor = #ffffff
XXXXXXXX /Input/proc/IsVisible = true
XXXXXXXX /Input/proc/IsDisabled = false
XXXXXXXX /Input/proc/IsTransparent = false
XXXXXXXX /Input/proc/IsDefault = false
XXXXXXXX /Input/proc/Border = none
XXXXXXXX /Input/proc/DropZone = false
XXXXXXXX /Input/proc/RightClick = false
/Input/proc/SavedParams =
XXXXXXXX /Input/proc/Command =
XXXXXXXX /Input/proc/MultiLine = false
XXXXXXXX /Input/proc/IsPassword = false
XXXXXXXX /Input/proc/NoCommand = false

/Grid/proc/Cell =
XXXXXXXX /Grid/proc/Pos = /Pos
XXXXXXXX /Grid/proc/Size = /Size
XXXXXXXX /Grid/proc/Anchor1 = none
XXXXXXXX /Grid/proc/Anchor2 = none
XXXXXXXX /Grid/proc/FontFamily =
XXXXXXXX /Grid/proc/FontSize = 0
XXXXXXXX /Grid/proc/FontStyle =
XXXXXXXX /Grid/proc/TextColor = #000000
XXXXXXXX /Grid/proc/BackgroundColor = #ffffff
XXXXXXXX /Grid/proc/IsVisible = true
XXXXXXXX /Grid/proc/IsDisabled = false
XXXXXXXX /Grid/proc/IsTransparent = false
XXXXXXXX /Grid/proc/IsDefault = false
XXXXXXXX /Grid/proc/Border = none
XXXXXXXX /Grid/proc/DropZone = true
XXXXXXXX /Grid/proc/RightClick = false
/Grid/proc/SavedParams =
XXXXXXXX /Grid/proc/Cells = 1x2
XXXXXXXX /Grid/proc/CurrentCell = 1,2
/Grid/proc/ShowLines = both
XXXXXXXX /Grid/proc/SmallIcons = false
XXXXXXXX /Grid/proc/ShowNames = true
XXXXXXXX /Grid/proc/EnableHttpImages = false
XXXXXXXX /Grid/proc/LinkColor = #0000ff
XXXXXXXX /Grid/proc/VisitedColor = #ff00ff
XXXXXXXX /Grid/proc/LineColor = #c0c0c0
/Grid/proc/Style =
XXXXXXXX /Grid/proc/IsList = false

XXXXXXXX /Browser/proc/Pos = /Pos
XXXXXXXX /Browser/proc/Size = /Size
XXXXXXXX /Browser/proc/Anchor1 = none
XXXXXXXX /Browser/proc/Anchor2 = none
XXXXXXXX /Browser/proc/FontFamily =
XXXXXXXX /Browser/proc/FontSize = 0
XXXXXXXX /Browser/proc/FontStyle =
XXXXXXXX /Browser/proc/TextColor = #000000
XXXXXXXX /Browser/proc/BackgroundColor = none
XXXXXXXX /Browser/proc/IsVisible = true
XXXXXXXX /Browser/proc/IsDisabled = false
XXXXXXXX /Browser/proc/IsTransparent = false
XXXXXXXX /Browser/proc/IsDefault = false
XXXXXXXX /Browser/proc/Border = none
XXXXXXXX /Browser/proc/DropZone = false
XXXXXXXX /Browser/proc/RightClick = false
/Browser/proc/SavedParams =
XXXXXXXX /Browser/proc/ShowHistory = false
XXXXXXXX /Browser/proc/ShowUrl = false
XXXXXXXX /Browser/proc/AutoFormat = true
XXXXXXXX /Browser/proc/UseTitle = false
/Browser/proc/OnShow =
/Browser/proc/OnHide =

XXXXXXXX /Info/proc/Pos = /Pos
XXXXXXXX /Info/proc/Size = /Size
XXXXXXXX /Info/proc/Anchor1 = none
XXXXXXXX /Info/proc/Anchor2 = none
XXXXXXXX /Info/proc/FontFamily =
XXXXXXXX /Info/proc/FontSize = 0
XXXXXXXX /Info/proc/FontStyle =
XXXXXXXX /Info/proc/TextColor = #000000
XXXXXXXX /Info/proc/BackgroundColor = #ffffff
XXXXXXXX /Info/proc/IsVisible = true
XXXXXXXX /Info/proc/IsDisabled = false
XXXXXXXX /Info/proc/IsTransparent = false
XXXXXXXX /Info/proc/IsDefault = false
XXXXXXXX /Info/proc/Border = none
XXXXXXXX /Info/proc/DropZone = true
XXXXXXXX /Info/proc/RightClick = false
/Info/proc/SavedParams =
XXXXXXXX /Info/proc/HighlightColor = #00ff00
XXXXXXXX /Info/proc/TabTextColor = #000000
XXXXXXXX /Info/proc/TabBackgroundColor = none
XXXXXXXX /Info/proc/TabFontFamily =
XXXXXXXX /Info/proc/TabFontSize = 0
XXXXXXXX /Info/proc/TabFontStyle =
XXXXXXXX /Info/proc/AllowHtml = true
XXXXXXXX /Info/proc/MultiLine = true
/Info/proc/OnShow =
/Info/proc/OnHide =
XXXXXXXX /Info/proc/OnTab =

XXXXXXXX /Tab/proc/Pos = /Pos
XXXXXXXX /Tab/proc/Size = /Size
XXXXXXXX /Tab/proc/Anchor1 = none
XXXXXXXX /Tab/proc/Anchor2 = none
XXXXXXXX /Tab/proc/FontFamily =
XXXXXXXX /Tab/proc/FontSize = 0
XXXXXXXX /Tab/proc/FontStyle =
XXXXXXXX /Tab/proc/TextColor = #000000
XXXXXXXX /Tab/proc/BackgroundColor = none
XXXXXXXX /Tab/proc/IsVisible = true
XXXXXXXX /Tab/proc/IsDisabled = false
XXXXXXXX /Tab/proc/IsTransparent = false
XXXXXXXX /Tab/proc/IsDefault = false
XXXXXXXX /Tab/proc/Border = none
XXXXXXXX /Tab/proc/DropZone = false
XXXXXXXX /Tab/proc/RightClick = false
/Tab/proc/SavedParams =
/Tab/proc/Tabs =
/Tab/proc/CurrentTab =
XXXXXXXX /Tab/proc/MultiLine = true
XXXXXXXX /Tab/proc/OnTab =

XXXXXXXX /Bar/proc/Pos = /Pos
XXXXXXXX /Bar/proc/Size = /Size
XXXXXXXX /Bar/proc/Anchor1 = none
XXXXXXXX /Bar/proc/Anchor2 = none
XXXXXXXX /Bar/proc/FontFamily =
XXXXXXXX /Bar/proc/FontSize = 0
XXXXXXXX /Bar/proc/FontStyle =
XXXXXXXX /Bar/proc/TextColor = #000000
XXXXXXXX /Bar/proc/BackgroundColor = none
XXXXXXXX /Bar/proc/IsVisible = true
XXXXXXXX /Bar/proc/IsDisabled = false
XXXXXXXX /Bar/proc/IsTransparent = false
XXXXXXXX /Bar/proc/IsDefault = false
XXXXXXXX /Bar/proc/Border = none
XXXXXXXX /Bar/proc/DropZone = false
XXXXXXXX /Bar/proc/RightClick = false
/Bar/proc/SavedParams =
XXXXXXXX /Bar/proc/BarColor = #ffffff
XXXXXXXX /Bar/proc/IsSlider = false
XXXXXXXX /Bar/proc/Width = 10
/Bar/proc/Dir = east
XXXXXXXX /Bar/proc/Angle1 = 0
XXXXXXXX /Bar/proc/Angle2 = 180
XXXXXXXX /Bar/proc/Value = 0
/Bar/proc/OnChange =

XXXXXXXX /Button/proc/Pos = /Pos
XXXXXXXX /Button/proc/Size = /Size
XXXXXXXX /Button/proc/Anchor1 = none
XXXXXXXX /Button/proc/Anchor2 = none
XXXXXXXX /Button/proc/FontFamily =
XXXXXXXX /Button/proc/FontSize = 0
XXXXXXXX /Button/proc/FontStyle =
XXXXXXXX /Button/proc/TextColor = #000000
XXXXXXXX /Button/proc/BackgroundColor = none
XXXXXXXX /Button/proc/IsVisible = true
XXXXXXXX /Button/proc/IsDisabled = false
XXXXXXXX /Button/proc/IsTransparent = false
XXXXXXXX /Button/proc/IsDefault = false
XXXXXXXX /Button/proc/Border = none
XXXXXXXX /Button/proc/DropZone = false
XXXXXXXX /Button/proc/RightClick = false
/Button/proc/SavedParams = is-checked
XXXXXXXX /Button/proc/Text =
XXXXXXXX /Button/proc/Image =
XXXXXXXX /Button/proc/Command =
XXXXXXXX /Button/proc/IsFlat = false
XXXXXXXX /Button/proc/Stretch = false
XXXXXXXX /Button/proc/IsChecked = false
/Button/proc/Group =
/Button/proc/ButtonType = pushbutton

XXXXXXXX /Map/proc/Pos = /Pos
XXXXXXXX /Map/proc/Size = /Size
XXXXXXXX /Map/proc/Anchor1 = none
XXXXXXXX /Map/proc/Anchor2 = none
XXXXXXXX /Map/proc/FontFamily =
XXXXXXXX /Map/proc/FontSize = 0
XXXXXXXX /Map/proc/FontStyle =
XXXXXXXX /Map/proc/TextColor = #000000
XXXXXXXX /Map/proc/BackgroundColor = none
XXXXXXXX /Map/proc/IsVisible = true
XXXXXXXX /Map/proc/IsDisabled = false
XXXXXXXX /Map/proc/IsTransparent = false
XXXXXXXX /Map/proc/IsDefault = true
XXXXXXXX /Map/proc/Border = none
XXXXXXXX /Map/proc/DropZone = true
XXXXXXXX /Map/proc/RightClick = false
/Map/proc/SavedParams = icon-size
XXXXXXXX /Map/proc/IconSize = 0
XXXXXXXX /Map/proc/TextMode = true
/Map/proc/OnShow =
/Map/proc/OnHide =


XXXXXXXX /Child/proc/Pos = 128,184
XXXXXXXX /Child/proc/Size = 200x200
XXXXXXXX /Child/proc/Anchor1 = none
XXXXXXXX /Child/proc/Anchor2 = none
XXXXXXXX /Child/proc/FontFamily = ""
XXXXXXXX /Child/proc/FontSize = 0
XXXXXXXX /Child/proc/FontStyle = ""
XXXXXXXX /Child/proc/TextColor = #000000
XXXXXXXX /Child/proc/BackgroundColor = none
XXXXXXXX /Child/proc/IsVisible = true
XXXXXXXX /Child/proc/IsDisabled = false
XXXXXXXX /Child/proc/IsTransparent = false
XXXXXXXX /Child/proc/IsDefault = false
XXXXXXXX /Child/proc/Border = none
XXXXXXXX /Child/proc/DropZone = false
XXXXXXXX /Child/proc/RightClick = false
/Child/proc/SavedParams = "splitter"
XXXXXXXX /Child/proc/Left = ""
XXXXXXXX /Child/proc/Right = ""
XXXXXXXX /Child/proc/IsVert = false
XXXXXXXX /Child/proc/Splitter = 50
XXXXXXXX /Child/proc/ShowSplitter = true
/Child/proc/Lock = none

*/