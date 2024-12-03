
#ifndef AT_NORTH
#define AT_NORTH	1
#endif
#ifndef AT_SOUTH
#define AT_SOUTH	2
#endif
#ifndef AT_EAST
#define AT_EAST		4
#endif
#ifndef AT_WEST
#define AT_WEST		8
#endif
#ifndef AT_NORTHEAST
#define AT_NORTHEAST 16
#endif
#ifndef AT_SOUTHEAST
#define AT_SOUTHEAST 32
#endif
#ifndef AT_SOUTHWEST
#define AT_SOUTHWEST 64
#endif
#ifndef AT_NORTHWEST
#define AT_NORTHWEST 128
#endif

#define AT_256		1
#define AT_47		2
#define AT_16		3
#define AT_WALL		4
#define AT_PILLAR	5

#ifndef AUTOTILE_FILL_RATE
#define AUTOTILE_FILL_RATE 1000
#endif

#ifndef AUTOTILE_CPU_LIMIT
#define AUTOTILE_CPU_LIMIT 90
#endif

#ifndef AUTOTILE_INITIALIZE

world/New()
	..()
	spawn(-1)
		autotile_block()

#endif

var
	autotile_registry/autotiles = new/autotile_registry()

autotile_registry
	var
		list/registry
	proc
		operator[](idx)
			if(isnull(idx))
				return registry[@"[]"]
			else if(islist(idx))
				return idx
			else if(istext(idx))
				try
					return registry[idx] ||= Process(json_decode(idx))
				catch(var/exception/e)
					world.log << "[e] on [e.file]:[e.line]"
					return registry[@"[]"]

		Process(list/json)
			. = list()
			for(var/tile_id in json)
				.[tile_id] = 1
			return .

	New()
		registry = list("\[]"=list())



proc/place_tile(turf/loc,type)
	new type(loc)

	var/global/list/at_order = list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST)
	var/global/list/at_dir = list(AT_NORTH,AT_NORTHEAST,AT_EAST,AT_SOUTHEAST,AT_SOUTH,AT_SOUTHWEST,AT_WEST,AT_NORTHWEST)
	var/global/list/at_inv = list(AT_SOUTH,AT_SOUTHWEST,AT_WEST,AT_NORTHWEST,AT_NORTH,AT_NORTHEAST,AT_EAST,AT_SOUTHEAST)

	var/turf/n, list/rule = autotiles[loc.autotile], id = loc.tile_id, turf/nf, nid, f = 0

	for(var/i in 1 to 8)
		n = get_step(loc,at_order[i])
		if(n)
			nf = n.tile_joins
			if(id && autotiles[n.autotile][id])
				nf |= at_inv[i]
			else
				nf &= ~at_inv[i]

			if(nf != n.tile_joins)
				n.tile_joins = nf
				n.JoinUpdate()

			if((nid = n.tile_id) && rule[nid])
				f |= at_dir[i]
		else if(rule["world"])
			f |= at_dir[i]

	loc.tile_joins = f
	loc.JoinUpdate()

	return loc

