// Issues

//spiritbomb is way too far topright
//Manage when ESC is available
//when fights are over, winners dont die but leave gracefully
//some sort of WIN or LOSE maptext
//charge bump results in a high damage knockback IF you dont block. if you do block do a microstun on the charger.
// Character select, maptext on which character and border for selected character
//control handling on battles, PVP - team 1 P1 team 2 P2, Coop - P1 and P2 can make changes
//scenario control handling, player cant change P2 settings
//scenarios and standardizing procs
	//24th budokai
	//Raditz Fight
	//Nappa Fight
	//Vegeta Fight
	//Ginyu Force Fight
	//Frieza Fight



client
	var
		characters[0]
		obj/mobref/selectedmobref
		obj/gui/battlegui/battlegui


obj/mobref
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE+2
	var
		mob/ref
		obj/gui/home
	New(turf/L,mob/M)
		..(L)
		src.icon=M.oicon
		src.icon_state=M.oicon_state
		src.ref=M
	Click()
		if(usr.client&&usr.client!=src.home:battlegui.Player[1])return

		if(usr.client?.selectedmobref &&usr.client?.selectedmobref==src)
			usr.client.selectedmobref.filters=null
			usr.client.selectedmobref=null
			return
		if(usr.client?.selectedmobref && usr.client?.selectedmobref.home!=src.home)
			usr.client.Swapref(usr.client.selectedmobref,src)
			return
		for(var/obj/O in usr.client?.battlegui.bench1.mobs)
			O.filters=null
		for(var/obj/O in usr.client?.battlegui.bench2.mobs)
			O.filters=null
		for(var/obj/gui/charslot/C in usr.client?.battlegui.charslots)
			for(var/obj/O in C)
				O.filters=null
		src.filters=filter(type="outline", color="white")
		usr.client?.selectedmobref=src



client/proc/Customfight(list/P)
	var/list/choices=new/list
	var/list/enemies=new/list
	for(var/t in playerselection)
		var/typ=playerselection[t]
		choices+=new typ(,alist(hp=200))
		enemies+=new typ(,alist(hp=200))
	src.levelpick=null
	var/list/S=new/list
	for(var/s in stagezs)
		S+=s
	src.screen|=levels
	src.levelselect=world.time+20
	src.pickinglevel=1
	while(!src.levelpick)
		sleep(20)
	var/Instance/C=new()
	C.bench=enemies
	C.stage=src.levelpick
	C.players=P
	src.levelpick=null
	src.characters=choices
	src.unlimitedreinforcements=1
	src.Loadbattlegui(C)


client/var/unlimitedreinforcements=0
client/verb/Battlegui()
	src.characters=list(
		new/mob/yamcha(,alist(pl=1480,hp=200,unlocked=alist("none"=1))),
		new/mob/krillin(,alist(pl=1770,hp=200,unlocked=alist("none"=1))),
		new/mob/tien(,alist(pl=1830,hp=200,unlocked=alist("none"=1))),
		new/mob/gohan(,alist(pl=981,hp=200,unlocked=alist("none"=1))),
		new/mob/chaotzu(,alist(pl=610,hp=200,unlocked=alist("none"=1))),
		new/mob/piccolo(,alist(pl=3500,hp=200,unlocked=alist("none"=1))),
		new/mob/goku(,alist(pl=9001,hp=200,unlocked=alist("kaiokenx2"=1))))
	src.unlimitedreinforcements=0
	src.Loadbattlegui(new/Instance/Nappa())
client/proc/Loadbattlegui(Instance/I)

	var/obj/gui/battlegui/B=new()
	src.battlegui=B
	src.screen+=B
	for(var/mob/M in src.characters)
		var/obj/mobref/m=new/obj/mobref(,M)
		B.bench1.mobs+=m
		m.home=B.bench1

	for(var/mob/M in I.bench)
		var/obj/mobref/m=new/obj/mobref(,M)
		B.bench2.mobs+=m
		m.home=B.bench2
	B.Player[1]=src
	B.instance=I
	B.Refreshbench(B.bench1)
	B.Refreshbench(B.bench2)



