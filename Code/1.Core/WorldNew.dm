/*
the New() server initiating proc is kept here, largely used to create common shared objects and initiate stages and global lists.
Autotiling is also initiated here, which is the important autotiling proc for turfs that are autotiling enabled handled by the Libary - TerAutojoin.dm
*/

world/New()
	..()
	banner=new/obj
	banner.icon='DBO Logo.png'
	banner.screen_loc="CENTER:-192,TOP:-16"
	Victory=new/obj
	Victory.plane=99
	Victory.screen_loc="CENTER:-192,TOP:-48"
	Victory.icon='Victory.png'
	Defeat=new/obj
	Defeat.plane=99
	Defeat.screen_loc="CENTER:-192,TOP:-48"
	Defeat.icon='Defeat.png'

//	banner.filters+=filter(type="outline",color="white")
	stagezs=new/alist()
	stageobjs=new/list
	stageobjs.len=world.maxz
	var/list/Lvls=typesof(/obj/gui/levelselect)
	for(var/L in Lvls)
		levels+=new L

	spawn(30)
		for(var/obj/stagetag/O in world)
			stagezs[O.name]=O.z
			stageobjs[O.z]=O
	spawn()
		for(var/mob/M in world)
			if(M.z==1 && !M.client)M.npcrespawn=1
	FX=new/alist
	controls=new/obj
	controls.icon='controls.png'
	controls.layer=FLOAT_LAYER
	controls.plane = FLOAT_PLANE
	controls.screen_loc="CENTER-6:+32,BOTTOM+1"
	InitiateChunks()
	spawn(-1)
		autotile_block()