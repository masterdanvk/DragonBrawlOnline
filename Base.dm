/*
- Charge bar is in middle of screen not on the mob
- Dense objects are being left on the map - not sure what they are

 */
world
	hub = "Masterdan.DragonBrawlOnline"
	visibility = 1
	hub_password="JN1Vh8KBRoJVFvWu"
	name = "Dragon Brawl Online Test Server - 516"

var/regex/comma_expression = new("(\\d)(?=(\\d{3})+$)","g") // hidden init proc, I know I know.

#define commafy(x) comma_expression.Replace(num2text(x,12),"$&,")

//100ms
//200ms for pressing releasing and pressing again
mob/verb/Check_Vars()
	world<<"usingskill [usingskill] aiming [aiming] canmove [canmove] chargin [charging] bouncing [bouncing] tossed [tossed] attacking [attacking] block[block]"
	world<<"mybeam [mybeam] mybeam.clash [mybeam?.clash] mybeam.head [mybeam?.head]"
 #define DEBUG
var/activemobs[0]
world

	tick_lag= 0.25 // 25 frames per second
	icon_size = 32	// 32x32 icon size by default
//	map_format=TOPDOWN_MAP
	view = "20x15"		// show up to 6 tiles outward from center (13x13 view)
	movement_mode=PIXEL_MOVEMENT_MODE

client/perspective=EDGE_PERSPECTIVE

client/verb/changeview(var/i as text)
	src.view=i
client/verb/Togglechat()
	if(!usr)usr=src
	if(chatactive)
		chatactive=0
		for(var/chatbox_gui/G in usr.client?.screen)
			G.alpha=0
		for(var/chatbox/C in usr.client?.screen)
			C.alpha=0
	else
		chatactive=1
		for(var/chatbox_gui/G in usr.client?.screen)
			G.alpha=70
		for(var/chatbox/C in usr.client?.screen)
			C.alpha=120




client/verb/SaibamenSeeding(var/n as num)
	set background = 1
	var/e=0
	for(var/i=1 to n)
		var/mob/M=new/mob/saibamen/NPC(locate(rand(10,90),rand(10,90),1))
		RefreshChunks|=M
		e++
		if(e>=50)
			sleep(1)
			e=0





client/verb/SaibamenInvasion(var/n as num)
	var/pace=input(src,"How many do you want to be out at at time?","Wave size",8) as num
	pace=min(n,pace)
	var/saibasleft=n
	var/list/saibamen=new/list()
	var/list/humans=new/list()
	var/s=n


	for(var/i=1 to min(n,pace))
		var/mob/saib=new/mob/saibamen(locate(rand(10,90),rand(10,90),1))
		saibasleft--
		saib.team="Saibamen"
		saibamen+=saib
	for(var/mob/H in world)
		if(H.z==1 && H.client)humans+=H
	while(s)
		s=0
		for(var/mob/M in saibamen)
			if(M.dead || !M.loc)continue
			if(!M.targetmob || !M.targetmob.client|| (!(M in AI_Active)&&!M.activeai))
				var/mindist=9999
				for(var/mob/H in humans)
					if(H.dead)continue
					if(abs(H.pixloc-M.pixloc)<mindist)
						mindist=abs(H.pixloc-M.pixloc)
						M.targetmob=H
				if(!M.targetmob)
					for(var/mob/H in world)
						if(H.dead||!H.client)continue
						if(abs(H.pixloc-M.pixloc)<mindist)
							mindist=abs(H.pixloc-M.pixloc)
							M.targetmob=H
				if(M.targetmob)
					Awaken(M,M.targetmob)
				else
					M.loc=null
			s++
		if(!s && saibasleft)
			var/c=saibasleft
			for(var/i=1 to min(c,pace))
				var/mob/saib=new/mob/saibamen(locate(rand(10,90),rand(10,90),1))
				saibasleft--
				saib.team="Saibamen"
				saibamen+=saib
				s++
		sleep(50)

	world<<"The Saibamen invasion is over!!"

client/verb/RaditzFight()
	var/hero=input(usr,"Which character do you want to be?","Character Select") in list("Goku","Piccolo","Cancel")
	if(hero=="Cancel")return
	var/prompt
	var/p1type
	var/p2type

	if(hero=="Goku")
		p1type=/mob/goku/raditzfight
		p2type=/mob/piccolo/raditzfight
		prompt="Who do you want to play as Piccolo?"
	else
		p1type=/mob/piccolo/raditzfight
		p2type=/mob/goku/raditzfight
		prompt="Who do you want to play as Goku?"
	var/list/choices=new/list
	for(var/mob/M in world)
		if(M!=src.mob && M.client)
			choices+=M
	choices+="Computer"
	choices+="Cancel"
	var/p=input(usr,"[prompt]","Ally Select") in choices
	var/mob/friend
	if(p=="Cancel")return
	for(var/mob/m in block(locate(48,1,2),locate(92,27,2)))
		m.loc=null
		m.Die()

	//72,19 raditz
	//68,14 goku
	//76,14 piccolo
	if(p!="Computer")friend=p

	var/mob/old=src.mob
	src.screen=null
	src.mob=new p1type(locate(68,14,2))
	del(old)
	var/mob/O=new/mob/raditz(locate(72,19,2))

	O.pl=1500
	O.hp=400
	O.maxhp=400
	O.aggrotag=1
	O.aggrorange=2
	O.wanderrange=4


	var/client/F
	if(p!="Computer")
		F=friend.client
		var/mob/friendold=friend
		F.screen=null
		F.mob=new p2type(locate(76,14,2))
		friendold.loc=null
		del(friendold)
		friend=F.mob
	else
		friend=new p2type(locate(76,14,2))
		spawn(30)Awaken(friend,O)
	src.mob.hp=300
	src.mob.maxhp=300
	friend.hp=300
	friend.maxhp=300
	friend.team="Good"
	src.mob.team="Good"
	O.team="Evil"
	src.mob.loc.loc.Entered(src.mob)
	friend.loc.loc.Entered(friend)
	RefreshChunks|=O
	RefreshChunks|=friend
	RefreshChunks|=src.mob
	while(O&&!O.dead&&((src.mob&&!src.mob.dead)||(friend&&!friend.dead)))
		if(p=="Computer")
			friend.Heal(20)
		sleep(50)
	src.edge_limit=null
	F?.edge_limit=null
	if(!O||O.dead)
		world<<"[src.mob] and [friend] defeated Raditz!"
		if(src.mob)spawn()src.mob.Die()
		if(friend)spawn()friend.Die()
	else
		world<<"Raditz defeated [src.mob] and [friend]."
		O.loc=null
		O.targetmob=null



client/verb/Tournament(var/s in list("Accurate","Equal","Easy","Medium","Hard"))

	src.mob.loc=locate(16,8,2)
	src.mob.loc.loc.Entered(src.mob)
	sleep(100)

	switch(src.mob.type)
		if(/mob/goku) src.mob.Set_PL(380)
		if(/mob/chaotzu) src.mob.Set_PL(140)
		if(/mob/yamcha) src.mob.Set_PL(150)
		if(/mob/krillin) src.mob.Set_PL(200)
		if(/mob/tien) src.mob.Set_PL(240)
		if(/mob/piccolo) src.mob.Set_PL(375)
		if(/mob/gohan) src.mob.Set_PL(1307)
		if(/mob/vegeta)src.mob.Set_PL(18000)
	if(s=="Easy")src.mob.Set_PL(1000)
	if(s=="Medium")src.mob.Set_PL(380)
	if(s=="Hard")src.mob.Set_PL(150)
	if(s=="Equal")src.mob.Set_PL(9000)

	var/mob/user=src.mob
	var/mob/m
	user.maxhp*=2
	user.hp*=2

	user.unlocked=new/alist()
	if(!istype(user,/mob/chaotzu))
		m=new/mob/chaotzu (locate(24,8,2))
		m.maxhp*=2
		m.hp*=2
		if(s=="Equal") m.Set_PL(9000)
		else m.Set_PL(140) // chaotzu 140, Yamcha 150, Krillin 200, Tien 240, Piccolo 375
		sleep(20)
		Awaken(m,user)
		while(user&&!user.dead && !m.dead && user.z==m.z)
			sleep(10)
		if(!user||user.dead||user.z!=2)
			m?.loc=null
			src.edge_limit=null
			return
		user.Heal(200)
		sleep(100)
	if(!istype(user,/mob/yamcha))
		m=new/mob/yamcha(locate(24,8,2))
		m.maxhp*=2
		m.hp*=2
		if(s=="Equal") m.Set_PL(9000)
		else m.Set_PL(150)
		Awaken(m,user)
		while(user&&!user.dead && !m.dead && user.z==m.z)
			sleep(10)
		if(!user||user.dead||user.z!=2)
			m?.loc=null
			src.edge_limit=null
			return
		user.Heal(200)
		sleep(100)
	if(!istype(user,/mob/krillin))
		m=new/mob/krillin(locate(24,8,2))
		m.maxhp*=2
		m.hp*=2
		if(s=="Equal") m.Set_PL(9000)
		else m.Set_PL(200)
		Awaken(m,user)
		while(user&&!user.dead && !m.dead && user.z==m.z)
			sleep(10)
		if(!user||user.dead||user.z!=2)
			m?.loc=null
			src.edge_limit=null
			return
		user.Heal(200)
		sleep(100)
	if(!istype(user,/mob/tien))
		m=new/mob/tien(locate(24,8,2))
		m.maxhp*=2
		m.hp*=2
		if(s=="Equal") m.Set_PL(9000)
		else m.Set_PL(240)
		Awaken(m,user)
		while(user&&!user.dead && !m.dead && user.z==m.z)
			sleep(10)
		if(!user||user.dead||user.z!=2)
			m?.loc=null
			src.edge_limit=null
			return
		user.Heal(200)
		sleep(100)
	if(!istype(user,/mob/piccolo))
		m=new/mob/piccolo(locate(24,8,2))
		m.maxhp*=2
		m.hp*=2
		if(s=="Equal") m.Set_PL(9000)
		else m.Set_PL(375)
		Awaken(m,user)
		while(user&&!user.dead && !m.dead && user.z==m.z)
			sleep(10)
		if(!user||user.dead||user.z!=2)
			m?.loc=null
			src.edge_limit=null
			return
		user.Heal(200)
		sleep(100)
	if(!istype(user,/mob/goku))
		m=new/mob/goku(locate(24,8,2))
		m.maxhp*=2
		m.hp*=2
		if(s=="Equal") m.Set_PL(9000)
		else m.Set_PL(375)
		Awaken(m,user)
		while(user&&!user.dead && !m.dead && user.z==m.z)
			sleep(10)
		if(!user||user.dead||user.z!=2)
			m?.loc=null
			src.edge_limit=null
			return
		user.Heal(200)
	world<<"[user] [user.appearance] beat the 23rd Budokai Tenkaichi Tournament!"
	sleep(100)
	user.loc=null
	user.Die()
	src.edge_limit=null

