/*
All code related to a client logging in/out, logging in to the default mob (mob/picking) and the character selection process and regular mob login/logout procs.
*/

var/obj/banner

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
	winset(src, "AnyMacro", list(
		name = "Any",
		parent = "macro",
		command = @"keydownverb [[*]]"))
	winset(src, "AnyMacroUp", list(
		name = "Any+Up",
		parent = "macro",
		command = @"keyupverb [[*]]"))
	..()



client/Del()
	_message(world, "[name] has logged out.", "yellow") // notify world
	clients-=src
	var/mob/M=src.mob
	M.loc=null
	M.client=null
	..()

mob
	Login()
		if(!src.selecting)
			var/obj/O=new/obj/nameplate
			O.layer=MOB_LAYER-0.5
			O.appearance_flags=RESET_TRANSFORM|RESET_COLOR
			O.maptext="<span style=\"font-family:UberBit7; font-size:8px; color:#fff; -dm-text-outline:1px black; text-align:center;\">[src.client.name]</span>"
			O.maptext_width=96
		//	O.maptext_x=32
			O.pixel_w=-38
			O.maptext_y=-12
			O.alpha=150
			src.vis_contents+=O
			client.screen.Add(gui_frame,gui_hpbar,gui_kibar,gui_blockbar,gui_counterbar,gui_picture,gui_target,gui_target2,gui_targetpl,gui_pl)
			src.oldclient=src.client
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


	Logout()
		if(oldclient)
			oldclient.screen.Remove(gui_frame,gui_hpbar,gui_kibar,gui_blockbar,gui_counterbar,gui_picture,gui_target,gui_target2,gui_targetpl,gui_pl)
		..()
mob/picking
	icon=null
	selecting=1

	Login()
		..()
		src.loc=null
		if(!src.client.name)
			//create a new name entry menu, and call Input()
			//Input() will wait until the client finishes picking a name.
			src.client.screen+=banner
			var/obj/gui/menu/name_entry/picker = new()
			var/n = picker.Input(src.client,"What is your name?")
			if(!src.client)return
			if(!n) n = src.client.key
			src.client.name = n
			src.client.screen-=banner

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
	MrSatan = /mob/mrsatan//,
	//Reid = /mob/reid
	)

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