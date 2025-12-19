
// File:    icons.dm
// Library: Forum_account.HandyStuff
// Author:  Forum_account
//
// Contents:
//   This file creates the Icon namespace which contains procs
//   to manipulate DM's /icon objects. The included procs are:
//
//       Icon.Fade(icon, [state], alpha)
//       Icon.Rotate(icon, [state], angle)
//       Icon.GetPixel(icon, x, y)
//
//   The "icon" parameter can be an icon file or an instance of
//   the /icon object. For Fade and Rotate, the "state" parameter
//   can be left out so you just specify an icon and an alpha/angle
//   and the change will be applied to all icon states.

var
	const
		NONE = 0
		LINEAR = 1
		COSINE = 2

	INTERPOLATION_MODE = LINEAR

var
	Icon_namespace/Icon = new /Icon_namespace()


// The icon procs could use some work. They don't support directional or animated icons.

Icon_namespace
	proc
		Fade(icon_file, state_name = "", alpha)

			var/list/to_transform = list()
			var/single_state = 0

			if(istext(state_name))
				to_transform[state_name] = icon(icon_file, state_name)
				single_state = 1
			else
				alpha = state_name

				for(state_name in icon_states(icon_file))
					to_transform[state_name] = icon(icon_file, state_name)

			var/icon/master = new()

			for(state_name in to_transform)
				var/icon/i = to_transform[state_name]
				var/icon/I = new('blank.dmi',"blank")
				I.Scale(i.Width(), i.Height())

				for(var/x = 1 to i.Width())
					for(var/y = 1 to i.Height())
						var/Color/col = GetPixel(i,x,y)
						col.alpha *= alpha
						I.DrawBox(col.RGB(), x, y)

				if(single_state)
					master.Insert(I)
				else
					master.Insert(I,state_name)

			return master

		Rotate(icon_file, state_name = "", theta = 0)

			var/list/to_transform = list()
			var/single_state = 0

			if(istext(state_name))
				to_transform[state_name] = icon(icon_file, state_name)
				single_state = 1
			else
				theta = state_name

				for(state_name in icon_states(icon_file))
					to_transform[state_name] = icon(icon_file, state_name)

			var/icon/master = new()

			for(state_name in to_transform)
				var/icon/i = to_transform[state_name]
				var/icon/I = new('blank.dmi',"blank")
				I.Scale(i.Width(), i.Height())

				var/center_x = (1 + i.Width()) / 2
				var/center_y = (1 + i.Height()) / 2

				for(var/x = 1 to i.Width())
					for(var/y = 1 to i.Height())
						var/ix = x - center_x
						var/iy = y - center_y

						var/rx = ix * cos(theta) - iy * sin(theta)
						var/ry = ix * sin(theta) + iy * cos(theta)

						rx = rx + center_x
						ry = ry + center_y

						var/u = rx - round(rx)
						var/v = ry - round(ry)

						rx = round(rx)
						ry = round(ry)

						var/Color/a = GetPixel(i,rx,ry)
						var/Color/b = GetPixel(i,rx+1,ry)
						var/Color/c = GetPixel(i,rx+1,ry+1)
						var/Color/d = GetPixel(i,rx,ry+1)

						var/Color/result = _interpolate(a,b,c,d,u,v)

						I.DrawBox(result.RGB(), x, y)

				if(single_state)
					master.Insert(I)
				else
					master.Insert(I,state_name)

			return master

		GetPixel(icon/I, x, y)
			if(x > I.Width() || x < 1 || y > I.Height() || y < 1)
				return new /Color(0,0,0,0)

			return new /Color(I.GetPixel(x,y))


		_interpolate(Color/a, Color/b, Color/c, Color/d, u, v)

			if(INTERPOLATION_MODE == LINEAR)
				return _bilinear_interpolate(a,b,c,d,u,v)
			else if(INTERPOLATION_MODE == COSINE)
				u = cos(180 * u) * -0.5 + 0.5
				v = cos(180 * v) * -0.5 + 0.5
				return _bilinear_interpolate(a,b,c,d,u,v)
			else
				return _nearest_neighbor(a,b,c,d,u,v)

		_nearest_neighbor(Color/a, Color/b, Color/c, Color/d, u, v)
			if(u < 0.5)
				if(v < 0.5)
					return a
				else
					return b
			else
				if(v < 0.5)
					return d
				else
					return c

		_bilinear_interpolate(Color/a, Color/b, Color/c, Color/d, u, v)

			var/rs = 0
			var/gs = 0
			var/bs = 0
			var/ts = 0
			var/count = 0

			if(a.alpha > 0)
				rs += a.red   * (1 - u) * (1 - v)
				gs += a.green * (1 - u) * (1 - v)
				bs += a.blue  * (1 - u) * (1 - v)
				count += 1

			if(b.alpha > 0)
				rs += b.red   * (u) * (1 - v)
				gs += b.green * (u) * (1 - v)
				bs += b.blue  * (u) * (1 - v)
				count += 1

			if(c.alpha > 0)
				rs += c.red   * (u) * (v)
				gs += c.green * (u) * (v)
				bs += c.blue  * (u) * (v)
				count += 1

			if(d.alpha > 0)
				rs += d.red   * (1 - u) * (v)
				gs += d.green * (1 - u) * (v)
				bs += d.blue  * (1 - u) * (v)
				count += 1

			ts += a.alpha * (1 - u) * (1 - v)
			ts += b.alpha * (u) * (1 - v)
			ts += c.alpha * (u) * (v)
			ts += d.alpha * (1 - u) * (v)

			return new /Color(rs, gs, bs, ts)
