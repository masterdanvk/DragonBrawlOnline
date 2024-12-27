client/verb/VisitOverworld()
	src.edge_limit = null
	src.mob.oicon=src.mob.icon
	src.mob.omaxspeed=src.mob.maxspeed
	src.mob.icon='rpg/rpg.dmi'
	src.mob.movevector=vector(0,0)
	switch(src.mob.type)
		if(/mob/goku)src.mob.icon_state="goku"
		if(/mob/vegeta)src.mob.icon_state="vegeta2"
		if(/mob/trunks)src.mob.icon_state="trunks"
		if(/mob/nappa)src.mob.icon_state="nappa"
		if(/mob/raditz)src.mob.icon_state="raditz"
		if(/mob/yamcha)src.mob.icon_state="yamcha"
		if(/mob/tien)src.mob.icon_state="tien"
		if(/mob/piccolo)src.mob.icon_state="piccolo"
		if(/mob/gohan)src.mob.icon_state="gohan"
		if(/mob/saibamen)src.mob.icon_state="saibamen"
		if(/mob/cell)src.mob.icon_state="cell"
		if(/mob/celljr)src.mob.icon_state="celljr"
		if(/mob/chaotzu)src.mob.icon_state="chaiotzu"

	//src.mob.icon_state=input(src,"Who do you want to be","Character") in list("goku","vegeta","trunks","nappa","raditz","yamcha","tien","piccolo","gohan","saibamen","cell","celljr")
	src.mob.transform=null
	if(!src.oworldpixloc)src.mob.loc=locate(/obj/overworldstart)
	else
		src.mob.loc=src.oworldpixloc
	src.overworld=1
	src.mob.maxspeed=4
	for(var/obj/nameplate/N in src.mob.vis_contents)
		N.maptext_x=-16


client/proc/LeaveOverworld()
	src.overworld=0
	src.oworldpixloc=src.mob.pixloc
	src.mob.icon=src.mob.oicon
	src.mob.maxspeed=src.mob.omaxspeed
	src.mob.icon_state=""
	for(var/obj/nameplate/N in src.mob.vis_contents)
		N.maptext_x=4

obj/overworldstart
client/var/overworld=0
client/var/pixloc/oworldpixloc
mob/var
	flying=0
	ostate=""
	oicon
	omaxspeed

obj
	overworld
		proc/Activate(mob/M)
		krillin_training
			icon='rpg/rpg.dmi'
			icon_state="krillin"
			bound_width=8
			bound_height=12
			bound_x=32
			bound_y=16
			density=1
			Activate(mob/M)
				M.client?.LeaveOverworld()
				Fight(M,new/mob/krillin,stagezs["Kamehouse"],1)

		kamehouse
			icon='rpg/overworldlocs.dmi'
			icon_state="kamehouse"
			density=1
			bound_width=41
			bound_height=62
			bound_x=16
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Kamehouse"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Kamehouse"])
				M.client?.edge_limit = stage.dimensions
