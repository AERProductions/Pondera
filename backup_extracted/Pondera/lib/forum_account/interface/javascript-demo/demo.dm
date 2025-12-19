
mob
	var
		Browser/browser

	proc
		from_js(mob/m, num, text, list/array, list/hashtable)
			// show that the object reference passed back from JavaScript
			// is actually the right mob:
			world << m.key

			// show that the number passed from JavaScript is treated as a
			// number (not a string):
			world << "[num] + 1 = [num + 1]"

			// show that the string passed from JavaScript is treated as a string:
			world << copytext(text, 2)

			// show that the array passed from JavaScript is treated as a DM list:
			for(var/a in array)
				world << "[a] \c"
			world << ""

			// show the key-value pairs in the hashtable
			for(var/k in hashtable)
				world << "[k] = [hashtable[k]]"

	verb
		Test_DM_to_JavaScript()
			// This calls a JS function that displays this data in the browser.
			// This shows that the values get passed correctly to JS, whether
			// they're strings, numbers, objects, or lists.
			var/list/associative = list("a" = 123, "test" = "5")

			browser.JavaScript("dm_to_js", src, client, 74, "some text", list(1, 2, 3, 4), associative)

		Test_JavaScript_to_DM()
			// This calls a JS function that calls the mob's from_js proc.
			// The argument, src, is passed to JavaScript then back to DM.
			browser.JavaScript("js_to_dm", src)

	Login()
		..()

		browser = new(src, "window", "browser")
		browser.HTML({"
<html>
	<head>
		<script>

			function js_to_dm(mob)
			{
				// We immediately invoke a DM function and should
				// see output in the DM output log.
				src.from_js(mob, 3, "abc", \[1, 2, 3], {cat: 5, dog: 3});
			}

			function dm_to_js(mob, client, num, text, list, hashtable)
			{
				var div = document.getElementById("output");

				// show that DM objects are passed as JS objects whose
				// properties can be accessed.
				div.innerHTML  = mob.key + "<br/>";
				div.innerHTML += client.type + "<br/>";

				// show that numbers are parsed as numbers
				div.innerHTML += num + " + 1 = " + (num + 1) + "<br/>";

				// show that the text string is passed as text
				div.innerHTML += text + ", " + text.substring(5) + "<br/>";

				// show that the list is a JavaScript array
				div.innerHTML += list.join(", ") + "<br/>";

				// show that the value contained in the hashtable is a number
				div.innerHTML += hashtable\["a"] + " + 1 = " + (hashtable\["a"] + 1);
			}

		</script>
	</head>
	<body>
		<div id="output"></div>
	</body>
</html>"})
