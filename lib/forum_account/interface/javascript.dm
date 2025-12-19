
#define DEBUG

// File:    javascript.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Contains the code used to handle the DM-JS interaction.
//   This has procs to generate JS code for calling DM procs,
//   procs for converting DM vars/objects to JS vars/objects
//   (and vice versa), and procs for calling JS functions from
//   DM procs.

proc
	is_associative(list/l)
		. = 0
		for(var/i in l)
			if(!isnum(i))
				if(!isnull(l[i]))
					return 1

	JSON(value, depth = 2)
		if(isnull(value))
			return "null"

		else if(ispath(value) || isicon(value) || isfile(value))
			return "'[value]'"

		else if(istype(value, /client))
			return value:json(depth - 1)

		else if(istype(value, /list))

			var/is_associative = is_associative(value)

			if(is_associative)
				// var/code = "(function(){var h={};"
				var/list/r = list()

				for(var/k in value)
					// code += "h\[[JSON(k)]]=[JSON(value[k])];"
					r += "[k]:[JSON(value[k])]"

				// return code + "return h;})();"
				return "{[concat(r, ",")]}"

			var/list/L = list()
			for(var/v in value)
				L += JSON(v)
			return "\[[concat(L, ",")]]"

		else if(istext(value))
			return "'[value]'"

		else if(isnum(value))
			return "[value]"

		else if(istype(value, /datum))
			if(depth > 0)
				return value:json(depth - 1)
			else
				// Set value:tag = null because we want to force the
				// internal ID to be used in case a tag was set.
				var/old_tag = value:tag
				value:tag = null
				. = "'\ref[value]'"
				value:tag = old_tag
				return .

		else if(copytext("[value]",1,2) == "/")
			return "'[value]'"

		else
			return "[value]"

// Convert a DM object to JSON.
datum
	proc
		json(depth = 1)

			if(depth < 1)
				var/old_tag = tag
				tag = null
				. = "'\ref[src]'"
				tag = old_tag
				return .

			var/json = "{"
			var/comma = 0
			for(var/v in vars)

				// vars is unnecessary, contents results in a lot of objects.
				if(isnull(vars[v]) || v == "vars" || v == "contents")

				// "class" is a reserved word in JavaScript, I need a workaround for this.
				else if(v == "class")
				else if(istype(vars[v],/list) && length(vars[v]) == 0)
				else
					if(comma) json += ","
					json += "[v]:[JSON(vars[v], depth - 1)]"
					comma = 1

			json += ",$objref:true,toString:function(){return\"\ref[src]\"}"

			for(var/p in src.procs())
				json += ",[p]:function(){call_proc('\ref[src]','[p]',arguments)}"

			json += "}"

			return json

	Topic(href, href_list[])
		. = ..()
		if("proc" in href_list)

			var/list/arg_list = list()

			if("args" in href_list)
				arg_list = split(href_list["args"], ",")

			var/proc_name = replace(href_list["proc"], "_", " ")
			call(src, proc_name)(arglist(arg_list))

			return 1

		return 0

client
	proc
		// same as the datum -> JSON conversion, we have to define
		// it again because clients aren't derived from /datum.
		json(depth = 1)
			if(depth < 1)
				var/old_tag = tag
				tag = null
				. = "'\ref[src]'"
				tag = old_tag
				return .

			var/json = "{"
			var/comma = 0
			for(var/v in vars)

				// vars is unnecessary, contents results in a lot of objects.
				if(isnull(vars[v]) || v == "vars" || v == "contents")

				// reserved words in JavaScript, I need a workaround for this.
				else if(v == "class")
				else if(istype(vars[v],/list) && length(vars[v]) == 0)
				else
					if(comma) json += ","
					json += "[v]:[JSON(vars[v], depth - 1)]"
					comma = 1

			json += ",$objref:true,toString:function(){return\"\ref[src]\"}"

			// for(var/p in src.procs()) json += ",[p]:function(){call_proc('\ref[src]','[p]',arguments)}"

			json += "}"

			return json

proc
	parse_value(v)
		var/prefix = copytext(v,1,2)
		var/value = copytext(v,2)

		// these prefixes were assigned in JavaScript when
		// the DM call was made.
		if(prefix == "n")
			value = text2num(value)
		else if(prefix == "l")
			value = parse_list("l" + value)
		else if(prefix == "r")
			var/o = locate(value)
			if(o)
				value = o
		else if(prefix == "h")
			value = parse_list("h" + value)

		return value

	parse_list(v)
		var/__list_parser/p = new(v)
		return p.parse()