proc/Awaken(mob/m,mob/opponent)
	m.targetmob=opponent
	m.CheckCanMove()
	AI_Active|=m
	m.Move(0)
	m.movevector=vector(0,0)
	m.rotation=0
	m.RotateMob(vector(0,0),100)
//	m.autoblocks=m.maxautoblocks
	m.tossed=0
	m.icon_state=""




client
	var
		chatactive=0
	tick_lag = 0.01
	Move(atom/NewLoc, Dir)
		walk(mob,0)
		return mob.Step(Dir)

atom/movable
	step_size = 4
	var
		move_speed = 4
		scale=1

	appearance_flags = LONG_GLIDE

	proc
		Step(Dir = src.dir, Dist = move_speed, Delay)
			glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
			return step(src,Dir,Dist)

mob
	var
		step_delay = 0.25
		tmp/next_move = 0
		tmp/stunned

	Step(Dir = src.dir, Dist = move_speed, Delay = step_delay)
		if(next_move>world.time) return 0
		glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
		next_move = world.time + Delay
		return step(src,Dir,Dist)


// Make objects move 8 pixels per tick when walking
mob
	Login()
		..()
		src.client?.removeskillbar()
		src.name=src.client.name
		src.team=src.ckey
		if(!istype(src,/mob/picking))
			src.client?.initskillbar()
			if(src.client && !src.client.chatinit)
				spawn(2)
					src.client.chatinit=1
					client.chatbox_build() // build the chatbox
					client.chatlog = "outputwindow.output" // set chatlog
					_message(world, "[name] has logged in.", "yellow") // notify world
				//spawn()src.client?.VisitOverworld()

client/verb/SayGamepad()
	var/obj/gui/menu/name_entry/picker = new()
	var/n = picker.Input(src,"What do you want to say?")

	src.mob.chat_say(_ftext(n,"lightgrey"))



mob/picking
	icon=null
	selecting=1

	Login()
		..()
		src.loc=null
		if(!src.client.name)
			//create a new name entry menu, and call Input()
			//Input() will wait until the client finishes picking a name.
			var/obj/gui/menu/name_entry/picker = new()
			var/n = picker.Input(src.client,"What is your name?")
			if(!src.client)return
			if(!n) n = src.client.key
			src.client.name = n

		src.client.Character_Select()


var/alist/playerselection=new/alist(
	Goku=/mob/goku,
	Vegeta=/mob/vegeta,
	Piccolo=/mob/piccolo,
	Gohan=/mob/gohan,
	Tien=/mob/tien,
	Krillin=/mob/krillin,
	Yamcha=/mob/yamcha,
	Chaiotzu=/mob/chaotzu,
	Roshi=/mob/roshi,
	Trunks=/mob/trunks,
	Raditz=/mob/raditz,
	Nappa=/mob/nappa,
	Saibamen=/mob/saibamen,
	Cell = /mob/cell,
	CellJr = /mob/celljr,
	MrSatan = /mob/mrsatan)

mob/verb/ChangePlayer()
	src.Die()


var/list/unusedmobs[0]
mob/var/tmp/selecting=0
mob/var/tmp/vector/displayvector
mob/var/tmp/spawncount=0
var/obj/controls
client/var/tmp/mob/select
client/var/tmp/mobselect[]
client/proc/Character_Select()

	if(src.mob&&!src.mob.selecting)
		var/mob/M=src.mob
		src.mob=new/mob/picking
		src.screen=null
		spawn(1)del(M)
	mobselect=new/list()
	for(var/types in playerselection)
		var/mob/N
		for(var/mob/R in unusedmobs[playerselection[types]])
			N=R
			break
		if(!N)
			var/T=playerselection[types]
			N=new T
		if(!src.select)src.select=N
		mobselect+=N

	src.RingDisplay()

var/ovalness=1
client/proc/RingDisplay()
	src.screen|=controls
	for(var/mob/m in src.screen)
		src.screen-=m
	var/picknum=mobselect.len
	if(!picknum)return
	ovalness=picknum/6
	for(var/i=1 to picknum)
		if(!mobselect[i])break
		mobselect[i].displayvector=vector(0,-96)
		mobselect[i].displayvector.Turn((i-1)*360/picknum)
		var/xoffset=0+round(mobselect[i].displayvector.x*ovalness,1)
		if(xoffset>0)xoffset="+[xoffset]"
		else xoffset="-[abs(xoffset)]"
		mobselect[i].screen_loc="CENTER:[xoffset],CENTER:+[round(96+mobselect[i].displayvector.y,1)]"
		src.screen|=mobselect[i]


client/proc/SelectingInput(button)
	if(button=="North"||button=="East"||button=="Northeast"||button=="Northwest")src.Pick_Next()
	else if(button=="West"||button=="South"||button=="Southwest"||button=="Southeast")src.Pick_Previous()
	else
		src.Pick_Mob()

client/proc/Pick_Mob()
	if(!src.select||src.busy)return
	src.mob=src.select
	src.VisitOverworld()
	src.mob.selecting=0

	unusedmobs-=src.mob
	src.mob.screen_loc=null
	src.screen-=src.mobselect
	for(var/mob/M in src.mobselect)
		src.screen-=M
		unusedmobs|=M
		src.mobselect-=M
	src.mobselect=null
	src.screen-=controls
	src.chatbox_showscreen()

client/var/busy=0
client/proc/Pick_Next()

	if(busy)return
	src.select=null
	busy=1
	var/picknum=src.mobselect.len
	for(var/i=1 to 5)
		for(var/mob/M in src.mobselect)
			M.displayvector.Turn((-360/picknum)/5)
			var/xoffset=0+round(M.displayvector.x*ovalness,1)
			if(xoffset>0)xoffset="+[xoffset]"
			else xoffset="-[abs(xoffset)]"
			var/newscreenloc ="CENTER:[xoffset],CENTER:+[round(96+M.displayvector.y,1)]"
			M.screen_loc=newscreenloc
		sleep(1)

	src.mob.selecting++
	if(src.mob.selecting>picknum)src.mob.selecting=1
	src.select=src.mobselect[src.mob.selecting]
	busy=0


client/proc/Pick_Previous()

	if(busy)return
	src.select=null
	busy=1
	var/picknum=src.mobselect.len
	for(var/i=1 to 5)
		for(var/mob/M in src.mobselect)
			M.displayvector.Turn((360/picknum)/5)
			var/xoffset=0+round(M.displayvector.x*ovalness,1)
			if(xoffset>0)xoffset="+[xoffset]"
			else xoffset="-[abs(xoffset)]"
			var/newscreenloc ="CENTER:[xoffset],CENTER:+[round(96+M.displayvector.y,1)]"
			M.screen_loc=newscreenloc
		sleep(1)

	src.mob.selecting--
	if(src.mob.selecting<=0)src.mob.selecting=picknum
	src.select=src.mobselect[src.mob.selecting]
	busy=0

client/var/tmp/chatinit=0

mob/verb/say(i as text)
	world<<"[usr.client.name]: [i]"
	chat_say(_ftext(i,"lightgrey"))

client/New()
	clients+=src
	src.mob=new/mob/picking

	world.log<<"[src] is at [src.address] while world is [world.internet_address]"
	if(findtextEx(src.address,"192,168")||findtextEx(src.address,"10,0,0")||src.address==world.internet_address||!world.internet_address||!src.address)
		src.verbs+=/mob/admin/verb/MakeShiny
		src.verbs+=/mob/admin/verb/ChangeHue
		src.verbs+=/mob/admin/verb/Levelupflying
		winset(src, "menu_spawnai", list(parent = "menu.admin", name = "SpawnAI", command = "SpawnAI"))
		winset(src, "menu_raditz", list(parent = "menu.admin", name = "Raditz Fight", command = "RaditzFight"))
		winset(src, "menu_tournament", list(parent = "menu.admin", name = "Tournament", command = "Tournament"))
		winset(src, "menu_saibamen", list(parent = "menu.admin", name = "Saibamen Spawn", command = "SaibamenSeeding"))
		winset(src, "menu_restoreearth", list(parent = "menu.admin", name = "Restore Earth", command = "RestoreEarth"))
		winset(src, "menu_addskill", list(parent = "menu.admin", name = "Add Skill", command = "ChangeSkill"))
		winset(src, "menu_setpowerlevel", list(parent = "menu.admin", name = "Set Powerlevel", command = "change_powerlevel"))
		winset(src, "menu_playcustomlevel", list(parent = "menu.admin", name = "Play Custom Level", command = "PlayLevel"))
	else
		winset(src,"menu.admin","is-visible=0")
	..()


