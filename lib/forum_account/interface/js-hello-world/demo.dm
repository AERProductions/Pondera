
mob
	Login()
		src << browse({"
<html>
	<head>
		<!--
			Calling this proc will embed some JavaScript code in this
			page which is needed for the JS-to-DM calls to work.
		-->
		[JS2DM(src)]

		<script>

			function change_caption(c)
			{
				var link = document.getElementById("link");
				link.innerHTML = c;
			}

		</script>
	</head>
	<body>
		<!--
			We can call a DM proc from JavaScript just like we'd
			call it in DM, we can even pass it parameters.
		-->
		<a id="link" href="javascript:src.my_proc('Hello, world!', 3);">Click Me!</a>
	</body>
</html>"})

	proc
		// this proc is called from JavaScript.
		my_proc(message, number)
			world << number
			alert(src, message)
