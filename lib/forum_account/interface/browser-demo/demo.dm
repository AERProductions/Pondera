
// This demo shows how you can easily integrate DM and JavaScript.

mob
	icon_state = "mob"

	var
		Browser/browser
		Map/map

	Login()

		// initialize the map and browser controls
		map = new(src, "window1.map")
		browser = new(src, "window1.browser")

		// show the HTML page in the browser
		browser.HTML(html())

		spawn(1)
			Move(locate(2,2,1))

	Move()
		. = ..()

		// We call a JavaScript function every time you move
		if(.)
			browser.JavaScript("update_loc", loc)

	proc
		// change your loc's icon_state
		build(new_state)
			loc:icon_state = new_state

			// we also need to update the browser display
			browser.JavaScript("update_loc", loc)

			// and restore focus to the map control.
			map.Focus(1)

		// This is the HTML that gets displayed in the browser control
		html()
			return {"
<html>
	<head>
		<style>
			/* we can easily change the CSS to change how the output is displayed */
			p, span
			{
				font-family: "Trebuchet MS";
				font-size: 10pt;

			}
			span
			{
				color: #55f;
				font-weight: bold;
			}

			img
			{
				border: 0;
			}
		</style>

		<!-- we need to put JS2DM in the header so that we can use calls to browser.JavaScript -->
		[JS2DM(src)]

		<script>

			function update_loc(turf)
			{
				// we can access the turf's variables just like we do in DM
				coords.innerHTML = turf.x + ", " + turf.y;
				tile.innerHTML = turf.icon_state;
			}

		</script>

	</head>
	<body>
		<p>
			<!-- display the player's coordinates -->
			My coordinates are <span id="coords">???</span>.<br/>

			<!-- display the type of tile the player is standing on -->
			I am standing on <span id="tile">???</span>.
		</p>
		<p>
			<!-- We use the browser.Cache() proc to cache images - it's return value is the filename of the cached resource. -->
			<a href="javascript:src.build('grass');"><img src="[browser.Cache('browser-demo-icons.dmi', "grass")]"/></a>
			<a href="javascript:src.build('floor');"><img src="[browser.Cache('browser-demo-icons.dmi', "floor")]"/></a>
			<a href="javascript:src.build('sidewalk');"><img src="[browser.Cache('browser-demo-icons.dmi', "sidewalk")]"/></a>
			<a href="javascript:src.build('pavement');"><img src="[browser.Cache('browser-demo-icons.dmi', "pavement")]"/></a>
		</p>
	</body>
</html>"}


// This is necessary for the demo but isn't part of the HTML/JavaScript stuff

world
	view = "21x13"
	cache_lifespan = 0

atom
	icon = 'browser-demo-icons.dmi'

turf
	icon_state = "grass"

	floor
		icon_state = "floor"

	sidewalk
		icon_state = "sidewalk"

	pavement
		icon_state = "pavement"

	brick
		density = 1
		icon_state = "brick"