client/Del()
	_message(world, "[name] has logged out.", "yellow") // notify world
	clients-=src
	var/mob/M=src.mob
	M.loc=null
	M.client=null
	..()

mob/verb/spawnmob()
	var/list/M=typesof(/mob)
	M-=/mob
	M-=/mob/picking
	var/pick=input(usr,"Select a mob to spawn","Spawn") in M
	new pick (usr.pixloc)
/*
mob/verb/firebeams()
	sleep(10)
	world<<"ready"
	sleep(10)
	world<<"set"
	sleep(10)

	world<<"fire!"

	for(var/mob/M in world)
		if(!M.client)
			M.aim=Dir2Vector(M.dir)
			for(var/mob/m in oview(14,M))
				if(m.client)
					M.aim=m.pixloc-M.pixloc

			spawn()M.FireBeam(50,500,new M.special)
*/
var/punchin=0


mob/admin/verb/change_powerlevel(var/p=src.pl as num)

	src.Set_PL(p)


mob/proc/Set_PL(p)
	src.pl=p
	src.Refresh_Scouter()

mob/proc/Refresh_Scouter()
	var/text_pl
	if(src.pl>=10000000)
		text_pl="[round(src.pl/1000000,0.1)] M"
	else if(src.pl>=1000)
		text_pl=commafy(src.pl)
	else
		text_pl="[src.pl]"
	src.gui_pl.maptext="<span style='font-family:Calibri;font-size:12pt;'><font color=white>[text_pl]</span></font>"

atom/movable
	var/tmp
		vector/movevector=vector(0,0)
		usingskill=0
		canmove=1
		bouncing=0

mob/proc/Next_Skill()

	var/cur=1
	for(var/i=1 to src.skills.len)
		if(src.skills[i]==src.equippedskill)
			cur=i
	cur++
	if(cur>src.skills.len)cur=1
	src.equippedskill=src.skills[cur]
	src.client?.updateskillbar()

mob/proc/Prev_Skill()
	var/cur=1
	for(var/i=1 to src.skills.len)
		if(src.skills[i]==src.equippedskill)
			cur=i
	cur--
	if(cur<=0)cur=src.skills.len
	src.equippedskill=src.skills[cur]
	src.client?.updateskillbar()


mob/proc/Create_Aura(color)
	var/obj/O=new/obj
	var/obj/U=new/obj
	U.layer=MOB_LAYER-0.2
	O.layer=MOB_LAYER+0.1
	if(src.aura)del(src.aura)
	if(src.auraover)del(src.auraover)
	src.aura=U
	src.auraover=O
	U.icon='aura.dmi'
	O.icon='aura.dmi'
	U.icon_state="none"
	O.icon_state="none"
	O.alpha=80
	U.alpha=200
	O.pixel_x=-36
	U.pixel_x=-36
	U.pixel_z=-4
	O.pixel_z=-4
	var/col
	switch(color)
		if("Blue")
			col=rgb(50,80,180)
		if("White")
			O.alpha=50
			col=rgb(160,160,160)
		if("Yellow")
			O.alpha=50
			col=rgb(225,210,30)
		if("Lightyellow")
			O.alpha=50
			U.alpha=150
			col=rgb(255,240,150)
		if("Red")
			O.alpha=50
			col=rgb(225,50,50)
		if("Lightgreen")
			O.alpha=50
			U.alpha=150
			col=rgb(100,180,130)

		if("Purple")
			O.alpha=50
			col=rgb(222,132,255)
		if("SSJ2")
			O.alpha=50
			col=rgb(225,210,30)
			O.vis_contents+=new/obj/electricity
			U.vis_contents+=new/obj/dustup
		if("Lightningarmor")
			O.alpha=50
			col=rgb(255,240,150)
			O.transform=matrix().Scale(1.3).Translate(0,15)
			U.transform=matrix().Scale(1.3).Translate(0,15)
			O.vis_contents+=new/obj/lightning
			U.vis_contents+=new/obj/dustup
		if("Orange")
			O.alpha=50
			col=rgb(185,110,30)
			O.transform=matrix().Scale(1.3).Translate(0,15)
			U.transform=matrix().Scale(1.3).Translate(0,15)
			U.vis_contents+=new/obj/dustup
	U.icon+=col
	O.icon+=col

obj/electricity
	layer=MOB_LAYER+0.2
	icon='elec.dmi'
	bound_width=69
	bound_height=65
	pixel_w=14
	appearance_flags=RESET_ALPHA

obj/lightning
	layer=MOB_LAYER+0.2
	icon='lightning.dmi'
	bound_width=69
	bound_height=65
	pixel_w=14
	appearance_flags=RESET_ALPHA
obj/dustup
	appearance_flags=RESET_TRANSFORM|RESET_ALPHA
	icon='dustup.dmi'
	bound_width=256
	bound_height=96
	pixel_w=-80
	pixel_z=-48

mob/var/skills[]
mob/var/alist/unlocked[]
mob/var/tmp/spawnings[0]

mob/proc
	Kaioken()
		src.icon_state="transform"
		src.form="kaioken"
		src.icon_state=""
		src.Set_PL(round(src.basepl*4.2,1))
		src.Create_Aura("Red")
		src.vis_contents|=src.aura
		src.vis_contents|=src.auraover
		src.aura.icon_state="start"
		src.auraover.icon_state="start"

		sleep(2)
		src.aura.icon_state="aura"
		src.auraover.icon_state="aura"
		sleep(4)
		src.filters += filter(
			type = "color",,
		 	color = list(255,220,220)
		 	)

		src.aura.icon_state=""
		src.auraover.icon_state=""
		sleep(10)
		src.vis_contents-=src.aura
		src.vis_contents-=src.auraover

	Kaioken_end()
		src.icon_state=""
		src.Set_PL(round(src.basepl,1))
		src.form=null
		src.filters=null
		src.Create_Aura("White")

