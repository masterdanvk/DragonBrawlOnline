// Issues

//spiritbomb is way too far topright
//Manage when ESC is available
// Character select, maptext on which character and border for selected character
//spiritshot isnt working

//scenarios and standardizing procs
	//23th budokai [Done]
	//Raditz Fight [Done]
	//Nappa Fight [Done]
	//Vegeta Fight [Partially Done]
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
		if(src.home.icon_state=="1")
			if(usr.client&&!(usr.client in src.home:battlegui:team1owners))return
		else
			if(usr.client&&!(usr.client in src.home:battlegui:team2owners))return

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
	C.bench2=enemies
	C.stage=src.levelpick
	C.players=P
	src.levelpick=null
	C.bench1=choices
	src.unlimitedreinforcements=1
	src.Loadbattlegui(C)


client/var/unlimitedreinforcements=0
client/verb/Battlegui()
	src.unlimitedreinforcements=0
	src.Loadbattlegui(new/Instance/Nappa())

client/proc/Loadbattlegui(Instance/I)

	var/obj/gui/battlegui/B=new()
	src.battlegui=B
	src.screen+=B
	for(var/mob/M in I.bench1)
		var/obj/mobref/m=new/obj/mobref(,M)
		B.bench1.mobs+=m
		m.home=B.bench1

	for(var/mob/M in I.bench2)
		var/obj/mobref/m=new/obj/mobref(,M)
		B.bench2.mobs+=m
		m.home=B.bench2
	for(var/i in 1 to 8)
		for(var/i2 in 1 to 7)
			if(I.charslots[i][i2])
				var/obj/mobref/m=new/obj/mobref(,I.charslots[i][i2])
				var/obj/gui/charslot/C=B.charslots[i][i2]
				m.home=C
				C.vis_contents+=m
				C.mref=m


	B.Player[1]=src
	B.instance=I
	B.Refreshbench(B.bench1)
	B.Refreshbench(B.bench2)






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
			team1owners[0]
			team2owners[0]
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
			spawn(5)
				if(Player[1])team1owners|=Player[1]
				if(Player[5])team2owners|=Player[5]
				else
					if(Player[1] && !instance.inflexibleteam2)team2owners|=Player[1]
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
			if(src.Playernumber<=4)
				if(usr.client&&!(usr.client in src.battlegui.team1owners))return
			else
				if(src.battlegui:Player[1]!=usr.client&&(usr.client&&!(usr.client in src.battlegui.team2owners)))return
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
						src.battlegui.Player-=c
						c.screen-=usr.client?.battlegui
				C.screen|=src.battlegui
				src.battlegui:Player[src.Playernumber]=C
				src.battlegui:Refreshplayerslots()
		proc/Setplayer(client/C)
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
			if(src.icon_state=="1")
				if(usr.client&&!(usr.client in src.battlegui.team1owners))return
			else
				if(usr.client&&!(usr.client in src.battlegui.team2owners))return
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
			if(src.icon_state=="1")
				if(usr.client&&!(usr.client in src.battlegui.team1owners))return
			else
				if(usr.client&&!(usr.client in src.battlegui.team2owners))return
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


client/var
	mob/oldmob
	turf/oldloc


var
	obj/Victory
	obj/Defeat
client/var/inbattle=0
