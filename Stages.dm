obj
	stagetag
		var
			vector/Start=vector(16,2)
			dimensions = "1,1 to 65,24"
			guistate

		Budokai
			name="Budokai"
			dimensions = "1,1 to 33,22"
			guistate="budokai"
		Raditz
			name="Raditz"
			dimensions = "1,1 to 39,22"
			guistate="raditz"
		Plains
			name="Plains"
			dimensions = "1,1 to 29,22"
			guistate="plains"
		Rockydesert
			name="Rockydesert"
			dimensions = "1,1 to 40,22"
			guistate="rockydesert"
		Plateaus
			name="Plateaus"
			dimensions = "1,1 to 40,22"
			guistate="vegeta"
		City
			name="City"
			dimensions = "1,1 to 60,22"
			guistate="city"
		Roadside
			name="Roadside"
			dimensions = "1,1 to 40,22"
			guistate="roadside"
		Mountain
			name="Mountain"
			dimensions = "1,1 to 37,21"
			guistate="mountains"
		Kamehouse
			name="Kamehouse"
			dimensions = "1,1 to 25,22"
			guistate="kamehouse"
			Start=vector(13,2)
		Lookout
			name="Lookout"
			dimensions = "1,1 to 24,22"
			guistate="lookout"
		Namek
			name="Namek"
			dimensions = "1,1 to 24,22"
			guistate="namek"
		Cellgames
			name="Cellgames"
			dimensions ="1,1 to 37,22"
			guistate="cellgames"

client/var/tmp/levelpick
client/var/tmp/pickinglevel=0
obj/gui/var
	gridX
	gridY
	image/overimage
var
	levelmaxX=0
	levelmaxY=0

obj/gui/levelselect
	icon='stages.dmi'
	background
		icon='gui/levelselect.png'
		screen_loc="CENTER-6:-17,CENTER-4:-8"
		mouse_opacity=0
		Click()
			return

	vegeta
		gridX=1
		gridY=3
		icon_state="vegeta"
		screen_loc="CENTER-6:-8,CENTER+2:-12"
	raditz
		gridX=2
		gridY=3
		icon_state="raditz"
		screen_loc="CENTER-3:-4,CENTER+2:-12"
	rockydesert
		gridX=3
		gridY=1
		icon_state="rockydesert"
		screen_loc="CENTER,CENTER-4:+12"
	plains
		gridX=4
		gridY=3
		icon_state="plains"
		screen_loc="CENTER+3:+4,CENTER+2:-12"
	namek
		gridX=1
		gridY=2
		icon_state="namek"
		screen_loc="CENTER-6:-8,CENTER-1"
	mountains
		gridX=2
		gridY=2
		icon_state="mountains"
		screen_loc="CENTER-3:-4,CENTER-1"
	lookout
		gridX=3
		gridY=2
		icon_state="lookout"
		screen_loc="CENTER,CENTER-1"
	roadside
		gridX=4
		gridY=2
		icon_state="roadside"
		screen_loc="CENTER+3:+4,CENTER-1"
	budokai
		gridX=1
		gridY=1
		icon_state="budokai"
		screen_loc="CENTER-6:-8,CENTER-4:+12"
	city
		gridX=2
		gridY=1
		icon_state="city"
		screen_loc="CENTER-3:-4,CENTER-4:+12"
	kamehouse
		gridX=3
		gridY=3
		icon_state="kamehouse"
		screen_loc="CENTER,CENTER+2:-12"
	cellgames
		gridX=4
		gridY=1
		icon_state="cellgames"
		screen_loc="CENTER+3:+4,CENTER-4:+12"
	New()
		..()
		var/image/I=new('stages.dmi',src,icon_state="selected")
		I.plane=src.plane+1
		I.layer=src.layer+1
		src.overimage=I
		if(src.gridX>levelmaxX)levelmaxX=src.gridX
		if(src.gridY>levelmaxY)levelmaxY=src.gridY
	MouseEntered()
		for(var/obj/gui/levelselect/L in levels)
			usr.client?.images-=L.overimage
		usr.client?.levelselectcoord=vector(src.gridX,src.gridY)
		usr.client?.stageprelim=src
		usr.client?.images+=src.overimage
	MouseExited()
		usr.client?.images-=src.overimage

	Click()
		usr.client?.Select()
client
	proc/Select()

		var/obj/stagetag/S
		if(src.levelselect>world.time)return
		for(var/obj/stagetag/O in stageobjs)
			if(src.stageprelim:icon_state==O.guistate)
				S=O
		src.levelpick=stagezs[S.name]
		for(var/obj/gui/levelselect/L in src.screen)
			src.screen-=L
		src.pickinglevel=0

	proc/Navigate(direction)
		var/X=0
		var/Y=0
		switch(direction)
			if(NORTH)Y=1
			if(SOUTH)Y=-1
			if(EAST)X=1
			if(WEST)X=-1
			if(NORTHEAST)
				Y=1
				X=1
			if(NORTHWEST)
				Y=1
				X=-1
			if(SOUTHEAST)
				Y=-1
				X=1
			if(SOUTHWEST)
				Y=-1
				X=-1
		src.levelselectcoord+=vector(X,Y)
		if(levelselectcoord.x>levelmaxX)levelselectcoord.x=1
		if(levelselectcoord.y>levelmaxY)levelselectcoord.y=1
		if(levelselectcoord.x<=0)levelselectcoord.x=levelmaxX
		if(levelselectcoord.y<=0)levelselectcoord.y=levelmaxY
		for(var/obj/gui/levelselect/L in levels)
			if(L.gridX==src.levelselectcoord.x && L.gridY==src.levelselectcoord.y)
				src.stageprelim=L
				src.images+=L.overimage
			else
				src.images-=L.overimage





