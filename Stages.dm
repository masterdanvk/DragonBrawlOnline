obj
	stagetag
		var
			vector/Start=vector(16,4)
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
			dimensions = "1,1 to 33,23"
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
			name="The Lookout"
			dimensions = "1,1 to 24,22"
			guistate="lookout"
		Namek
			name="Namek"
			dimensions = "1,1 to 24,22"
			guistate="namek"
		Cellgames
			name="Cell Games"
			dimensions ="1,1 to 37,22"
			guistate="cellgames"

client/var/tmp/levelpick
obj/gui/levelselect
	icon='stages.dmi'
	background
		icon='gui/levelselect.png'
		screen_loc="CENTER-6:-17,CENTER-4:-8"
		Click()
			return
	vegeta
		icon_state="vegeta"
		screen_loc="CENTER-6:-8,CENTER+2:-12"
	raditz
		icon_state="raditz"
		screen_loc="CENTER-3:-4,CENTER+2:-12"
	rockydesert
		icon_state="rockydesert"
		screen_loc="CENTER,CENTER-4:+12"
	plains
		icon_state="plains"
		screen_loc="CENTER+3:+4,CENTER+2:-12"
	namek
		icon_state="namek"
		screen_loc="CENTER-6:-8,CENTER-1"
	mountains
		icon_state="mountains"
		screen_loc="CENTER-3:-4,CENTER-1"
	lookout
		icon_state="lookout"
		screen_loc="CENTER,CENTER-1"
	roadside
		icon_state="roadside"
		screen_loc="CENTER+3:+4,CENTER-1"
	budokai
		icon_state="budokai"
		screen_loc="CENTER-6:-8,CENTER-4:+12"
	city
		icon_state="city"
		screen_loc="CENTER-3:-4,CENTER-4:+12"
	kamehouse
		icon_state="kamehouse"
		screen_loc="CENTER,CENTER+2:-12"
	cellgames
		icon_state="cellgames"
		screen_loc="CENTER+3:+4,CENTER-4:+12"
	Click()
		var/obj/stagetag/S
		for(var/obj/stagetag/O in stageobjs)
			if(O.guistate==src.icon_state)
				S=O
		usr.client?.levelpick=stagezs[S.name]
		for(var/obj/gui/levelselect/L in usr.client?.screen)
			usr.client.screen-=L

Instance
	var/list/TeamA
	var/list/TeamB
	var/stage
	proc/Initiate()

	Nappa
		Initiate()



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