Instance
	var/list/bench[]
	var/stage
	var/list/players[8]
	Custom


	Nappa
		New()
			..()
			stage=stagezs["Plains"]
			bench=list(
				new/mob/saibamen(,alist("pl"=1100,"hp"=100)),
				new/mob/saibamen(,alist("pl"=1100,"hp"=100)),
				new/mob/saibamen(,alist("pl"=1100,"hp"=100)),
				new/mob/saibamen(,alist("pl"=1100,"hp"=100)),
				new/mob/saibamen(,alist("pl"=1100,"hp"=100)),
				new/mob/saibamen(,alist("pl"=1100,"hp"=100)),
				new/mob/nappa(,alist("pl"=4000,"hp"=800)),
				new/mob/vegeta(,alist("pl"=18000,"hp"=200)))


obj/gui
	battlegui
		proc
			Refreshbench(obj/gui/charbench/B)
				B.vis_contents=null
				for(var/i in 1 to B.mobs.len)

					var/obj/O=B.mobs[i]
					O.pixel_x = 7 + ((i - 1) % 7) * 32
					O.pixel_y = 64 - floor((i - 1) / 7) * 32

					B.vis_contents+=O
			Refreshplayerslots()
				for(var/obj/gui/playerslot/P in src.playerslots)
					if(Player[P.Playernumber])
						P.player=Player[P.Playernumber]
						P.maptext="<span style='text-align:left;vertical-align:top;font-size:6px;'>[P.player:name] ([P.player])</span>"
					else
						P.maptext="<span style='text-align:left;vertical-align:top;font-size:6px;'>Computer</span>"


		screen_loc="CENTER-8,CENTER-3:-5"
		icon='gui/battlegui.dmi'
		var
			charslots[8][7] //player and charslot
			obj/gui/charbench/bench1
			obj/gui/charbench/bench2
			Player[8]
			playerslots[8]
			buttons[1]
			Instance/instance
		New()
			..()
			sleep(3)
			buttons[1]=new/obj/gui/start
			buttons[1].battlegui=src
			src.vis_contents+=buttons[1]
			for(var/i in 1 to charslots.len) //for(var/row in 1 to rows)
				playerslots[i]=new/obj/gui/playerslot
				playerslots[i].battlegui=src
				playerslots[i].pixel_y=177-(i-1)*48
				playerslots[i].Playernumber=i
				if(i>=5)
					playerslots[i].icon_state="2"
					playerslots[i].pixel_x=256
					playerslots[i].pixel_y+=192
				else if(i==1)
					spawn(1)
						playerslots[1].player=Player[1]

						if(src.instance.players)

							for(var/p in 2 to 8)

								if(src.instance.players[p])
									Player[p]=src.instance.players[p]
									playerslots[p]?.Setplayer(src.instance.players[p])
						src.Refreshplayerslots()
				src.vis_contents+=playerslots[i]
				for(var/I in 1 to charslots[i].len)
					charslots[i][I]=new/obj/gui/charslot(,i,I)
					charslots[i][I].battlegui=src
					src.vis_contents+=charslots[i][I]
					if(i<=4)
						charslots[i][I].pixel_x=17+(I-1)*34
						charslots[i][I].pixel_y=145-(i-1)*48
					else
						charslots[i][I].icon_state="2"
						charslots[i][I].pixel_x=258+136+(I-5)*34
						charslots[i][I].pixel_y=145-(i-5)*48
					I++

				i++
			bench1=new/obj/gui/charbench
			bench2=new/obj/gui/charbench
			bench1.battlegui=src
			bench2.battlegui=src
			bench2.icon_state="2"
			bench2.pixel_x=255
			src.vis_contents+=bench1
			src.vis_contents+=bench2
	start
		icon='gui/start.dmi'
		icon_state="0"
		plane=FLOAT_PLANE+3
		pixel_y=-24
		pixel_x=224
		var
			obj/gui/battlegui/battlegui
		Click()
			if(usr.client&&usr.client!=src.battlegui:Player[1])return
			icon_state="1"
			sleep(5)
			var/list/mobrefs[8][7]
			for(var/i in 1 to 8)
				for(var/obj/gui/charslot/C in src.battlegui.charslots[i])
					if(C.mref)mobrefs[C.pslot][C.cslot]=C.mref

			for(var/client/c in src.battlegui.Player)
				c.screen-=src.battlegui
			Battle(src.battlegui.Player,mobrefs,src.battlegui.instance)
			del(src.battlegui)


	playerslot
		icon='gui/playerslot.dmi'
		icon_state="1"
		plane=FLOAT_PLANE+3
		pixel_x=17
		maptext_width=200
		maptext_y=-17
		maptext_x=2
		var
			Playernumber
			player
			obj/gui/battlegui/battlegui
		Click()
			if(usr.client&&usr.client!=src.battlegui:Player[1])return
			var/list/options=list("Nevermind")
			options+=clients
			options-=usr.client
			var/client/C = input(usr,"Which player do you want to invite?","Invite") in options
			if(C=="Nevermind")return
			if(!usr.client.battlegui)return
			if(src.Playernumber==1)return
			var/answer=C.ShowDialogue("Join [usr.name]'s Lobby?","[usr.name] wants to play a match with you, do you want to join?",list("No","Yes"))
			if(answer=="Yes")
				for(var/client/c in usr.client?.battlegui:Player)
					if(c==C)
						usr.client?.battlegui:Player-=c
						c.screen-=usr.client?.battlegui
				C.screen|=usr.client?.battlegui
				usr.client?.battlegui:Player[src.Playernumber]=C
				usr.client?.battlegui:Refreshplayerslots()
		proc/Setplayer(client/C)
			world.log<<"Successfully Setplayer [C]"
			C.screen|=usr.client?.battlegui
			src.battlegui:Player[src.Playernumber]=C
			src.battlegui:Refreshplayerslots()

	charbench
		icon='gui/battlegui2.dmi'
		pixel_x=18
		pixel_y=194
		icon_state="1"
		var
			mobs[0]
			obj/gui/battlegui/battlegui
		Click()
			if(usr.client!=src.battlegui.Player[1])return
			if(usr.client?.selectedmobref&&usr.client?.selectedmobref.home.icon_state!=src.icon_state)return
			var/obj/H=usr.client?.selectedmobref?.home
			var/obj/mobref/M=usr.client?.selectedmobref
			if(!M)return
			if(H&&istype(H,/obj/gui/charslot))
				H:mref=null
				H.vis_contents=null
				if(usr.client?.unlimitedreinforcements)
					M.home=null
					del(M)
					return
			M.home=src
			src.mobs|=M
			src.battlegui.Refreshbench(src)
			src.filters=null
			usr.client?.selectedmobref=null

	charslot
		var
			pslot
			cslot
			obj/mobref/mref
			obj/gui/battlegui/battlegui
		icon='gui/battlegui3.dmi'
		icon_state="1"
		New(turf/L,player,slot)
			..(L)
			pslot=player
			cslot=slot
		Click()
			if(usr.client!=src.battlegui.Player[1])return
			if(usr.client?.selectedmobref && usr.client?.selectedmobref.home!=src)
				var/obj/H=usr.client?.selectedmobref.home
				var/obj/mobref/M=usr.client?.selectedmobref
				if(H&&H.icon_state==src.icon_state)
					if(istype(H,/obj/gui/charbench))
						if(!usr.client.unlimitedreinforcements)
							H:mobs-=M
							usr.client?.battlegui.Refreshbench(H)
						else
							var/mob/m=new M.ref.type()
							var/obj/mobref/N=new/obj/mobref(,m)
							src.vis_contents+=N
							src.mref=N
							N.pixel_x=4
							N.pixel_y=2
							N.home=src
							return
					else if(istype(H,/obj/gui/charslot))
						H:mref=null
						H.vis_contents=null

					if(src.mref && src.mref!=M)
						usr.client?.Swapref(M,src.mref)
					M.home?.vis_contents-=src
					M.home=src
					M.pixel_x=4
					M.pixel_y=2
					src.vis_contents+=M
					src.mref=M
					M.filters=null
					usr.client?.selectedmobref=null



			//18,98 +0:18,+3:6