client
	Topic(href, href_list[])

		if("js_error" in href_list)
			CRASH("JavaScript Error: [href_list["name"]]: [href_list["message"]]\n")

		. = ..()

		if(.) return 1

		var/list/arg_list = list()

		if("args" in href_list)
			arg_list = split(href_list["args"], "|")

			for(var/i = 1 to arg_list.len)
				arg_list[i] = parse_value(arg_list[i])

		if("proc" in href_list)
			var/proc_name = replace(href_list["proc"], "_", " ")

			if("world" in href_list)
				call(proc_name)(arglist(arg_list))
			else
				call(mob, proc_name)(arglist(arg_list))


proc
	BROWSER_UPDATE_SCRIPT(mob/src)
		return JS2DM(src)

	JS2DM(mob/src)

		var/world_obj = "{"
		for(var/t in typesof("/proc"))
			var/list/parts = split("[t]", "/")

			var/p = parts[parts.len]

			if(length(world_obj) > 2)
				world_obj += ","

			// for some reason you can't pass the arguments array as
			// an argument to call_proc, so we make a copy of it first.
			world_obj += "[p]:function(){var a=\[];for(var i=0;i<arguments.length;i++){a\[i]=arguments\[i];}call_proc('world','[p]',a)}"

		world_obj += "}"

		var/src_obj = "{"

		if(src)
			for(var/t in typesof("[src.type]/proc"))
				var/list/parts = split("[t]", "/")

				var/p = parts[parts.len]

				if(length(src_obj) > 2)
					src_obj += ","

				// for some reason you can't pass the arguments array as
				// an argument to call_proc, so we make a copy of it first.
				src_obj += "[p]:function(){var a=\[];for(var i=0;i<arguments.length;i++){a\[i]=arguments\[i];}call_proc('client','[p]',a)}"

		src_obj += "}"

		. = {"
<script>

	var world = [world_obj];
	var src = [src_obj];

	// this is called when a JavaScript function is called from DM
	function browser_update(params)
	{
		try
		{
			eval(params);
		}
		catch(e)
		{
			location = "?js_error&name=" + e.name + "&message=" + e.message;
		}
	}

	// I need to make an Object.prototype.toString function
	Object.prototype.toString = function()
	{
		var output = "h{";
		var comma = "";

		for(var k in this)
		{
			output += comma + k + ":" + encode_var(this\[k]);
			comma = ",";
		}

		output += '}';

		document.getElementById("output").innerHTML = output;

		return output;
	};

	// This is used to convert JavaScript arrays to a DM-parsable syntax.
	Array.prototype.$is_array = true;
	Array.prototype.toDMString = function()
	{
		var a = \[];
		for(var i = 0; i < this.length; i++)
		{
			a\[i] = encode_var(this\[i]);
		}
		return "\[" + a.join(",") + "]";
	};

	// Every value is passed to DM as a string. We give each variable
	// a prefix so we know how to parse it. Without this, we'd have no
	// way to tell if "\[0x00000001]" is a string or an object reference.
	function encode_var(v)
	{
		if(typeof(v) == "number")
			return "n" + v;
		else if(v.$is_array)
			return "l\" + v.toDMString();
		else if(typeof(v) == "object")
			if(v.$objref)
				return "r" + v;
			else
				return "" + v;
		else
			return "s" + v;
	}

	// this is used internally to call a DM proc
	function call_proc(src,proc,args)
	{
		if(args === undefined) args = \[];

		var arg_str = "";
		for(var i = 0; i < args.length; i++)
		{
			if(arg_str != "")
				arg_str += "|";

			arg_str += encode_var(args\[i]);
		}

		if(arg_str != "")
			arg_str = "&args=" + arg_str;

		if(src == "src")
			setTimeout(function(){location = "?proc=" + proc + arg_str;}, 0);
		else if(src == "world")
			setTimeout(function(){location = "?world=1&proc=" + proc + arg_str;}, 0);
		else
			setTimeout(function(){location = "?src=\ref" + src + "&proc=" + proc + arg_str;}, 0);
	}

</script>"}

mob
	proc
		// This function creates JavaScript code that is a function call to
		// js_func with the specified parameters. This is packed into a string
		// and passed to the borwser_update JavaScript function (which is
		// defined by the JS2DM proc) which evaluates the parameter - which is
		// code that calls js_func.
		call_JavaScript(browser_ctl, js_func, list/parameters)
			ASSERT(args.len >= 2)
			ASSERT(istext(browser_ctl))
			ASSERT(istext(js_func))

			var/list/params = list()

			for(var/a in parameters)
				params += JSON(a)

			var/param_str = merge(params, ",")
			var/func_str = "[js_func]([param_str]);"

			// world << func_str
			src << output(func_str, "[browser_ctl]:browser_update")
