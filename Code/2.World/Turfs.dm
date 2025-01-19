
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
turf
	Lgrass
		icon = 'lgrass.dmi'
		icon_state="255"
		autotile = @{"["lgrass","world","grasswater"]"}
		tile_id = "lgrass"
		autotile_type=AT_47
	dgrass
		icon = 'dgrass.dmi'
		icon_state="255"
		autotile = @{"["dgrass","world","grasswater"]"}
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
		autotile = @{"["water","beach","grasswater","world"]"}
		tile_id = "water"
		autotile_type=AT_47
		Entered(mob/A)
			if(istype(A,/mob)&&A.icon=='rpg/rpg.dmi'&&!A.flying)
				A.flying=1
				A.ostate=A.icon_state
				if("[A.ostate]F" in icon_states(A.icon))A.icon_state="[A.ostate]F"

				return 1
			..()
		Exited(mob/A)

			if(istype(A,/mob)&&A.icon=='rpg/rpg.dmi'&&A.flying &&!istype(A.loc,/turf/water))

				A.flying=0
				A.icon_state=A.ostate
				return 1

			..()
		grasswater
			icon = 'grasswater.dmi'
			icon_state="0"
			autotile = @{"["world","grasswater","grass","dgrass","sand","lgrass","beach"]"}
			tile_id = "grasswater"
			autotile_type=AT_47

		beach
			icon = 'sandwater.dmi'
			icon_state="0"
			autotile = @{"["sand","beach","world","grasswater","grass"]"}
			tile_id = "beach"
			autotile_type=AT_47
turf
	icon='turf.dmi'
	bouncy=2
	var/ground=1
	grass
		icon_state="grass"
		tile_id = "grass"

	bump
		density=1
		bouncy=10
		icon_state="bump"
	boundary
		density=0
		indestructible=1
		Cross(atom/A)
			if(istype(A,/mob))
				return 0
			else
				return 1

	blank
		indestructible=1
		sky
			ground=0
			Entered(mob/A)
				.=..()
				if(istype(A,/mob)&&A.flyinglevel<3)
					A.Gravity()




		ground

	dark
		density=1
		opacity=1
		indestructible=1

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
proc/Restore()
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
	if(!P||!radius)return
	for(var/turf/T in bounds(P,radius))
		if(T.indestructible)continue
		var/vector/v=T.pixloc-P
		if(v.size<=radius)
			for(var/obj/O in T)
				O.Destroy_Landscape()
			save_turf(T)
			place_tile(T,/turf/dirt)

obj/proc/Destroy_Landscape()


turf_overlays
	parent_type=/obj
	New()
		..()
		spawn(-1)
			var/turf/T=src.loc
			T.overlays+=src.appearance
			src.loc=null
	flowers
		icon='props1x1.dmi'
		flower1
			icon_state="flower1"
		flower2
			icon_state="flower2"
		flower3
			icon_state="flower3"
		flower4
			icon_state="flower4"
		flower5
			icon_state="flower5"
		flower6
			icon_state="flower6"
		flower7
			icon_state="flower7"
		flower8
			icon_state="flower8"
		flower9
			icon_state="flower9"
		flower10
			icon_state="flower10"
		flower11
			icon_state="flower11"
		flower12
			icon_state="flower12"
	rocks
		icon='props1x1.dmi'
		rock1
			icon_state="rock"
		rock2
			icon_state="rock2"
		rock3
			icon_state="rock3"
		rock4
			icon_state="rock4"
		rock5
			icon_state="rock5"
		rock6
			icon_state="rock6"
		rock7
			icon_state="rock7"
	grass
		icon='props1x1.dmi'
		grass1
			icon_state="grass1"
		grass2
			icon_state="grass2"
		grass3
			icon_state="grass3"
		grass4
			icon_state="grass4"
		grass5
			icon_state="grass5"
		grass6
			icon_state="grass6"
		grass7
			icon_state="grass7"
		grass8
			icon_state="grass8"
	leaf
		icon='props1x1.dmi'
		leaf1
			icon_state="leaf1"
		leaf2
			icon_state="leaf2"
		leaf3
			icon_state="leaf3"
		leaf4
			icon_state="leaf4"
		leaf5
			icon_state="leaf5"
		leaf6
			icon_state="leaf6"
		leaf7
			icon_state="leaf7"
	shrub
		icon='props1x1.dmi'
		icon_state="shrub"
	mushroom
		icon='props1x1.dmi'
		mushroom1
			icon_state="mush1"
		mushroom2
			icon_state="mush2"
		mushroom3
			icon_state="mush3"
	bramble
		icon='props1x1.dmi'
		bramble1
			icon_state="bramble1"
		bramble2
			icon_state="bramble2"
		bramble3
			icon_state="bramble3"