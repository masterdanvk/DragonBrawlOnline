/*

  -- Map Instancing --

This library lets you create and manage copies of maps. While the game
is running you can create a duplicate instance of an existing map. The
library will automatically create additional z levels for these new
instances. When you're done using a map the library will re-use z levels
so you can conserve space.


  -- How to Use It --

The library comes with two demos, each is contained in its own sub-
folder. To run a demo, include all of the files in the sub-folder and
run the library. Some demos may have additional instructions, so check
the "demo.dm" file in the demo's folder.

To create a copy of a map you just have to do this:

	var/Map/map = maps.copy(2)

This creates a copy of the second z level. The copy is created on the
first available z level (or, if none are available, a new one is created).
The Map object is returned so you can manage the new map instance:

	mob.loc = locate(5, 3, map.z)

	map.repop()

	map.free()

The Map object has a "z" var which tells you what z level the map copy
was created on. This lets you move mobs to the new map. The object also
has some procs. The repop() proc creates new instances of objects to
replace deleted ones - it's like world.Repop() except it only repopulates
that one map instance. The free() proc tells the library that you're done
using the map, this way the library can use that z level again later.

*/
var
	Maps/maps = new()

atom
	var
		// this is used to determine if an object was
		// created as part of an instanced map or not.
		__instanced = 0

	proc
		// This is used to determine if an object should
		// be stored as part of a MapBase or not. You can
		// override it to make certain object types not
		// be instanced. By default, all objects are stored
		// except for mobs with clients.
		is_instanced()
			return 1

mob
	is_instanced()
		if(client)
			return 0
		else
			return 1

Maps
	var
		list/z = list()
		list/bases = list()
		list/file_bases = list()

	New()
		for(var/i = 1 to world.maxz)
			bases += 0

	proc
		load(filename)

			if(!fexists(filename))
				CRASH("The file '[filename]' does not exist.")

			var/savefile/f = new(filename)
			var/MapBase/base
			f >> base

			return base

		// create a MapBase for the z level (if we haven't already)
		// and create an instance of that base
		copy(map_z)

			// the argument to copy can be a z level or
			// a filename, if it's a filename we load the
			// MapBase from the file, then create an instance
			// of it
			if(istext(map_z))

				var/filename = map_z

				var/MapBase/base

				// if we've loaded it before, use the already-loaded one
				if(filename in file_bases)
					base = file_bases[filename]

				// otherwise we load it from disk
				else
					base = load(filename)

				// return a new instance of this base
				return base.make()

			var/MapBase/base = bases[map_z]

			// if we don't have a base for this z level, create one
			if(!base)
				base = new(map_z)
				bases[map_z] = base

			// create an instance of the base and return it
			return base.make()

		// makes a z level available for use
		clear(map_z)

			// if the z level is already available, do nothing
			if(map_z in z)
				return 0

			// otherwise, add it to the list of available z levels
			z += map_z
			return 1

		// return the next available z level, creating a new one if necessary
		__get_z()
			if(z.len == 0)
				world.maxz += 1
				return world.maxz
			else
				var/next_z = z[1]
				z -= next_z

				return next_z