mob
	proc/Reset_Portrait()
		if(src.bdir==WEST)
			src.transform=null
			src.gui_portrait.appearance=src.appearance
			src.transform=new/matrix().Scale(-1,1)
		else
			src.gui_portrait.appearance=src.appearance


	proc/Transform()
		src.Reset_Portrait()
	proc/Revert()
		src.Reset_Portrait()
	dir=EAST


	goku
		name="Goku"
		icon='goku.dmi'
		oicon_state="goku"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9001
		special=/Beam/Kamehameha
		unlocked=alist("ssj"=1)
		behaviors=list(10,10,40,10,30) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		raditzfight
			pl=416
			unlocked=null
			New()
				..()
				spawn(1)
					for(var/Skill/Spiritbomb/S in src.skills)
						del(S)
		Transform()
			if(src.unlocked["ssj"])
				if(!form)
					src.icon_state="transform"
					sleep(6)
					src.icon='goku_ssj.dmi'
					src.form="SSJ"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))
					src.Create_Aura("Yellow")
				else return
			..()

		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='goku.dmi'
				src.form=null
				src.Create_Aura("White")
			..()



		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Spiritbomb,new/Skill/Spiritshot,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]

	vegeta
		name="Vegeta"
		icon='vegeta.dmi'
		oicon_state="vegeta2"
		portrait_yoffset=5
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38

		pl=9000
		special=/Beam/Galekgun
		unlocked=alist("ssj"=1)
		behaviors=list(5,5,25,40,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Blue")
			src.skills=list(new/Skill/Galekgun,new/Skill/Bigbangattack,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["ssj"])
				if(!form)
					src.icon_state="transform"
					sleep(6)
					src.icon='vegeta_ssj.dmi'
					src.form="SSJ"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))
					src.Create_Aura("Yellow")
				else return
			..()


		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='vegeta.dmi'
				src.form=null
				src.Create_Aura("Blue")
			..()

	piccolo
		name="Piccolo"
		icon='piccolo.dmi'
		oicon_state="piccolo"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Specialbeamcannon
		unlocked=alist("orange"=1)
		behaviors=list(5,25,25,20,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		raditzfight
			pl=408
			unlocked=null
		New()
			..()
			src.Create_Aura("Purple")
			src.skills=list(new/Skill/Specialbeamcannon,new/Skill/HellzoneGrenade,new/Skill/ExplosiveDemonWave,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["orange"] && !src.form)

				src.icon='piccolo_orange.dmi'
				src.bound_width=32
				src.bound_height=46
				src.icon_w=15
				src.icon_z=-14
				src.form="Orange"
				src.icon_state="transform"
				sleep(9)

				src.icon_state=""
				src.Set_PL(round(src.basepl*4.2,1))
				src.Create_Aura("Orange")
			..()
		Revert()
			if(form)
				src.icon_state="revert"
				src.bound_width=24
				src.bound_height=38
				src.icon_w=20
				src.icon_z=0
				sleep(4)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='piccolo.dmi'
				src.form=null
				src.Create_Aura("Purple")

			..()

	gohan
		name="Gohan"
		icon='gohan.dmi'
		oicon_state="gohan"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=28
		pl=6500
		basepl=6500
		special=/Beam/Masenko
		unlocked=alist("ssj"=1,"ssj2"=1)
		behaviors=list(25,25,10,10,30) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Masenko,new/Skill/Kamehameha,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["ssj"] && !src.form)
				src.icon_state="transform"
				sleep(6)
				src.icon='gohan_ssj.dmi'
				src.form="SSJ"
				src.icon_state=""
				src.Set_PL(round(src.basepl*4.2,1))
				src.Create_Aura("Yellow")
			else if(src.unlocked["ssj2"]&&src.form=="SSJ")
				src.icon_state="transform"
				sleep(8)
				src.icon='gohan_ssj2.dmi'
				src.form="SSJ2"
				src.icon_state=""
				src.Set_PL(round(src.basepl*6.4,1))
				src.vis_contents+=new/obj/personalelectricity
				src.Create_Aura("SSJ2")
			..()
		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='gohan.dmi'
				if(form=="SSJ2")
					for(var/obj/personalelectricity/E in src.vis_contents)src.vis_contents-=E
				src.form=null
				src.Create_Aura("White")

			..()

	tien
		name="Tienshinhan"
		icon='tien.dmi'
		oicon_state="tien"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Tribeam
		unlocked=alist("kaioken"=1)
		behaviors=list(15,5,30,10,45) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		Transform()
			if(src.unlocked["kaioken"])
				if(!form)
					src.Kaioken()
			..()
		Revert()
			if(form)
				src.Kaioken_end()
			..()
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Tribeam,new/Skill/Dondonpa,new/Skill/Solarflare,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	chaotzu
		name="Chaiotzu"
		icon='chaotzu.dmi'
		oicon_state="chaiotzu"
		icon_w=25
		icon_z=10
		bound_width=18
		bound_height=20
		pl=9000
		special=/Beam/Dondonpa
		behaviors=list(10,10,3,27,50) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Lightgreen")
			src.skills=list(new/Skill/Dondonpa,new/Skill/Spiritball,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	krillin
		name="Krillin"
		icon='krillin.dmi'
		oicon_state="krillin"
		icon_w=20
		icon_z=2
		bound_width=20
		bound_height=28
		pl=9000
		special=/Beam/Kamehameha
		unlocked=alist("kaioken"=1)
		behaviors=list(15,25,30,5,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Destructodisc,new/Skill/Kamehameha,new/Skill/Solarflare,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["kaioken"])
				if(!form)
					src.Kaioken()
			..()
		Revert()
			if(form)
				src.Kaioken_end()
			..()
	yamcha
		name="Yamcha"
		icon='yamcha.dmi'
		oicon_state="yamcha"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Kamehameha
		unlocked=alist("kaioken"=1)
		behaviors=list(15,5,50,10,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Spiritball,new/Skill/Wolffangfist,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]

		Transform()
			if(src.unlocked["kaioken"])
				if(!form)
					src.Kaioken()
			..()
		Revert()
			if(form)
				src.Kaioken_end()
			..()

	roshi
		name="Roshi"
		icon='roshi.dmi'
		oicon_state="roshi"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		flyinglevel=2
		special=/Beam/Kamehameha
		behaviors=list(10,10,20,10,50) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Spiritshot,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	trunks
		name="Trunks"
		icon='trunks.dmi'
		oicon_state="trunks"
		icon_w=32
		icon_z=0
		bound_width=24
		bound_height=28
		portrait_xoffset=-10
		pl=9000
		special=/Beam/Masenko
		kiblast=/obj/Kiblast/Sliceblast
		unlocked=alist("ssj"=1)
		behaviors=list(20,10,20,25,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Masenko,new/Skill/Burningattack,new/Skill/Kiblast/Slicing)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["ssj"] && !src.form)
				src.icon_state="transform"
				sleep(6)
				src.icon='trunks_ssj.dmi'
				src.form="SSJ"
				src.icon_state=""
				src.Set_PL(round(src.basepl*4.2,1))
				src.Create_Aura("Yellow")
			..()
		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='trunks.dmi'
				src.form=null
				src.Create_Aura("White")

			..()

	mrsatan
		name="Mr. Satan"
		icon='mrsatan.dmi'
		oicon_state="mrsatan"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=28
		portrait_xoffset=-10
		pl=45
		maxhp=1000
		hp=1000
		flyinglevel=0
		special=/Beam/Dondonpa
		kiblast=/obj/Kiblast/Gun
		behaviors=list(0,10,50,40,0) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kiblast/Gun)
			src.equippedskill=src.skills[1]
	raditz
		name="Raditz"
		icon='raditz.dmi'
		oicon_state="raditz"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Doublesunday
		behaviors=list(10,40,20,10,20) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		unlocked=alist("ssj"=1)
		Transform()
			if(src.unlocked["ssj"])
				if(!form)
					src.icon_state="transform"
					sleep(6)
					src.icon='raditz_ssj.dmi'
					src.form="SSJ"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))
					src.Create_Aura("Yellow")
				else return
			..()


		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='raditz.dmi'
				src.form=null
				src.Create_Aura("Purple")
			..()

		New()
			..()
			src.Create_Aura("Purple")
			src.skills=list(new/Skill/Doublesunday,new/Skill/Saturdaycrush,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	nappa
		name="Nappa"
		icon='nappa.dmi'
		oicon_state="nappa"
		icon_w=22
		icon_z=0
		bound_width=30
		bound_height=40
		portrait_yoffset=-15
		pl=9000
		special=/Beam/Mouthblast
		unlocked=new/alist("lightningarmor"=1)
		behaviors=list(10,25,30,5,30) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Lightyellow")
			src.skills=list(new/Skill/Explosivewave,new/Skill/Mouthblast,new/Skill/Energyblast,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["lightningarmor"])
				if(!form)
					src.icon_state="transform"
					src.Create_Aura("Lightningarmor")
					src.vis_contents|=src.aura
					src.vis_contents|=src.auraover
					src.aura.icon_state="start"
					src.auraover.icon_state="start"

					sleep(2)
					src.aura.icon_state="aura"
					src.auraover.icon_state="aura"
					sleep(4)
					src.form="lightningarmor"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))

					src.vis_contents+=new/obj/lightningarmor
					src.filters+=filter(type="outline",size=1,color=rgb(230,230,100))
					src.icon='nappa_lightning.dmi'
					src.aura.icon_state=""
					src.auraover.icon_state=""
					sleep(10)
					src.vis_contents-=src.aura
					src.vis_contents-=src.auraover
				else return
			..()


		Revert()
			if(form)
				src.Set_PL(src.basepl)
				src.form=null
				src.Create_Aura("Lightyellow")
				for(var/obj/lightningarmor/E in src.vis_contents)src.vis_contents-=E
				src.icon='nappa.dmi'
				src.filters=null
				sleep(5)
			..()
	cell
		name="Perfect Cell"
		icon='cell.dmi'
		oicon_state="cell"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=38000
		special=/Beam/Kamehameha
		unlocked=alist("celljr"=1)
		kiblast=/obj/Kiblast/Fingerlaser
		behaviors=list(5,35,25,10,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Yellow")

			src.skills=list(new/Skill/Kamehameha,new/Skill/Specialbeamcannon,new/Skill/Kiblast/Fingerlaser)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["celljr"])
				if(src.spawncount<6)
					src.spawncount++
					var/spl=round(src.pl/5,1)
					src.Set_PL(round(src.pl*4/5,1))
					src.icon_state="transform"
					src.canmove=0
					sleep(8)
					src.canmove=1
					var/mob/cjr=new/mob/celljr(bound_pixloc(src,0))
					cjr.team=src.team
					cjr.wanderrange=4
					cjr.aggrorange=1
					cjr.Set_PL(spl)
					src.spawnings+=cjr
					sleep(3)
					RefreshChunks|=cjr
					src.icon_state=""



	celljr
		name="Cell Jr."
		icon='celljr.dmi'
		oicon_state="celljr"
		icon_w=20
		icon_z=2
		portrait_yoffset=10
		bound_width=24
		bound_height=28
		pl=9000
		special=/Beam/Kamehameha
		behaviors=list(5,25,30,20,20) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Yellow")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Specialbeamcannon,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	saibamen
		name="Saibamen"
		oicon_state="saibamen"
		portrait_yoffset=10
		NPC
			team="Enemy"
			wanderrange=3
			aggrorange=1


		Cyan
			name="Saibamen (Cyan)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=90
			pl=4000
		Blue
			name="Saibamen (Blue)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=120
			pl=7000
		DarkBlue
			name="Saibamen (Dark Blue)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=150
			pl=10000

		Purple
			name="Saibamen (Purple)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=210
			pl=20000

		Magenta
			name="Saibamen (Magenta)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=255
			pl=35000
		Red
			name="Saibamen (Red)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=300
			pl=50000
		Orange
			name="Saibamen (Orange)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=330
			pl=300

		icon='saibamen.dmi'

		icon_w=25
		icon_z=10
		bound_width=18
		bound_height=20
		maxhp=50
		hp=50
		pl=1100
		special=/Beam/Masenko
		behaviors=list(5,40,30,10,15) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Lightgreen")
			src.skills=list(new/Skill/Masenko,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]

	var
		maxhp=100
		maxki=100
		ki=100
		team
		basepl=9000
	var/tmp
		mob/lastattacked
		mob/lastattackedby
		lasthostile
		dead=0
		special
		ap
		maxspeed=16
		minspeed=6
		rotation=0
		bdir=EAST
		autoblocks=0
		block=0
		attacking=0
		tossed=0
		hp=100
		pl=9000
		invulnerable=0
		vector/facing=vector(1,0)
		aiming=0
		vector/aim
		obj/aura
		obj/auraover
		charging=0
		obj/fade
		obj/fade2
		blocktime
		Beam/mybeam
		beamtime
		form
		counters=5
		maxcounters=5
		blocks=21
		maxblocks=21
		hpregen=5
		maxautoblocks=0
		npcrespawn=0

	step_size = 8

	icon='goku.dmi'







mob
	on_crossed(atom/A)

turf
//	Entered(mob/A)
	//	if(!A.client && A.detector && !A.targetmob)
	//		A.detector.Move((bound_pixloc(A,0)+vector(-224,-224)))
	//		if(A.detector2)A.detector2.Move((bound_pixloc(A,0)+vector(-448,-448)))
	//	..()

	//Move()
	//	..()
	//	if(!src.client && src.detector)
	//		Move(src.detector,(bound_pixloc(src,0)+vector(-224,-224)))