client/proc/Swapref(obj/mobref/stealer,obj/mobref/M)
	if(!usr.client.unlimitedreinforcements)
		var/obj/gui/OGhome=stealer.home
		stealer.home=M.home
		M.home=OGhome
		stealer.home.vis_contents-=M
		M.home.vis_contents-=stealer
		if(istype(stealer.home,/obj/gui/charslot))
			stealer.pixel_x=6
			stealer.pixel_y=0
			stealer.home.vis_contents+=stealer
			stealer.home:mref=stealer
		else
			stealer.home:mobs-=M
			stealer.home:mobs|=stealer
			src.battlegui.Refreshbench(stealer.home)
		if(istype(M.home,/obj/gui/charslot))
			M.pixel_x=4
			M.pixel_y=2
			M.home.vis_contents+=M
			M.home:mref=M
		else
			M.home:mobs|=M
			M.home:mobs-=stealer
			src.battlegui.Refreshbench(M.home)
	else
		if(istype(M.home,/obj/gui/charslot))
			var/mob/m=new M.ref.type()
			var/obj/mobref/N=new/obj/mobref(,m)
			M.home.vis_contents+=N
			M.home:mref=N
			N.pixel_x=4
			N.pixel_y=2
			N.home=M.home
			M.home.vis_contents-=M
			M.home=null

	usr.client?.selectedmobref?.filters=null
	usr.client?.selectedmobref=null