MapBase
	var
		// the size of the base map
		maxx
		maxy

		// a 2D list of turf types
		list/turfs

		// a 2D list of area types for each turf
		list/areas

		// the list of objects placed on the map, for every
		// object three values are added to this list:
		//   the object's type path
		//   the object's x coordinate
		//   the object's y coordinate
		list/objects = list()

	New(z = -1)

		// if no z level was specified, do nothing
		if(z == -1)
			return

		// otherwise, a z level was specified so we extract data from that map

		// first we find the maxx and maxy for the z level
		for(var/x = 1 to world.maxx)
			var/turf/t = locate(x, 1, z)

			if(t)
				maxx = x
			else
				break

		for(var/y = 1 to world.maxy)
			var/turf/t = locate(1, y, z)

			if(t)
				maxy = y
			else
				break

		// then we create lists to determine the turf and area
		// type for each tile in the z level
		turfs = new(maxx, maxy)
		areas = new(maxx, maxy)

		for(var/x = 1 to maxx)
			for(var/y = 1 to maxy)
				var/turf/t = locate(x, y, z)
				turfs[x][y] = t.type

				var/area/area = t.loc
				areas[x][y] = area.type

				// Make this work with the Region library.
				#ifdef FA_REGION
				for(var/region/r in t.regions)
					objects += r.type
					objects += t.x
					objects += t.y
				#endif

				// we also keep a list of objects
				for(var/atom/a in t)
					if(a.is_instanced())
						objects += a.type
						objects += a.x
						objects += a.y

	proc
		save(filename)
			var/savefile/f = new(filename)
			f << src

		// create a new instance of this map and return
		// a /Map object that represents it.
		make(z = 0)

			var/Map/map

			// if the argument is a Map object, we use that
			if(istype(z, /Map))
				map = z

			// otherwise we create a new one.
			else
				map = new(src)

				// if we passed a z value to make(), use that
				if(z)
					map.z = z

				// otherwise, find an available z value
				else
					map.z = maps.__get_z()

			// set all turfs on the new map
			for(var/x = 1 to world.maxx)
				for(var/y = 1 to world.maxy)
					if(x > maxx || y > maxy)
						var/turf/t = locate(x, y, map.z)
						t.icon = null
					else
						// remove existing objects on the map
						var/turf/t = locate(x, y, map.z)
						for(var/atom/movable/m in t)
							if(m.__instanced)
								m.loc = null

						// set the turf's area
						var/area/a = locate(areas[x][y])
						a.contents += t

						// make a new turf of the appropriate type
						var/turf_type = turfs[x][y]
						new turf_type(t)

			// populate the map with objects
			for(var/i = 1 to objects.len / 3)
				var/obj_type = objects[i * 3 - 2]
				var/obj_x = objects[i * 3 - 1]
				var/obj_y = objects[i * 3 - 0]

				var/atom/a = new obj_type(locate(obj_x, obj_y, map.z))

				// This is mostly to make it work with the region library.
				// The /region objects delete themselves inside their
				// constructor, so we have to check if a is null here.
				if(a)
					a.__instanced = 1
					map.objects += a

			return map

// A /Map object is created to represent an instance
// of a map that you've made.
Map
	var
		// the z level this map copy is placed on
		z

		// a list of references to each object that was created
		// as part of this map instance, this is what lets us
		// be able to repop() an individual map instance.
		list/objects = list()

		// the /MapBase objec that was used to create this instance
		MapBase/base

	New(MapBase/b)

		if(!b)
			CRASH("The Map object's constructor must be passed a MapBase object.")

		base = b

	proc
		// make this map's z level available for other maps to use
		free()
			maps.z += z
			del src

		// repopulate the map with objects that were initially there,
		// but have since been deleted
		repop()
			for(var/i = 1 to objects.len)
				if(objects[i])
					continue

				var/obj_type = base.objects[i * 3 - 2]
				var/obj_x = base.objects[i * 3 - 1]
				var/obj_y = base.objects[i * 3 - 0]

				objects[i] = new obj_type(locate(obj_x, obj_y, z))

		reset()
			for(var/i = 1 to objects.len)
				del objects[i]

			objects.Cut()

			base.make(src)

		get(type_path)

			var/is_turf = derived_from(type_path, /turf)
			var/is_area = derived_from(type_path, /area)
			var/is_mob = derived_from(type_path, /atom/movable)

			var/list/L = list()

			if(is_mob)
				for(var/x = 1 to base.maxx)
					for(var/y = 1 to base.maxy)
						var/turf/t = locate(x, y, z)

						for(var/atom/movable/m in t)
							if(istype(m, type_path))
								L += m

			else if(is_turf)
				for(var/x = 1 to base.maxx)
					for(var/y = 1 to base.maxy)
						var/turf/t = locate(x, y, z)

						if(istype(t, type_path))
							L += t

			else if(is_area)
				for(var/x = 1 to base.maxx)
					for(var/y = 1 to base.maxy)
						var/turf/t = locate(x, y, z)
						var/area/a = t.loc

						if(istype(a, type_path))
							L += a

			return L

proc
	derived_from(child, parent)
		return (child in typesof(parent)) ? 1 : 0