client
	var
		image/aimimage


mob/verb/give_mobs_blocks()
	for(var/mob/M in world)
		if(!M.client)
			M.autoblocks+=5


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

mob/proc/Gravity()
	set waitfor = 0
	if(src.falling)return
	sleep(2+src.flyinglevel*3)
	if(src.falling)return
	src.falling=1
	var/pace=-16+(src.flyinglevel*4)
	while(istype(src.loc,/turf/blank/sky))
		step(src,vector(0,pace))
		sleep(1)
	src.falling=0

mob/admin/verb/Levelupflying()
	var/mob/M=usr
	M.flyinglevel++
	if(M.flyinglevel>3)M.flyinglevel=0
	world.log<<"flying level is now [M.flyinglevel]"
mob/var/tmp/flyinglevel=3
mob/var/tmp/falling=0
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

	stages
		indestructible=1
		density=0
		layer=TURF_LAYER+0.1
		budokai
			icon='tournament.png'

obj
	stages
		density=0
		layer=TURF_LAYER+0.1

		budokai
			icon='backgrounds/budokai.dmi'
		city
			icon='backgrounds/city.png'
		desert
			icon='backgrounds/desert.jpg'
		plains
			icon='backgrounds/field.png'
		raditz
			icon='backgrounds/raditz.jpg'
		roadside
			icon='backgrounds/highway.png'
		rockydesert
			icon='backgrounds/rockydesert.jpg'
		vegeta
			icon='backgrounds/vegeta.jpg'
		namek
			icon='backgrounds/Namek.png'
		lookout
			icon='backgrounds/lookout.png'
		mountains
			icon='backgrounds/mountains.jpg'
		kamehouse
			icon='backgrounds/kamehouse.png'
		cellgames
			icon='backgrounds/cellgames.png'


world/turf=/turf/blank


mob/proc/Heal(heal)
	src.hp+=heal
	if(src.hp>src.maxhp)src.hp=src.maxhp
	gui_hpbar.setValue(src.hp/src.maxhp,10)

mob/var/tmp/storeddamage=0
mob/proc/Damage(damage,impact,critchance,mob/damager)
	if(src.team && src.team==damager.team)return 0
	if(!src.client && src.canaggro && (!src.targetmob||src.aggrotag))
		src.Detect(damager)
	var/vector/v=src.pixloc-damager.pixloc
	var/crit=prob(critchance)
	damager.lastattacked=src
	damager.Show_target(src)
	src.lastattackedby=damager
	src.lasthostile=world.time
	damager.lasthostile=world.time
	src.Show_target(damager)
	storeddamage++
	if(src.block)src.storedblock++
	if(crit)
		src.Flash(1.5,100)
		v.size=impact*10
		src.hp-=damage*3
		var/vector/diff=(bound_pixloc(damager,0)-bound_pixloc(src,0))
		diff.size=8
		Explosion(/obj/FX/Smash,bound_pixloc(src,0)+diff)
		src.sendflying(v,(v.size*3+300),16)
	else
		src.Flash(0.5,30)
		v.size=impact
		src.hp-=damage
		if(src.hp<=0)src.invulnerable=1
		src.knockback(v,v.size,16)
	gui_hpbar.setValue(src.hp/src.maxhp,10)
	if(src.hp<=0)
		src.Die(damager)
mob/proc
	Die(mob/damager)
		if(src.dead)return
		src.Standstraight()
		if(src.spawnings.len)
			for(var/mob/S in src.spawnings)
				spawn()S.Die()
		src.invulnerable=1
		src.vis_contents=null
		src.dead=1
		src.density=0
		src.client?.edge_limit=null
		src.canmove=0
		src.Clear_target()
		var/state
		if("dead" in icon_states(src.icon))
			src.icon_state="dead"
			state="dead"
		else
			src.icon_state="hurt1"
			state="hurt1"

		if(damager)
			world<<"[src] has been killed by [damager]"
			_message(world, "[src] has been killed by [damager]", rgb(200,100,100))

		if(damager)damager.Clear_target()
		var/matrix/M=src.transform
		if(state=="hurt1")M.Turn(-60)


		animate(src,transform=M,time=3)
		while(src.loc?:ground==0)
			src.Move(vector(0,-16))
			sleep(world.tick_lag)

		if(src.holdskill)
			src.holdskill:loc=null
			src.holdskill=null
		if(src.client)src.client.keydown=new/alist()
		sleep(20)
		src.icon_state=state

		if(src.client?.inbattle)
			while(src.client && src.client.inbattle)
				sleep(20)
			animate(src,alpha=0,time=30)
			src.loc=null
			if(src.client)
				src.client.overworld=0
				src.client.oworldpixloc=null
				src.client.Character_Select()
		else
			animate(src,alpha=0,time=30)
			sleep(100)
			if(!src.client)
				src.loc=null
				if(src.npcrespawn)
					sleep(1000)
					src.hp=src.maxhp
					src.alpha=255
					src.icon_state=""
					src.ki=src.maxki
					src.pl=src.basepl
					src.density=1
					src.dead=0
					src.invulnerable=0
					src.canmove=1
					src.loc=src.initloc
			else
				src.client.overworld=0
				src.client.oworldpixloc=null
				src.client.Character_Select()




mob/var/tmp/obj/hitbox
mob/proc/Punch(mob/hit)
	set waitfor = 0
	if(!src.attacking)

		src.attacking=1
		var/dist=999
		var/vector/gap
		var/mob/t
		var/backstab
		var/counter=0
		var/mob/T=src.Target()
		var/vector/aim
		if(T)
			aim=T.pixloc-src.pixloc
			if(aim.size>40)T=null
		if(!T)aim= Dir2Vector(src.dir)

		var/i=40
		while(i>0)
			src.step_size=src.maxspeed
			aim.size=src.step_size
			Move(src.pixloc+aim)
			sleep(world.tick_lag)
			i-=src.step_size
		aim.size=30
		if(hit) t=hit
		else
			for(var/mob/M in bounds(bound_pixloc(src,src.dir)+aim,30))

				if(M.invulnerable||M==src)continue
				gap=M.pixloc-src.pixloc
				if(gap.size<dist && gap.size<=src.bound_width+30)
					dist=gap.size
					t=M
		src.canmove=0
		var/blocked=0
		if(t)

			var/duration
			src.Face(t)
			duration=world.time-t.blocktime
			if(duration<=2 && t.counters>0)
				counter=1
				t.counters--
				t.Update_Counters()
				t.Counter(src)

			if(src.Backstab(t))
				backstab=1
			else
				if(t.autoblocks>0&&t.blocks>0)
					t.Block()
					t.autoblocks--
					t.blocks--
					t.Update_Blocks()
					blocked=1
				if(t.icon_state=="block"&&t.blocks>0)
					blocked=1
					t.blocks--
					t.Update_Blocks()
			src.Move(src.pixloc+gap)
			gap.size=8
			animate(src,pixel_x=pixel_x+gap.x,pixel_y=pixel_y+gap.y,time=2,flags=ANIMATION_PARALLEL)
			animate(src,pixel_x=0,pixel_y=0,delay=3,time=2,flags=ANIMATION_PARALLEL)



		animate(src,icon_state="punch1",time=2,flags=ANIMATION_PARALLEL)
		animate(src,icon_state="punch2",time=2,delay=2,flags=ANIMATION_PARALLEL)
		sleep(2)
		if(t)
			spawn()
				if(!blocked&&!counter)
					var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
					mid.size=mid.size/2
					Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid))
				else if(blocked)
					var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
					mid.size=mid.size/2
					Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.5,0.5)
		if(t&&!counter)spawn()t.Damage(3*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*20*(1- blocked+backstab),src)
		sleep(2)
		src.attacking=0
		src.CheckCanMove()
		if(src.client?.movekeydown&&!src.dead) src.icon_state="dash2"
		else if(!src.dead) src.icon_state=""

mob/proc/Kick(mob/hit)
	set waitfor = 0
	if(!src.attacking)
		src.attacking=1
		var/dist=999
		var/vector/gap
		var/mob/t
		var/backstab
		var/counter=0
		var/mob/T=src.Target()
		var/vector/aim
		if(T)
			aim=T.pixloc-src.pixloc
			if(aim.size>60)T=null
		if(!T)aim= Dir2Vector(src.dir)

		var/i=60
		while(i>0)
			src.step_size=src.maxspeed
			aim.size=src.step_size
			Move(src.pixloc+aim)
			sleep(world.tick_lag)
			i-=src.step_size
		aim.size=40
		if(hit) t=hit
		else
			for(var/mob/M in bounds(bound_pixloc(src,src.dir)+aim,40))
				if(M.invulnerable||M==src)continue
				gap=M.pixloc-src.pixloc
				if(gap.size<dist && gap.size<=src.bound_width+40)
					dist=gap.size
					t=M

		src.canmove=0
		var/blocked=0

		if(t)
			src.Face(t)
			var/duration
			if(t.client)
				duration=world.time-t.client.keydown["D"]
				if(duration<=2 && t.counters>0)
					counter=1
					t.counters--
					t.Update_Counters()
					t.Counter(src)
			if(src.Backstab(t))
				backstab=1
			else
				if(t.autoblocks>0&&t.blocks>2)
					t.Block()
					t.autoblocks--
					t.blocks-=3
					t.Update_Blocks()
					blocked=1
				if(t.icon_state=="block"&&t.blocks>2)
					blocked=1
					t.blocks-=3
					t.Update_Blocks()
			src.Move(src.pixloc+gap)
			gap.size=8
			animate(src,pixel_x=pixel_x+gap.x,pixel_y=pixel_y+gap.y,time=2,flags=ANIMATION_PARALLEL)
			animate(src,pixel_x=0,pixel_y=0,delay=3,time=2,flags=ANIMATION_PARALLEL)



		animate(src,icon_state="kick1",time=2,flags=ANIMATION_PARALLEL)
		animate(src,icon_state="kick2",time=2,delay=2,flags=ANIMATION_PARALLEL)
		sleep(2)
		if(t)
			spawn()
				if(!blocked&&!counter)
					var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
					mid.size=mid.size/2
					Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid))
				else if(blocked)
					var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
					mid.size=mid.size/2
					Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.5,0.5)
		if(t&&!counter)spawn()t.Damage(9*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*50*(1- blocked+backstab),src)
		sleep(2)
		src.attacking=0
		src.CheckCanMove()
		if(src.client?.movekeydown&&!src.dead) src.icon_state="dash2"
		else if(!src.dead)src.icon_state=""


