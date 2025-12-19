/*
    nq_chunk: Allows you to save portions of map files on file for later reuse.
    Copyright (C) 2015  NullQuery (http://www.byond.com/members/NullQuery)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef NQ_CHUNK_TILES_PER_TICK
#define NQ_CHUNK_TILES_PER_TICK 64
#endif

/var/nq_chunk_global/nq_chunk					= new/nq_chunk_global();

/nq_chunk_global
{
	var
		const
			SEP_TURF							= "_<nq_chunk_turf>_";
			SEP_REF								= "_<nq_chunk_ref>_";
	proc
		LoadFromFile(filename, x1, y1, z1)
		{
			var/zipfile/zipfile					= new/zipfile(filename);

			zipfile.Export("[filename].tmp", "map.dat");

			var/savefile/savefile				= new/savefile("[filename].tmp");

			var/exception;

			try
			{
				var/maxx						= savefile["/maxx"];
				var/maxy						= savefile["/maxy"];
				var/maxz						= savefile["/maxz"];

				ASSERT(maxx > 0 && maxy > 0 && maxz > 0);

				var/nq_chunk/chunk				= new/nq_chunk(x1, y1, z1, x1 + maxx - 1, y1 + maxy - 1, z1 + maxz - 1);
				var/nq_chunk_reader/reader		= new/nq_chunk_reader(savefile);
				var/x = 1, y = 1, z = 1, i = 1;

				for (var/turf/turf in chunk.turfs)
				{
					savefile.cd					= "/turfs/[z]/[y]/[x]";

					reader.ReadTurf(turf);

					if (++x > maxx)
					{
						x						= 1;

						if (++y > maxy)
						{
							y					= 1;

							if (++z > maxz)		{ break }
						}
					}

					sleep ((++i % NQ_CHUNK_TILES_PER_TICK == 25) ? 1 : 0);
				}
			}
			catch (var/ex)						{ exception = ex }

			del savefile

			fdel("[filename].tmp")

			if (exception)						{ throw(exception); }
		}

		GetSavedVars(atom/atom)
		{
			var/list/L							= new/list();

			for (var/v in src.vars)
			{
				if (IsSaved(atom, v))			{ L.Add(atom.vars[v]); }
			}

			return L;
		}

		GetUniqueHash(object)
		{
			if		(istype(object, /atom))
			{
				var/atom/atom					= object;
				.								= md5("[atom.type]");

				for (var/value in nq_chunk.GetSavedVars(atom))
				{
					.							= md5(. + GetUniqueHash(value))
				}
			}
			else if (istype(object, /list))
			{
				.								= md5("/list(" + length(object) + ")");

				for (var/value in object)
				{
					.							= md5(. + GetUniqueHash(value));
				}
			}
			else if (isnum(object))				{ . = md5("/_builtin_/number_[object]"); }
			else if (istext(object))			{ . = md5("/_builtin_/text_[object]"); }
			else								{ . = md5("/_builtin_/undefined_[object]"); }

			return .;
		}

		IsSaved(atom/atom, v)
		{
			if (v != "contents" && v != "loc" && issaved(atom.vars[v]) && initial(atom.vars[v]) != atom.vars[v])
			{
				if ((v != "overlays" && v != "underlays") || length(atom.vars[v]) > 0)
				{
					return TRUE;
				}
			}

			return FALSE;
		}

		GetType(type)
		{
			// TODO: Add a method for replacing types from older savefile versions.
			return text2path(type);
		}
}

/nq_chunk_reader
{
	var
		list/objects							= new/list();
		savefile/savefile;

	New(savefile/savefile)
	{
		. = ..();

		src.savefile							= savefile;
	}

	proc
		LoadObject(ref)
		{
			if (ref in objects)					{ return objects[ref]; }
			else
			{
				var/path						= savefile.cd;

				savefile.cd						= "/objects";

				if (ref in savefile.dir)
				{
					savefile.cd					= "/objects/[ref]";

					var/type					= nq_chunk.GetType(savefile["type"]);
					var/atom/atom				= new type();

					ReadVars(atom);

					.							= atom;
				}

				objects[ref]					= .;

				savefile.cd						= path;

				return .;
			}
		}

		ReadVars(atom/atom)
		{
			var/temp,x,y,z,pos,pos2;

			for (var/v in savefile.dir)
			{
				if (v != "type" && v != "contents")
				{
					try
					{
						if (istext(savefile[v]))
						{
							if (findtext(savefile[v], "[nq_chunk.SEP_TURF]"))
							{
								temp			= copytext(savefile[v], length(nq_chunk.SEP_TURF) + 1);

								pos				= findtext(temp, ",");
								pos2			= findtext(temp, ",", pos + 1);

								ASSERT(pos);
								ASSERT(pos2);

								x				= text2num(copytext(temp, 1, pos));
								y				= text2num(copytext(temp, pos + 1, pos2));
								z				= text2num(copytext(temp, pos2 + 1));

								ASSERT(x);
								ASSERT(y);
								ASSERT(z);

								atom.vars[v]	= locate(x, y, z); // assumes that the turf is never deleted as a reference

								continue;
							}
							else if (findtext(savefile[v], "[nq_chunk.SEP_REF]"))
							{
								temp			= copytext(savefile[v], length(nq_chunk.SEP_REF) + 1);

								atom.vars[v]	= LoadObject(temp);

								continue;
							}
						}

						atom.vars[v]			= savefile[v];
					}
					catch (var/ex)				{ world.log << ex; } // TODO: nq_log??
				}
			}

			var/list/contents;

			savefile["contents"] >> contents;

			if (contents && contents.len > 0)
			{
				var/atom/movable/a;

				for (var/hash in contents)
				{
					try
					{
						a						= LoadObject(hash);

						if (a)					{ a.loc = atom; }
					}
					catch (var/ex)				{ world.log << ex; } // TODO: nq_log??
				}
			}
		}

		ReadTurf(turf/turf)
		{
			try
			{
				var/type						= nq_chunk.GetType(savefile["type"]);

				turf							= new type(turf);

				ReadVars(turf);
			}
			catch (var/ex)						{ world.log << ex; } // TODO: nq_log??
		}
}

/nq_chunk
{
	parent_type									= /datum;

	var
		x1;
		y1;
		z1;
		x2;
		y2;
		z2;

		maxx;
		maxy;
		maxz;
		list/turfs;

	New(x1, y1, z1, x2, y2, z2)
	{
		src.x1									= x1;
		src.y1									= y1;
		src.z1									= z1;
		src.x2									= x2;
		src.y2									= y2;
		src.z2									= z2;
		src.maxx								= x2 - x1 + 1;
		src.maxy								= y2 - y1 + 1;
		src.maxz								= z2 - z1 + 1;
		src.turfs								= block(locate(x1, y1, z1), locate(x2, y2, z2));
	}

	proc
		WriteAtomObject(atom/atom, atom/parent, savefile/savefile, variable)
		{
			var/path							= savefile.cd;
			savefile.cd							= "/objects";
			var/hash							= nq_chunk.GetUniqueHash(atom);

			ASSERT (hash != "");

			if (!(hash in savefile.dir))
			{
				savefile.cd		= "/objects/[hash]";

				try								{ WriteAtom(atom, savefile); }
				catch (var/exception/ex)
				{
					if (istype(ex) && findtext(ex.name, "contains a reference to"))
					{
						throw EXCEPTION("Object \ref[parent]'s [variable] variable (\ref[atom])) [copytext(ex.name, findtext(ex.name, "contains a reference to"))]");
					}
				}
			}

			savefile.cd							= path;

			return hash;
		}

		WriteAtom(atom/atom, savefile/savefile)
		{
			var/cont							= TRUE;
			var/path							= savefile.cd;
			var/temp;

			if (ismob(atom))
			{
				var/mob/mob						= atom;

				if (mob.ckey)					{ cont = FALSE; }
			}

			if (istype(atom, /atom))
			{
				var/turf/t						= atom;

				while (t && !istype(t))			{ t = t.loc; }

				if (t && !(t in src.turfs))		{ throw EXCEPTION("Object \ref[atom] contains a reference to turf [t.x],[t.y],[t.z], but it doesn't exist in this chunk.") }
			}

			if (cont)
			{
				var/turf/t

				for (var/v in atom.vars)
				{
					if (nq_chunk.IsSaved(atom, v))
					{
						if (istype(atom.vars[v], /atom))
						{
							if (isturf(atom.vars[v]))
							{
								t				= atom.vars[v];

								if (t in turfs)	{ savefile[v] << "[nq_chunk.SEP_TURF][t.x - x1 + 1],[t.y - y1 + 1],[t.z - z1 + 1]"; }
								else			{ throw EXCEPTION("Object \ref[atom]'s [v] variable contains a reference to turf [t.x],[t.y],[t.z], but it doesn't exist in this chunk."); }
							}
							else
							{
								temp			= WriteAtomObject(atom.vars[v], atom, savefile, v);

								ASSERT(temp != "");

								savefile[v] << "[nq_chunk.SEP_REF][temp]";
							}
						}
						else					{ savefile[v] << atom.vars[v]; }
					}
				}

				savefile["type"] << "[atom.type]";

				var/list/contents				= new/list();
				var/mob/m

				for (var/atom/a in atom.contents)
				{
					if (ismob(a))
					{
						m						= a;

						if (m.ckey)				{ continue; }
					}

					temp						= WriteAtomObject(a, atom, savefile, "contents");

					ASSERT(temp != "");

					contents.Add(temp);
				}

				if (contents.len)
				{
					savefile["[path]/contents"] << contents;
				}
			}
		}

		WriteToFile(filename)
		{
			var/exception;

			try
			{
				fdel("[filename].tmp");

				var/savefile/savefile			= new/savefile("[filename].tmp");

				var/x = 1, y = 1, z = 1, i = 1;

				savefile["/maxx"] << src.maxx;
				savefile["/maxy"] << src.maxy;
				savefile["/maxz"] << src.maxz;

				for (var/turf/turf in src.turfs)
				{
					savefile.cd					= "/turfs/[z]/[y]/[x]";

					src.WriteAtom(turf, savefile);

					if (++x > src.maxx)
					{
						x						= 1;

						if (++y > src.maxy)
						{
							y					= 1;

							if (++z > src.maxz)	{ break; }
						}
					}

					sleep ((++i % NQ_CHUNK_TILES_PER_TICK == 25) ? 1 : 0);
				}

				del savefile

				fdel(filename);

				var/zipfile/zipfile				= new(filename);

				zipfile.Import("[filename].tmp", "//map.dat")

				zipfile.Close()
			}
			catch (var/ex)						{ exception = ex }

			fdel("[filename].tmp")

			if (exception)						{ throw(exception) }
		}
}

#undef NQ_CHUNK_TILES_PER_TICK