proc/autotile_block(x1=1,y1=1,z1=1,x2=world.maxx,y2=world.maxy,z2=world.maxz,fill_rate=AUTOTILE_FILL_RATE,cpu_limit=AUTOTILE_CPU_LIMIT)
	x1 = max(1,x1); y1 = max(1,y1); z1 = max(1,z1);
	x2 = min(x2,world.maxx); y2 = min(y2,world.maxy); z2 = min(z2,world.maxz);

	var/x, y, z, rate = 0, rule, nid, id, turf/n, wj, f
	var/mx = world.maxx, my = world.maxy

	for(z in z2 to z1 step -1)
		for(y in y2 to y1 step -1)
			for(x in x2 to x1 step -1)
				src = locate(x,y,z)

				rule = autotiles[src:autotile]
				id = src:tile_id
				wj = null

				f = src:tile_joins & (AT_NORTHWEST | AT_NORTH | AT_NORTHEAST | AT_EAST)
				if(y==my)
					if((wj ||= rule["world"]))
						f |= (AT_NORTH | AT_NORTHEAST | AT_NORTHWEST)
					else
						f &= ~(AT_NORTH | AT_NORTHEAST | AT_NORTHWEST)

				if(x==mx)
					if((wj ||= rule["world"]))
						f |= (AT_EAST | AT_NORTHEAST | AT_SOUTHEAST)
					else
						f &= ~(AT_EAST | AT_NORTHEAST | AT_SOUTHEAST)

				if((n = get_step(src,WEST)))
					if((nid = n.tile_id) && rule[nid])
						f |= AT_WEST
					if(id && autotiles[n.autotile][id])
						n.tile_joins |= AT_EAST
					else
						n.tile_joins &= ~AT_EAST
				else if((wj ||= rule["world"]))
					f |= AT_WEST
				else
					f &= ~AT_WEST

				if((n = get_step(src,SOUTHWEST)))
					if((nid = n.tile_id) && rule[nid])
						f |= AT_SOUTHWEST
					if(id && autotiles[n.autotile][id])
						n.tile_joins |= AT_NORTHEAST
					else
						n.tile_joins &= ~AT_NORTHEAST
				else if((wj ||= rule["world"]))
					f |= AT_SOUTHWEST
				else
					f &= ~AT_SOUTHWEST

				if((n = get_step(src,SOUTH)))
					if((nid = n.tile_id) && rule[nid])
						f |= AT_SOUTH
					if(id && autotiles[n.autotile][id])
						n.tile_joins |= AT_NORTH
					else
						n.tile_joins &= ~AT_NORTH

				else if((wj ||= rule["world"]))
					f |= AT_SOUTH
				else
					f &= ~AT_SOUTH

				if((n = get_step(src,SOUTHEAST)))
					if((nid = n.tile_id) && rule[nid])
						f |= AT_SOUTHEAST
					if(id && autotiles[n.autotile][id])
						n.tile_joins |= AT_NORTHWEST
					else
						n.tile_joins &= ~AT_NORTHWEST


				else if((wj ||= rule["world"]))
					f |= AT_SOUTHEAST
				else
					f &= ~AT_SOUTHEAST

				src:tile_joins = f
				if(src:autotile_type)
					src:JoinUpdate()

				if(world.tick_usage>=cpu_limit && ++rate > fill_rate)
					rate = 0
					sleep(world.tick_lag)

turf
	var
		tile_id = null
		tile_joins = 0
		autotile = null
		autotile_type
		indestructible=0

	proc
		JoinUpdate()
			switch(autotile_type)
				if(AT_256)
					icon_state = "[tile_joins]"

				if(AT_47)
					var/f = tile_joins

					var/d1 = f & AT_NORTH, d2 = f & AT_SOUTH, d3 = f & AT_EAST, d4 = f & AT_WEST
					if(f & AT_NORTHWEST && (!d1 || !d4))
						f &= ~AT_NORTHWEST
					if(f & AT_SOUTHWEST && (!d2 || !d4))
						f &= ~AT_SOUTHWEST
					if(f & AT_NORTHEAST && (!d1 || !d3))
						f &= ~AT_NORTHEAST
					if(f & AT_SOUTHEAST && (!d2 || !d3))
						f &= ~AT_SOUTHEAST

					icon_state = "[f]"

				if(AT_16)
					icon_state = "[tile_joins & (AT_NORTH | AT_SOUTH | AT_EAST | AT_WEST)]"

				if(AT_WALL)
					icon_state = "[tile_joins & (AT_EAST | AT_WEST)]"

				if(AT_PILLAR)
					icon_state = "[tile_joins & (AT_NORTH | AT_SOUTH)]"

#ifdef DEBUG

var
	list/__atlib_states = list(  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
						   21, 23, 29, 31, 38, 39, 46, 47, 55, 63, 74, 75, 78, 79, 95,110,
						  111,127,137,139,141,143,157,159,175,191,203,207,223,239,255)
	                     //  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  21  23  29  31  38  39  46  47  55  63  74  75  78  79  95 110 111 127 137 139 141 143 157 159 175 191 203 207 223 239 255
	list/__atlib_tl = list(  1,  7,  4,  7,  4,  7,  4,  7,  5,  3,  5,  3,  5,  3,  5,  3, 10,  7,  3,  3,  4,  7,  5,  3,  7,  3,  6,  3,  5,  3,  3,  5,  3,  3, 12,  9, 11,  8, 11,  8,  8,  8,  9,  8,  8,  8,  8)
	list/__atlib_tr = list(  1,  9,  6,  9,  5,  3,  5,  3,  6,  9,  6,  9,  5,  3,  5,  3, 10,  7,  8,  8,  4,  3,  5,  3,  7,  8,  6,  9,  5,  3,  8,  5,  3,  8, 12,  9,  3,  3, 11,  8,  3,  8,  9,  3,  8,  3,  8)
	list/__atlib_bl = list(  1, 10,  7,  7, 10, 10,  7,  7, 11, 11,  3,  3, 11, 11,  3,  3, 10,  7, 11,  3,  4,  7,  3,  3,  7,  3,  6,  8,  5,  8,  8,  5,  8,  8, 12,  3, 11,  3, 11,  3,  3,  3,  9,  8,  8,  8,  8)
	list/__atlib_br = list(  1, 12,  9,  9, 11, 11,  3,  3, 12, 12,  9,  9, 11, 11,  3,  3, 10,  3, 11,  3,  4,  7,  8,  8,  7,  8,  6,  9,  3,  3,  3,  5,  8,  8, 12,  9, 11,  3, 11,  3,  8,  8,  9,  3,  3,  8,  8)