proc/PLcompare(mob/atk,mob/def)
	var/ratio=atk.pl/def.pl
//	world<<"ratio [ratio]"
	if(ratio>100)return 4
	else if(ratio>10) return 3
	else if(ratio>5) return 2
	else if(ratio>3) return 1.5
	else if(ratio>2) return 1.3
	else if(ratio>1.7) return 1.2
	else if(ratio>1.5) return 1.15
	else if(ratio>1.3) return 1.1
	else if(ratio>1.1) return 1.05
	else if(ratio>=1) return 1
	else if(ratio>0.8) return 0.9
	else if(ratio>0.6) return 0.8
	else if(ratio>0.5) return 0.7
	else if(ratio>0.4) return 0.6
	else if(ratio>0.3) return 0.5
	else if(ratio>0.2) return 0.4
	else if(ratio>0.1) return 0.35
	else if(ratio>0.01) return 0.25
	else return 0.20



mob/proc/Block()
	set waitfor = 0
	animate(src,icon_state="block",time=4)
	src.movevector=vector(0,0)
	sleep(4)
	if(src.dead)return
	if(src.client?.movekeydown) src.icon_state="dash2"
	else src.icon_state=""


obj
	step_size = 8
client
	var
		alist/keydown
		movekeydown=0

mob/proc/RotateMob(vector/V,weight=100)
	var/angle=round(arctan(V),1)
	if(src.bdir==WEST && angle==90)angle=90.1
	var/flip=1
	if(bdir==EAST)
		if(angle>90)
			angle-=180
			bdir=WEST
			flip=-1
		if(angle<-90)
			angle+=180
			bdir=WEST
			flip=-1
	else

		if(angle<90 && angle>-90)
			bdir=EAST
		else
			if(angle>=90)
				angle-=180
				flip=-1
			if(angle<=-90)
				angle+=180
				flip=-1

	if(flip==1)bdir=EAST

	var/matrix/M=new/matrix()
	src.rotation=(clamp(src.rotation,-30,30)*(100-weight)+angle*weight)/100
	M.Scale(flip,1)
//	world<<"[src.rotation]"
	M.Turn(-src.rotation)
	src.transform=M

mob/proc/Counter(mob/M)

	var/obj/fade=new/obj(src.pixloc)
	fade.icon='fade.dmi'
	var/obj/olay=new/obj
	olay.appearance=src
	olay.blend_mode=BLEND_INSET_OVERLAY
	fade.blend_mode=BLEND_MULTIPLY
	fade.appearance_flags=KEEP_TOGETHER
	fade.vis_contents+=olay

	if(M)
		if(!M.client)M.stunned=world.time+20
		else M.stunned=world.time+5
		var/vector/V=M.pixloc-src.pixloc
		V.size=V.size*2
		var/pixloc/destination=src.pixloc+V
		var/turf/T=destination.loc
		if(T&&!T.density)
			src.pixloc=destination
		src.Face(M)


	spawn(5)
		fade.loc=null
		fade.vis_contents-=olay

mob/var/tmp/chargecd

client
	New()
		. = ..()
		winset(src, "AnyMacro", list(
			name = "Any",
			parent = "macro",
			command = @"keydownverb [[*]]"))
		winset(src, "AnyMacroUp", list(
			name = "Any+Up",
			parent = "macro",
			command = @"keyupverb [[*]]"))

client/proc/GamePad2Key(button, keydown)
	var/b
	switch(button)
		if("GamepadFace1","Gamepad2Face1")b="D"
		if("GamepadFace2","Gamepad2Face2")b="A"
		if("GamepadFace3","Gamepad2Face3")b="F"
		if("GamepadFace4","Gamepad2Face4")b="S"

		if("GamepadL1","Gamepad2L1")b="Q"
		if("GamepadR1","Gamepad2R1")b="W"
		if("GamepadL2","Gamepad2L1")b="-"
		if("GamepadR2","Gamepad2R1")b="="
		if("GamepadLeft","Gamepad2Left")b="West"
		if("GamepadRight","Gamepad2Right")b="East"
		if("GamepadUp","Gamepad2Up")b="North"
		if("GamepadDown","Gamepad2Down")b="South"
		if("GamepadSelect","Gamepad2Select")b="Escape"
		if("GamepadUpLeft","Gamepad2UpLeft")b="Northwest"
		if("GamepadDownLeft","Gamepad2DownLeft")b="Southwest"
		if("GamepadUpRight","Gamepad2UpRight")b="Northeast"
		if("GamepadDownRight","Gamepad2DownRight")b="Southeast"

	if(b)
		if(!src.keydown)src.keydown=new/alist()
		spawn()
			if(keydown)//&&!src.keydown[b])
				src.keydownverb(b)
			else if(b&&src.keydown[b])
				src.keyupverb(b)
client/var/dashkey
client/var/lasttapped[2]
client/verb/keydownverb(button as text)
	set instant=1
	set hidden = 1


	//if the user has a focus target, call onKeyDown() on the focus target.
	//if the object returns null or 0 (or doesn't return anything), stop this input from propagating further.
	//the focus target can return a true value with some or no keys to allow this input to propagate.
	if(src.indialogue)
		if(button=="South"||button=="East"||button=="GamepadRight"||button=="GamepadDown")
			src.NextChoice()
		else if(button=="North"||button=="West"||button=="GamepadLeft"||button=="GamepadUp")
			src.PrevChoice()
		return
	if(src.pickinglevel)
		switch(button)
			if("North","GamepadUp")src.Navigate(NORTH)
			if("South","GamepadDown")src.Navigate(SOUTH)
			if("East","GamepadRight")src.Navigate(EAST)
			if("West","GamepadLeft")src.Navigate(WEST)
			if("NorthEast","GamepadUpRight")src.Navigate(NORTHEAST)
			if("SouthEast","GamepadDownRight")src.Navigate(SOUTHEAST)
			if("NorthWest","GamepadRight")src.Navigate(NORTHWEST)
			if("SouthWest","GamepadLeft")src.Navigate(SOUTHWEST)
		return

	if(focus_target && !focus_target.onKeyDown(button))
	//	world.log<<button
		return
//	world.log<<button
	if(button=="GamepadL3")
		src.ChangeMoveMode()
		return
	if(button=="GamepadR3")
		src.SayGamepad()
		return
	if(button=="GamepadSelect"||button=="Gamepad2Select"||button=="GamepadFace1"||button=="GamepadFace2"||button=="GamepadFace3"||button=="GamepadFace4"||button=="GamepadL1"||button=="GamepadR1"||button=="GamepadL2"||button=="GamepadR2"||button=="GamepadLeft"||button=="GamepadRight"||button=="GamepadUp"||button=="GamepadDown"||button=="GamepadUpLeft"||button=="GamepadDownLeft"||button=="GamepadUpRight"||button=="GamepadDownRight"||button=="Gamepad2Face1"||button=="Gamepad2Face2"||button=="Gamepad2Face3"||button=="Gamepad2Face4"||button=="Gamepad2L1"||button=="Gamepad2R1"||button=="Gamepad2L2"||button=="Gamepad2R2"||button=="Gamepad2Left"||button=="Gamepad2Right"||button=="Gamepad2Up"||button=="Gamepad2Down"||button=="Gamepad2UpLeft"||button=="Gamepad2DownLeft"||button=="Gamepad2UpRight"||button=="Gamepad2DownRight")
	//	world<<"[button] passed to GamePad2Key"
		src.GamePad2Key(button,1)
		return
	var/mob/M=src.mob

	if(M.selecting)
		src.SelectingInput(button)
		return
	if(M.dead||M.icon_state=="transform")return
	if(!src.keydown)src.keydown=new/alist()

	if((src.keydown["D"]&&button=="S")||button=="="&&!src.overworld)
		M.Transform()
		return
	var/tapbetween
	if(src.lasttapped[1]==button)
		tapbetween=world.time-src.lasttapped[2]


	if(M.stunned&&M.stunned>world.time)
		return
	else
		if(M.stunned)M.stunned=0
	src.keydown[button]=world.time

	var/starttime=world.time

	src.lasttapped[1]=button
	src.lasttapped[2]=world.time
	if((src.keydown["D"]&&src.keydown["South"]&&M.form&&!src.movekeydown)||button=="-"&&!src.overworld)
		M.Revert()
	if((src.keydown["F"]||(src.keydown["D"]&&src.keydown["North"]))&&world.time>M.chargecd&&!src.overworld) //charge
		if(!M.charging&&!M.aiming)
			if(M.block)
				M.block=0
				if(M.icon_state=="block")
					M.icon_state=""

			M.charging=1
			M.canmove=0
			M.aura.icon_state="none"
			M.auraover.icon_state="none"
			M.vis_contents|=M.aura
			M.vis_contents|=M.auraover
			M.aura.icon_state="start"
			M.auraover.icon_state="start"
			if(M.bdir==EAST)
				M.transform=matrix()
				M.rotation=0
			else
				M.transform=matrix().Scale(-1,1)
				M.rotation=0
			spawn()
				while(M.charging&&src.keydown[button]==starttime)
					M.chargecd=world.time+15
					if(M.ki<M.maxki)
						M.Get_Ki(min((M.maxki-M.ki),10))
					sleep(5)


			spawn(3)
				M.aura.icon_state="aura"
				M.auraover.icon_state="aura"



	else
		if(button=="D"&&!M.dead&&!src.overworld)
			M.icon_state="block"
			M.block=1
			M.canmove=0
			M.blocktime=world.time

	if(button=="S"&&M.canmove&&!M.block&&!M.usingskill&&!M.charging&&!src.overworld)
		var/chargestate=M.equippedskill?.state1
		if((chargestate in icon_states(M.icon)))
			M.icon_state=chargestate
		else M.icon_state="blast1"
		M.canmove=0
		M.movevector=vector(0,0)
		M.aiming=1
		if(M.facing&&M.facing.size)M.aim=vector(M.facing)
		else
			M.aim=vector(0,0)
		M.gui_charge.setValue(0)
		var/atom/Veye=src.virtual_eye
		var/mob/Eye=src.eye
		if(Eye!=Veye)
			var/offx=(Eye.x-Veye.x)*32+round(Eye.step_x,1)-4
			var/offy=(Eye.y-Veye.y)*32+round(Eye.step_y,1)-32
			if(offx>0)offx="+[offx]"
			else offx="[offx]"
			if(offy>0)offy="+[offy]"
			else offy="[offy]"
			M.gui_charge.screen_loc="CENTER:[offx] ,CENTER:[offy]"

		else
			M.gui_charge.screen_loc="CENTER ,CENTER:-16"

		if(M.equippedskill)
			src.screen|=M.gui_charge
			M.gui_charge.setValue(1,M.equippedskill.ctime)

		src.ShowAim()
		spawn(M.equippedskill.ctime)
			if(src.keydown["S"]&&src.keydown["S"]==starttime)
				M.ChargeSkill()
	else
		if(button=="S"&&M.usingskill&&M.mybeam.clash)
			M.beamtime=world.time
	if(M.usingskill)return

	if(button=="North"||button=="South"||button=="East"||button=="West"||button=="Northeast"||button=="Southeast"||button=="Northwest"||button=="Southwest")
		src.movekeydown=1
		if(!M.charging)
			src.UpdateMoveVector()
		if(tapbetween&&tapbetween<=2&&M.counters>=1&&!M.aiming) //doubletap!
			src.dashkey=button
			M.counters--
			M.Update_Counters()
			spawn(world.tick_lag)M.Charge()


	if(M)activemobs|=M