client/var/levelselect
client/var/vector/levelselectcoord
client/var/stageprelim




client/verb/PlayLevel()

	var/mob/P=src.mob
	var/pixloc/Po=P.pixloc
	var/pixloc/Eo
	var/list/choices=new/list()
	src.levelpick=null
	for(var/mob/m in world)
		if(m!=src.mob && m.client)
			choices+=m
	choices+="Computer"
	choices+="Cancel"
	var/mob/E
	var/p=input(usr,"Pick an Opponent","Opponent Select") in choices
	if(p=="Cancel")return
	var/enemy
	if(p=="Computer")
		var/list/M=typesof(/mob)
		M-=/mob
		M-=/mob/picking
		enemy=input(usr,"Select a mob to spawn","Opponent") in M
	else
		E=p
		Eo=E.pixloc
	var/list/S=new/list
	for(var/s in stagezs)
		S+=s
	src.screen|=levels
	src.levelselectcoord=vector(1,3)
	src.levelselect=world.time+20
	src.pickinglevel=1
	while(!src.levelpick)
		sleep(20)


	var/Map/map = maps.copy(src.levelpick)
	var/obj/stagetag/T=stageobjs[src.levelpick]
	src.mob.loc=locate(T.Start.x,T.Start.y,map.z)
	src.edge_limit = T.dimensions
	src.mob.team="Good"
	if(p=="Computer")
		E=new enemy (locate(T.Start.x+4,T.Start.y,map.z))
		spawn(20)Awaken(E,src.mob)
	else
		E.loc=locate(T.Start.x+4,T.Start.y,map.z)
		E.client?.edge_limit = T.dimensions
	E.team="Evil"
	if(src.overworld)src.LeaveOverworld()
	if(E.client?.overworld)E.client.LeaveOverworld()
	while(E&&!E.dead&&P&&!P.dead)
		sleep(50)
	if(!E||E.dead)
		P.pixloc=Po
		src.edge_limit=null
	else
		if(p!="Computer")
			if(E&&!E.dead&&Eo)
				E.pixloc=Eo
				E.client?.edge_limit=null
		else
			E.loc=null
	map.free()

client/verb/PVP(mob/E)


	var/mob/P=src.mob
	var/pixloc/Po=P.pixloc
	var/pixloc/Eo
	src.levelpick=null
	Eo=E.pixloc
	var/list/S=new/list
	for(var/s in stagezs)
		S+=s
	src.screen|=levels
	src.levelselect=world.time+20
	src.pickinglevel=1
	while(!src.levelpick)
		sleep(20)
	src.LeaveOverworld()
	E.client?.LeaveOverworld()

	var/Map/map = maps.copy(src.levelpick)
	var/obj/stagetag/T=stageobjs[src.levelpick]
	src.mob.loc=locate(T.Start.x,T.Start.y,map.z)
	src.edge_limit = T.dimensions
	src.mob.team="Good"
	E.loc=locate(T.Start.x+4,T.Start.y,map.z)
	E.client?.edge_limit = T.dimensions
	E.team="Evil"
	spawn(20)Awaken(E,src.mob)

	while(E&&!E.dead&&P&&!P.dead)
		sleep(50)
	if(!E||E.dead)
		P.pixloc=Po
		src.edge_limit=null
	else

		if(E&&!E.dead&&Eo)
			E.pixloc=Eo
			E.client?.edge_limit=null
			E.client?.VisitOverworld()
	map.free()
	src.VisitOverworld()

proc/Fight(mob/P1,mob/P2,Level,oworld)
	var/pixloc/Po=P1.pixloc
	var/pixloc/Eo

	var/Map/map = maps.copy(Level)
	var/obj/stagetag/T=stageobjs[Level]
	P1.loc=locate(T.Start.x,T.Start.y,map.z)
	P1.client?.edge_limit = T.dimensions
	P1.team="Good"
	if(!P2.client)
		P2.loc= locate(T.Start.x+4,T.Start.y,map.z)
		spawn(20)Awaken(P2,P1)
	else
		P2.loc=locate(T.Start.x+4,T.Start.y,map.z)
		P2.client?.edge_limit = T.dimensions
	P2.team="Evil"

	while(P2&&!P2.dead&&P1&&!P1.dead)
		sleep(50)

	sleep(30)
	if(!P2||P2.dead)

		if(oworld)
			P1.client?.VisitOverworld()
		else
			P1.pixloc=Po
		P1.client?.edge_limit=null
	else
		if(P2.client)
			if(P2&&!P2.dead&&Eo)
				if(oworld)
					P2.client?.VisitOverworld()
				else P2.pixloc=Eo
				P2.client?.edge_limit=null
		else
			P2.loc=null

	map.free()




var
	alist/stagezs
	stageobjs[]

/*
	var/Map/map = maps.copy(2)

This creates a copy of the second z level. The copy is created on the
first available z level (or, if none are available, a new one is created).
The Map object is returned so you can manage the new map instance:

	mob.loc = locate(5, 3, map.z)

	map.repop()

	map.free()
	*/