mob/var/tmp/pnum
proc/Battle(list/Players,list/Mobrefs,Instance/I)

	var/Map/map = maps.copy(I.stage)
	var/obj/stagetag/T=stageobjs[I.stage]//load level
	for(var/client/C in Players)
		C.inbattle=1
		C.LeaveOverworld()
		C.mob.loc=null
		C.edge_limit = T.dimensions
	var/list/mobs[8]
	var/list/activeteam1=new/list()
	var/list/activeteam2=new/list()
	var/list/Good=new
	var/list/Evil=new
	var/list/computerallies=new/list()
	var/list/computerenemies=new/list()
	var/wave=1
	var/wave2=1

	for(var/i in 1 to 8)
		mobs[i]=new/list()
		for(var/i2 in 1 to 7)
			if(Mobrefs[i]&&Mobrefs[i][i2])
				if(Mobrefs[i][i2].ref)
					mobs[i]+=Mobrefs[i][i2].ref

					if(i<=4)
						Mobrefs[i][i2].ref.team="Good"
						Mobrefs[i][i2].ref.pnum=i2
						Good+=Mobrefs[i][i2].ref

					else
						Mobrefs[i][i2].ref.team="Evil"
						Mobrefs[i][i2].ref.pnum=i2
						Evil+=Mobrefs[i][i2].ref

		/*var/mob/M
		if(mobs[i]&&mobs[i].len)M=mobs[i][1]
		if(M)
			if(Players[i])
				var/mob/old=Players[i].mob
				Players[i].mob=M
				old.loc=null


			else
				if(i<=4)
					computerallies|=M
					M.aggrotag=1
				else
					computerenemies|=M
					M.aggrotag=1
			//if(i<5)
			//	activeteam1|=M
			//	M.loc=locate(T.Start.x-i,T.Start.y,map.z)
			*/

	for(var/i in 1 to 4)
		if(Mobrefs[i][wave]&&Mobrefs[i][wave].ref)
			Mobrefs[i][wave].ref.loc=locate(T.Start.x-(i)-3,T.Start.y,map.z)
			Mobrefs[i][wave].ref.team="Good"
			activeteam1|=Mobrefs[i][wave].ref

			if(!Players[i])spawn(5)if(activeteam2.len)Awaken(Mobrefs[i][wave].ref,pick(activeteam2))
			else
				Players[i].mob=Mobrefs[i][wave].ref
				Players[i].mob.team="Good"
	for(var/i in 5 to 8)
		if(Mobrefs[i][wave2]&&Mobrefs[i][wave2].ref)
			Mobrefs[i][wave2].ref.loc=locate(T.Start.x+(i-4)+3,T.Start.y,map.z)
			Mobrefs[i][wave2].ref.team="Evil"
			activeteam2|=Mobrefs[i][wave2].ref
			if(!Players[i])spawn(5)if(activeteam1.len)Awaken(Mobrefs[i][wave2].ref,pick(activeteam1))
			else
				Players[i].mob=Mobrefs[i][wave2].ref
				Players[i].mob.team="Evil"
	sleep(20)
	for(var/mob/C in computerallies)
		spawn()Awaken(C,pick(activeteam2))
	for(var/mob/C in computerenemies)
		spawn()Awaken(C,pick(activeteam1))

	while(Good.len && Evil.len)
		sleep(100)
		for(var/mob/m in activeteam1)
			if(m.dead)
				Good-=m
				var/num=m.pnum
				activeteam1-=m
				if(m in computerallies)
					computerallies-=m
					mobs[num]-=m
				//	if(mobs[num].len && mobs[num][1])
				//		computerallies|=mobs[num][1]
				//		if(activeteam2.len)spawn()Awaken(mobs[num][1],pick(activeteam2))
				else if(m.client)
					mobs[num]-=m
				//	if(mobs[num].len && mobs[num][1])
				//		m.client.mob=mobs[num][1]
				//if(mobs[num]?.len&&mobs[num][1])
				//	mobs[num][1].loc=locate(T.Start.x-(num),T.Start.y,map.z)
				//	activeteam1|=mobs[num][1]
		for(var/mob/m in activeteam2)
			if(m.dead)
				Evil-=m
				var/num=m.pnum
				activeteam2-=m
				if(m in computerenemies)
					computerenemies-=m
					mobs[num]-=m
				//	if(mobs[num].len && mobs[num][1])
				//		computerenemies|=mobs[num][1]
				//		if(activeteam1.len)spawn()Awaken(mobs[num][1],pick(activeteam1))
				else if(m.client)
					mobs[num]-=m
				//	if(mobs[num].len && mobs[num][1])
				//		m.client.mob=mobs[num][1]
				//if(mobs[num]?.len&&mobs[num][1])
				//	mobs[num][1].loc=locate(T.Start.x+(num-4),T.Start.y,map.z)
				//	activeteam2|=mobs[num][1]
		if(!activeteam1.len)
			wave++
			for(var/i in 1 to 4)
				if(Mobrefs[i][wave]&&Mobrefs[i][wave].ref)
					Mobrefs[i][wave].ref.loc=locate(T.Start.x-i,T.Start.y,map.z)
					Mobrefs[i][wave].ref.team="Good"
					activeteam1|=Mobrefs[i][wave].ref
					if((Players.len>=i||!Players[i]) && !activeteam2.len)Awaken(Mobrefs[i][wave].ref,pick(activeteam2))
					else
						if(Players.len>=i)
							Players[i].mob=Mobrefs[i][wave].ref
							Players[i].mob.team="Good"

		if(!activeteam2.len)
			wave2++
			for(var/i in 5 to 8)
				if(Mobrefs[i][wave2]&&Mobrefs[i][wave2].ref)
					Mobrefs[i][wave2].ref.loc=locate(T.Start.x+(i-4),T.Start.y,map.z)
					Mobrefs[i][wave2].ref.team="Evil"
					activeteam2|=Mobrefs[i][wave2].ref
					if((Players.len>=i||!Players[i]) && activeteam1.len)Awaken(Mobrefs[i][wave2].ref,pick(activeteam1))
					else
						if(Players.len>=i)
							Players[i].mob=Mobrefs[i][wave2].ref
							Players[i].mob.team="Evil"

		for(var/mob/A in computerenemies)
			if(!A.targetmob || A.targetmob.dead)
				world.log<<"no targetmob! gonna pick from [activeteam1[1]]"
				if(activeteam1.len)
					Awaken(A,pick(activeteam1))
		for(var/mob/A in computerallies)
			if(!A.targetmob || A.targetmob.dead)
				if(activeteam2.len)
					Awaken(A,pick(activeteam2))

	//	world.log<<"Loop [activeteam1.len] / [activeteam2.len]"

	if(!activeteam1.len)
		world.log<<"Team 2 won!"
	else
		world.log<<"Team 1 won!"



	map.free()

	for(var/client/C in Players)
		C.edge_limit=null
		C.inbattle=0
		C.mob.Die()
	for(var/mob/m in mobs)
		m.loc=null
	for(var/mob/m in Good)
		m.loc=null
	for(var/mob/m in Evil)
		m.loc=null



client/var/inbattle=0


/*
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
	src.VisitOverworld()	*/