client/verb/keyupverb(button as text)
	set hidden = 1
	set instant=1

	//if the user has a focus target, call onKeyUp() on the focus target.
	//if the object returns null or 0 (or doesn't return anything), stop this input from propagating further.
	//the focus target can return a true value with some or no keys to allow this input to propagate.
	if(src.indialogue)

		if(button=="A"||button=="GamepadFace2"||button=="Enter"||button=="Space")
			src.MakeChoice()
		return
	if(src.pickinglevel)
		if(button=="A"||button=="GamepadFace2"||button=="Enter"||button=="Space")
			src.Select()
		return

	if(focus_target && !focus_target.onKeyUp(button))
		return
	if(button=="GamepadSelect"||button=="Gamepad2Select"||button=="GamepadFace1"||button=="GamepadFace2"||button=="GamepadFace3"||button=="GamepadFace4"||button=="GamepadL1"||button=="GamepadR1"||button=="GamepadLeft"||button=="GamepadRight"||button=="GamepadUp"||button=="GamepadDown"||button=="GamepadUpLeft"||button=="GamepadDownLeft"||button=="GamepadUpRight"||button=="GamepadDownRight"||button=="Gamepad2Face1"||button=="Gamepad2Face2"||button=="Gamepad2Face3"||button=="Gamepad2Face4"||button=="Gamepad2L1"||button=="Gamepad2R1"||button=="Gamepad2Left"||button=="Gamepad2Right"||button=="Gamepad2Up"||button=="Gamepad2Down"||button=="Gamepad2UpLeft"||button=="Gamepad2DownLeft"||button=="Gamepad2UpRight"||button=="Gamepad2DownRight")
		src.GamePad2Key(button,0)
		return
	var/mob/M=src.mob
	if(M.stunned&&M.stunned>world.time)
		if(src.keydown[button])
			sleep(M.stunned-world.time)
		else
			return
	else
		if(M.stunned)M.stunned=0

	if(button==src.dashkey)
		M.Chargestop()
		src.dashkey=null
	if(M.selecting)
		return
	if(button=="Escape")
		if(src.oworldpixloc)src.VisitOverworld()
		else M.ChangePlayer()
		return
	if(M.dead)
		return
	var/i=0
	while(M.icon_state=="transform"&&i<20)
		i++
		sleep(1)


	if(button=="W"&&!src.keydown["S"])M.Next_Skill()
	else if(button=="Q"&&!src.keydown["S"])M.Prev_Skill()
	if(!src.overworld)
		if(button=="A")
			var/duration=world.time-src.keydown[button]
			M.Melee(duration)
		//	if(duration>5)M.Kick()
		//	else M.Punch()
		if((button=="D"&& M.charging)||(button=="North"&& M.charging)||(button=="F" && M.charging))
			M.charging=0
			M.aura.icon_state="end"
			M.auraover.icon_state="end"
			M.CheckCanMove()
			spawn(3)
				if(!M.charging)
					M.aura.icon_state="none"
					M.auraover.icon_state="none"

					M.vis_contents-=M.aura
					M.vis_contents-=M.auraover

		else if(button=="D")
			M.block=0
			if(M.icon_state=="block")
				if(src.movekeydown && !M.charging)
					M.icon_state="dash2"
				else
					M.icon_state=""
			M.CheckCanMove()
			if(M.storedblock>=3)M.Repulse(min(160,M.storedblock*16))
			M.storedblock=0

		if(button=="S" && !M.usingskill &&src.keydown["S"])
			M.aiming=0
			src.HideAim()
			var/skilltime=world.time-src.keydown[button]
			src.screen-=M.gui_charge
			if(!M.equippedskill)M.equippedskill=M.skills[1]
			if(skilltime>=M.equippedskill.ctime)
				M.UseSkill(world.time-src.keydown[button])
			else
				src.keydown[button]=null
				M.UseKiBlast()

		else if(button=="S" && !M.usingskill)
			M.aiming=0
			src.HideAim()
			src.screen-=M.gui_charge
			M.usingskill=0
			M.canmove=1
			if(!M.dead)M.icon_state=""
	else
		if(button=="A")
			var/turf/T=get_step(src.mob,src.mob.dir)
			for(var/obj/overworld/O in T)
				O.Activate(M)
				return
			for(var/obj/overworld/O in view(1,T))
				O.Activate(M)
				return
			for(var/obj/overworld/O in view(2,T))
				O.Activate(M)
				return
			for(var/mob/O in view(2,T))
				if(O!=src.mob && O.client)
					src.Talkto(O.client)

					return
	src.keydown?.Remove(button)


	if(button=="North"||button=="South"||button=="East"||button=="West"||button=="Northeast"||button=="Southeast"||button=="Northwest"||button=="Southwest")
		src.UpdateMoveVector()
		if(!(src.keydown["North"]||src.keydown["South"]||src.keydown["East"]||src.keydown["West"]||src.keydown["Northeast"]||src.keydown["Southeast"]||src.keydown["Northwest"]||src.keydown["Southwest"]))
			src.movekeydown=0
			if(M.dashing)
				M.Chargestop()
				src.dashkey=null
	if(length(src.keydown)==0 && (!M.movevector || M.movevector.size<=1)) activemobs-=M


client/proc/Talkto(client/C)
	var/choice=src.ShowDialogue("[C.name]","How do you want to interact with this Player?",list("PVP Challenge","Custom Fight (PVP)","Custom Fight (Coop)","Leave"))
	switch(choice)
		if("PVP Challenge")
			var/response=C.ShowDialogue("[src.name]","[src.name] wants to duel you!",list("No thanks","Sure!"))
			if(response=="Sure!")
				src.PVP(C)
		if("Custom Fight (PVP)")
			var/response=C.ShowDialogue("[src.name]","[src.name] wants to fight you in a custom match",list("No thanks","Sure!"))
			if(response=="Sure!")
				var/list/players[8]
				players[5]=C
				Customfight(players)
		if("Custom Fight (Coop)")
			var/response=C.ShowDialogue("[src.name]","[src.name] wants to fight you in a custom match",list("No thanks","Sure!"))
			if(response=="Sure!")
				var/list/players[8]
				players[2]=C
				Customfight(players)


mob/var/tmp
	obj/dash
	obj/dash2
	dashing=0