client/verb
	GenAutotile(icon/i as icon)
		set hidden = 1, instant = 1

		if(world.host!=key&&world.address)
			return 0

		i = icon(i)
		var/icon/j = new(), icon/k
		var/ix,iy
		var/h = i.Height(), w = i.Width(), ih = floor(h/4), iw = floor(w/3), hw = iw/2, hh = ih/2
		var/count

		while(count<12)
			k = icon(i)
			ix = (count%3)*iw
			iy = h-(floor(count/3)+1)*ih
			k.Crop(ix+1,iy+1,ix+iw,iy+ih)
			j.Insert(k,"[++count]")

		var/icon/bli=new(j),icon/bri=new(j),icon/tli=new(j),icon/tri=new(j)
		bli.Crop(1,1,hw,hh)
		bli.Crop(1,1,iw,ih)
		bri.Crop(hw+1,1,iw,hh)
		bri.Crop(1-hw,1,hw,ih)
		tli.Crop(1,hh+1,hw,ih)
		tli.Crop(1,1-hh,iw,hh)
		tri.Crop(hw+1,hh+1,iw,ih)
		tri.Crop(1-hw,1-hh,hw,hh)

		var/list/bll = list(), list/brl = list(), list/tll = list(), list/trl = list()

		var/lbl
		for(count in 1 to 12)
			lbl = "[count]"
			bll += icon(bli,lbl)
			brl += icon(bri,lbl)
			tll += icon(tli,lbl)
			trl += icon(tri,lbl)

		bli = new(); bri = new(); tli = new(); tri = new()

		for(count in 1 to 47)
			lbl = "[__atlib_states[count]]"
			bli.Insert(bll[__atlib_bl[count]],lbl)
			bri.Insert(brl[__atlib_br[count]],lbl)
			tli.Insert(tll[__atlib_tl[count]],lbl)
			tri.Insert(trl[__atlib_tr[count]],lbl)

		bli.Blend(bri,ICON_OVERLAY)
		tli.Blend(tri,ICON_OVERLAY)
		bli.Blend(tli,ICON_OVERLAY)

		usr << ftp(bli)

#endif


turf
	Lgrass
		icon = 'lgrass.dmi'
		icon_state="255"
		autotile = @{"["lgrass","world"]"}
		tile_id = "lgrass"
		autotile_type=AT_47
	dgrass
		icon = 'dgrass.dmi'
		icon_state="255"
		autotile = @{"["dgrass","world"]"}
		tile_id = "dgrass"
		autotile_type=AT_47
	gravel
		icon = 'gravel.dmi'
		icon_state="255"
		autotile = @{"["gravel","world"]"}
		tile_id = "gravel"
		autotile_type=AT_47
	dirt
		icon = 'dirt.dmi'
		icon_state="255"
		autotile = @{"["dirt","world"]"}
		tile_id = "dirt"
		autotile_type=AT_47
	sand
		icon = 'sand.dmi'
		icon_state="255"
		autotile = @{"["sand","beach","world"]"}
		tile_id = "sand"
		autotile_type=AT_47
	water
		icon = 'water.dmi'
		icon_state="255"
		autotile = @{"["water","beach","world"]"}
		tile_id = "water"
		autotile_type=AT_47
	beach
		icon = 'sandwater.dmi'
		icon_state="0"
		autotile = @{"["sand","beach","world"]"}
		tile_id = "beach"
		autotile_type=AT_47

var/altered_turfs[0]
var/altered_objects[0]
obj/var/turf/old_loc

proc/save_turf(turf/T)
	if(!T || !isturf(T))return
	altered_turfs[T] ||= T.type


client/verb/RestoreEarth()
	for(var/turf/T in altered_turfs)
		place_tile(T,altered_turfs[T])
	altered_turfs=new/list()
	for(var/obj/o in altered_objects)
		if(o.old_loc)
			o.loc=o.old_loc
			o.density=1
			o.alpha=255
			altered_objects-=o

proc/destroy_turfs(pixloc/P,radius)
	for(var/turf/T in bounds(P,radius))
		if(T.indestructible)continue
		var/vector/v=T.pixloc-P
		if(v.size<=radius)
			for(var/obj/O in T)
				O.Destroy_Landscape()
			save_turf(T)
			place_tile(T,/turf/dirt)

obj/proc/Destroy_Landscape()