mob/proc
	Charge()
		if(!src.dashing && !src.client?.overworld)
			var/mob/target
			var/X=0
			var/Y=0
			if(src.dir==NORTH||src.dir==NORTHEAST||src.dir==NORTHWEST)Y=0.5
			else if(src.dir==SOUTH||src.dir==SOUTHEAST||src.dir==SOUTHWEST)Y=-0.5
			if(src.dir==WEST||src.dir==NORTHWEST||src.dir==SOUTHWEST)X=-1
			else if(src.dir==EAST||src.dir==NORTHEAST||src.dir==SOUTHEAST)X=1

			var/list/mobs=new/list
			for(var/turf/T in block(src.x-8+X*7,src.y-8+Y*7,src.z,src.x+8+X*7,src.y+Y*7+8))
				for(var/mob/M in T)
					if(M!=src)mobs+=M
			if(src.targetmob in mobs)
				target=src.targetmob
			else if(src.lastattacked in mobs)
				target=src.lastattacked
			else if(src.lastattackedby in mobs)
				target=src.lastattackedby
			else if(mobs.len)
				target=pick(mobs)

			if(!target)return


			var/obj/A
			var/obj/B

			if(src.dash)
				A=src.dash
			else
				A=new/obj
			if(src.dash2)
				B=src.dash2
			else
				B=new/obj
			A.layer=MOB_LAYER+0.1
			A.density=0
			A.icon=aura.icon
			A.icon_state="dash"
			A.alpha=100
			A.bound_width=80
			A.bound_height=106
			A.pixel_y=-26
			A.pixel_w=-16
			A.bound_x=20
			A.bound_y=5
			B.layer=OBJ_LAYER
			B.density=0
			B.icon=aura.icon
			B.icon_state="dash"
			B.alpha=180
			B.bound_width=80
			B.bound_height=106
			B.pixel_y=-26
			B.pixel_w=-16
			B.bound_x=20
			B.bound_y=5
			src.dash=A
			src.dash2=B
			src.dashing=1
			src.vis_contents+=src.dash
			src.vis_contents+=src.dash2
			src.icon_state="dash2"
			var/oldstep=src.step_size
			var/i=0
			while(src.dashing && src.ki>1)
				i++
				if(i>=5)
					src.Take_Ki(1)
					i=0
				var/vector/stepvector=target.pixloc-src.pixloc
				src.step_size=src.maxspeed
				stepvector.size=src.step_size
				Move(src.pixloc+stepvector)
				sleep(world.tick_lag)
			src.step_size=oldstep
			if(src.icon_state=="dash2")src.icon_state=""



	Chargestop()
		src.vis_contents-=src.dash
		src.vis_contents-=src.dash2
		src.dashing=0


client/proc/ShowAim()
	if(!src.aimimage)
		src.aimimage=new/image('aim.dmi',src.mob)
		src.aimimage.appearance_flags=RESET_TRANSFORM
	else
		src.aimimage.loc=src.mob
	var/matrix/m=new/matrix()

	var/vector/offset
	if(src.mob.aim&&istype(src.mob.aim,/vector)&&src.mob.aim.size)
		offset=vector(src.mob.aim)
		offset.size=32
	else
		offset=src.mob.AutoAim(Dir2Vector(dir))
		offset.size=32
	if(!offset || !offset.size)
		offset=Dir2Vector(src.mob.dir)
		offset.size=32

	src.mob.aim=offset
	var/angle=vector2angle(src.mob.aim)
	if(src.mob.aim&&src.mob.aim.size)m.Turn(angle)
	src.aimimage.transform=m
	src.aimimage.pixel_x=4
	src.aimimage.pixel_y=22
	src.aimimage.pixel_x+=offset.x
	src.aimimage.pixel_y+=offset.y
	var/flip=1
	if(src.mob.bdir==EAST)
		if(angle>90)
			angle-=180
			src.mob.bdir=WEST
			flip=-1
		if(angle<-90)
			angle+=180
			src.mob.bdir=WEST
			flip=-1
	else
		if(angle<90 && angle>-90)
			src.mob.bdir=EAST
			flip=-1

	src.mob.transform.Scale(flip,1)
	src.images|=src.aimimage
	if(src.autoaim)
		sleep(2)
		var/mob/targ=src.mob.Target()
		if(src.autoaim&&(src.aimimage in src.images)&&targ&&targ.pixloc)
			src.mob.aim=targ.pixloc-src.mob.pixloc
			spawn()src.ShowAim()

client/proc/HideAim()
	if(src.aimimage in src.images)src.images-=src.aimimage

client/var/autoaim=1

client/var/movemode="tight"
client/verb/ChangeMoveMode()
	if(movemode=="tight")
		src<<"movement mode: loose"
		movemode="loose"
	else
		src<<"movement mode: tight"
		movemode="tight"



//	world<<"UpdateMoveVector [V], [V.size]"

var/regentick=0
var/regenworldtick=0
world/Tick()
	var/regen=0
	regentick++
	regenworldtick++
	if(regenworldtick>5000)
		regenworldtick=0
		spawn()Restore()
	if(regentick==50)
		regen=1
		regentick=0
	for(var/C in clients)
		var/title="([world.cpu]%)"
		winset(C, "mainwindow", "title=[title]")
		var/mob/M = C:mob
		if(M)
			if(!M.attacking&&M.canmove && !M.tossed&&(!M.stunned||M.stunned<=world.time))
				M.client?.UpdateMoveVector()
				try
					if(M.client?.movemode=="tight")
						if(!(M.PixelMove(M.movevector)))
							M.movevector=vector(0,0)
					else
						if(!(M.Move(M.pixloc+M.movevector)))
							M.movevector=vector(0,0)

				catch
				if(regen && (world.time-M.lasthostile)>60)
					if(M.hp<M.maxhp)
						M.hp=min(M.maxhp,M.hp+M.hpregen)
						M.gui_hpbar.setValue(M.hp/M.maxhp,10)

				if(regen && (world.time-M.lasthostile)>20)
					if(M.blocks<M.maxblocks)
						M.blocks=min(M.blocks+2,M.maxblocks)

						M.Update_Blocks()
					if(M.counters<M.maxcounters)
						M.counters++
						M.Update_Counters()
	AI_Loop()
	for(var/mob/M in RefreshChunks)
		RefreshChunks-=M
		spawn()M.Chunkupdate()

var/clients[0]

mob/proc/Standstraight()
	if(src.bdir==EAST)
		src.transform=matrix()
		src.rotation=0
	else
		src.transform=matrix().Scale(-1,1)
		src.rotation=0

mob/var/autoattack=0
//bumping code
mob
	Bump(atom/o)
		..()
		if(src.dashing)src.Chargestop()
		if(istype(o,/mob))
			var/mob/M=o
			if(M.dashing)M.Chargestop()

			var/vector/kbvector
			if(src.movevector)kbvector=vector(src.movevector)
			else kbvector=vector(0,0)
			kbvector+=(M.pixloc-src.pixloc)

			if(src.client)
				if(src.client.overworld)return
				if(src.client.keydown["A"]&&src.autoattack)
					spawn()
						if(!src.attacking)
							var/duration=world.time-src.client?.keydown["A"]
							src.Melee(duration)
						//	if(duration>5)src.Kick()
						//	else src.Punch()
							src.client?.keydown["A"]=world.time


				else

					if(M.canmove&&!M.tossed)
						kbvector.size=4
						M.Move(M.pixloc+kbvector)
				return
			else
				if(src.posture)
					var/duration=world.time-src.posturetime
					src.Melee(duration)
				//	if(duration>5)src.Kick()
				//	else src.Punch()
					src.posturetime=world.time

		if(src.bouncing && src.canmove)src.bouncing=0
		if(src.bouncing)return
		else
			src.bounce(o)


mob/proc/knockback(vector/V,distance,rate)
	if(tossed)return
	var/vector/v=vector(V)
	v.size=distance
	var/vector/S=vector(v)
	S.size=rate
	src.canmove=0
	var/oldglide=src.glide_size

	while(distance>0)
		if(distance<rate)
			rate=distance
			S.size=rate
		src.step_size=src.glide_size=rate
		src.Move(src.pixloc+S)
		distance-=rate

		sleep(world.tick_lag)
	src.glide_size=oldglide
	sleep(1)
	src.Move(0)
	src.CheckCanMove()


mob/proc/sendflying(vector/V,distance,rate)
	if(tossed)return
	src.tossed=1
	var/vector/v=vector(V)
	v.size=distance
	src.movevector=v
	var/vector/S=vector(v)
	S.size=rate
	src.canmove=0
	var/oldglide=src.glide_size
	src.glide_size=rate
	src.RotateMob(vector(-S.x,S.y),100)
	while(distance>0)

		src.step_size=rate
		src.icon_state="hurt2"
		src.Move(src.pixloc+S)
		distance-=rate
		src.movevector.size=distance
		sleep(world.tick_lag)
	src.glide_size=oldglide
	sleep(5)
	src.Move(0)
	src.movevector=vector(0,0)
	src.rotation=0
	src.RotateMob(vector(S.x,0),100)
	//src.autoblocks=src.maxautoblocks
	src.tossed=0
	src.CheckCanMove()
	if(!src.dead)src.icon_state=""

atom/var/bouncy=1
atom/movable/proc/bounce(atom/T)
	src.bouncing=1

	var/vector/normal=getnormal(src,T)
	if(normal.size==0)
		return

	var/vector/incident
	if(src.movevector)incident=vector(src.movevector)
	else incident=vector(0,0)
	if(incident.size==0)return
	var/vector/result=calculate_bounce(incident,normal)
	src.canmove=0
	var/distance=min(T.bouncy*src.movevector.size,1000)
	result.size=clamp(src.movevector.size,2,src.step_size)

	sleep(1)
	while(distance>0)
		distance-=min(distance,result.size)
		if(!src.Move(src.pixloc+result))
			distance=0
		sleep(world.tick_lag)
	sleep(1)
	src.bouncing=0
	if(istype(src,/mob))src:CheckCanMove()



mob/proc/CheckCanMove()
	if(!src.charging&&!src.tossed&&!src.usingskill&&!src.block&&!src.aiming)
		src.canmove=1

mob/proc/Take_Ki(amount)
	if(src.ki>=amount)
		src.ki-=amount
		gui_kibar.setValue(src.ki/src.maxki,20)
		return 1
	else
		return 0

mob/proc/Get_Ki(amount)
	src.ki+=amount
	if(src.ki>src.maxki)src.ki=src.maxki
	gui_kibar.setValue(src.ki/src.maxki,10)
