client/var/name
mob
	var/tmp
		obj/gui_frame
		obj/maskbar/gui_hpbar
		obj/maskbar/gui_kibar
		obj/maskbar/gui_blockbar
		obj/maskbar/gui_counterbar
		obj/gui_portrait
		obj/gui_picture
		obj/gui_target
		obj/gui_target2
		obj/gui_pl
		obj/gui_targetpl

		obj/maskbar/gui_charge
		mob/targetmob
		portrait_xoffset=0
		portrait_yoffset=0

	New(turf/L,alist/P)
		..()
		if(P)
			var/test=P["pl"]
			world.log<<"P! [P] and [test]!"
			if(P["hp"])src.hp=src.maxhp=P["hp"]
			if(P["ki"])src.ki=src.ki=P["ki"]
			if(P["pl"])src.basepl=src.pl=P["pl"]
			if(P["flyinglevel"])src.flyinglevel=P["flyinglevel"]
			if(P["skills"])src.skills=P["skills"]
			if(P["unlocked"])src.unlocked=P["unlocked"]
		if(src.npcrespawn)src.initloc=src.loc
		if(src.hue)
			src.filters += filter(
				type = "color",
				space = FILTER_COLOR_HSV,
			 	color = list(1,0,0, 0,1,0, 0,0,1, src.hue/360,0,0)
			 	)
		if(istype(src,/mob/picking))return
		gui_frame= new/obj/gui/scouterframe()
		gui_frame.owner=src
		gui_hpbar = new/obj/maskbar/hp()
		gui_kibar = new/obj/maskbar/ki()
		gui_blockbar = new/obj/maskbar/block()
		gui_counterbar = new/obj/maskbar/counter()
		gui_target = new/obj/gui/target()
		gui_target2 = new/obj/gui/target()
		gui_target2.screen_loc="TOP: -14,RIGHT: -3"

		gui_charge=new/obj/maskbar/charge()
		var/obj/background = new/obj/gui/picturewindow()
		var/obj/person=new/obj/gui/picture()
		gui_portrait=new/obj/gui/picture()
		gui_portrait.appearance=src.appearance
		person.vis_contents+=gui_portrait
		person.pixel_z+=src.portrait_yoffset
		person.pixel_w+=src.portrait_xoffset
		background.vis_contents+=person
		gui_picture= new/obj/gui/mask()
		gui_picture.vis_contents+=background

		gui_targetpl=new/obj/gui/targetpowerlevel()
		gui_targetpl.screen_loc="TOP:-14,RIGHT:-110"
		gui_pl=new/obj/gui/powerlevel()
		gui_pl.screen_loc="TOP:-14,LEFT:+5"
		gui_pl.owner=src
		gui_targetpl.owner=src




	Login()
		if(!src.selecting)
			var/obj/O=new/obj/nameplate
			O.layer=MOB_LAYER-0.5
			O.appearance_flags=RESET_TRANSFORM|RESET_COLOR
			O.maptext="<span style=\"font-family:UberBit7; font-size:8px; color:#fff; -dm-text-outline:1px black; text-align:center;\">[src.client.name]</span>"
			O.maptext_width=96
			O.maptext_x=4
			O.maptext_y=-12
			O.alpha=150
			src.vis_contents+=O
			client.screen.Add(gui_frame,gui_hpbar,gui_kibar,gui_blockbar,gui_counterbar,gui_picture,gui_target,gui_target2,gui_targetpl,gui_pl)
		..()

obj/nameplate

obj/gui
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	powerlevel
		New()
			..()
			spawn(1)
				src.maptext_x=37
				src.maptext_y=21
				src.maptext_width=72
				src.owner.Refresh_Scouter()
	targetpowerlevel
		New()
			..()
			spawn(1)
				src.maptext_x=37
				src.maptext_y=21
				src.maptext_width=72

	scouterframe
		icon='gui.dmi'
		icon_state="scouter"
		screen_loc="TOP: -6,LEFT: +2"



	picturewindow
		icon='gui.dmi'
		icon_state="background"
		screen_loc="TOP: -6,LEFT: +2"
		appearance_flags = KEEP_TOGETHER
		blend_mode = BLEND_MULTIPLY
	picture
		screen_loc="TOP: -6,LEFT: +2"
		pixel_w=-18
		pixel_z=-12
	mask
		icon='gui.dmi'
		icon_state="mask"
		screen_loc="TOP: -6,LEFT: +2"
		appearance_flags = KEEP_TOGETHER

	target
		appearance_flags = KEEP_TOGETHER
		screen_loc="TOP: +1,RIGHT: -3"
		New()
			..()
			var/matrix/M=new/matrix()
			M.Scale(-1,1)
			src.transform=M


mob/proc/Show_target(mob/M)
	if(src.targetmob!=M)
		src.Clear_target()
		src.targetmob=M
		src.gui_target.icon='gui.dmi'
		src.gui_target.icon_state="scouter_red"
		src.gui_target2.vis_contents.Add(M.gui_hpbar,M.gui_kibar,M.gui_blockbar,M.gui_counterbar,M.gui_picture)
		src.gui_targetpl.vis_contents+=M.gui_pl


mob/proc/Clear_target()
	src.targetmob=null
	src.gui_target.icon=null
	src.gui_target2.vis_contents=null
	src.gui_targetpl.vis_contents=null



obj/maskbar
	hp
		icon = 'gui_hp.dmi'
		screen_loc = "TOP: -14,LEFT: +2"
		width = 72
		height = 5
		orientation = EAST
	ki
		icon = 'gui_ki.dmi'
		screen_loc = "TOP: -14,LEFT: +2"
		width = 72
		height = 5
		orientation = EAST
	block
		icon = 'gui_block.dmi'
		screen_loc = "TOP: -14,LEFT: +2"
		width = 64
		height = 3
		orientation = EAST
	counter
		icon = 'gui_counter.dmi'
		screen_loc = "TOP: -14,LEFT: +2"
		width = 16
		height = 3
		orientation = EAST
	charge
		icon = 'charge.dmi'
		screen_loc = "CENTER,CENTER:-16"
		width = 32
		height = 4
		orientation = EAST

obj/skillbar
	var/selected=0
	var/Skill/linkedskill
	var/active=0
	icon='skills.dmi'
	Click()
		if(!src.selected)src.Activate()
		else src.Deactivate()
	proc/Activate()
		src.transform=matrix().Scale(0.75,0.75)
		src.selected=1
	proc/Deactivate()
		src.transform=matrix().Scale(0.5,0.5)
		src.selected=0

	New()
		..()
		src.transform=matrix().Scale(0.5,0.5)
		src.selected=0
	S1
		screen_loc="BOTTOM:+2,LEFT:+2"
	S2
		screen_loc="BOTTOM:+2,LEFT+2:+2"
	S3
		screen_loc="BOTTOM:+2,LEFT+4:+2"
	S4
		screen_loc="BOTTOM:+2,LEFT+6:+2"
	S5
		screen_loc="BOTTOM:+2,LEFT+8:+2"
	S6
		screen_loc="BOTTOM:+2,LEFT+10:+2"
	S7
		screen_loc="BOTTOM:+2,LEFT+12:+2"


client/proc/initskillbar()
	var/mob/M=src.mob
	if(!src.skillgui)
		src.skillgui=new/list
		src.skillgui.len=7
	if(M.skills.len>=1)
		if(!src.skillgui[1])src.skillgui[1]=new/obj/skillbar/S1
		src.skillgui[1].icon=M.skills[1].icon
		src.skillgui[1].icon_state=M.skills[1].icon_state
	if(M.skills.len>=2)
		if(!src.skillgui[2])src.skillgui[2]=new/obj/skillbar/S2
		src.skillgui[2].icon=M.skills[2].icon
		src.skillgui[2].icon_state=M.skills[2].icon_state
	if(M.skills.len>=3)
		if(!src.skillgui[3])src.skillgui[3]=new/obj/skillbar/S3
		src.skillgui[3].icon=M.skills[3].icon
		src.skillgui[3].icon_state=M.skills[3].icon_state
	if(M.skills.len>=4)
		if(!src.skillgui[4])src.skillgui[4]=new/obj/skillbar/S4
		src.skillgui[4].icon=M.skills[4].icon
		src.skillgui[4].icon_state=M.skills[4].icon_state
	if(M.skills.len>=5)
		if(!src.skillgui[5])src.skillgui[5]=new/obj/skillbar/S5
		src.skillgui[5].icon=M.skills[5].icon
		src.skillgui[5].icon_state=M.skills[5].icon_state
	if(M.skills.len>=6)
		if(!src.skillgui[6])src.skillgui[6]=new/obj/skillbar/S6
		src.skillgui[6].icon=M.skills[6].icon
		src.skillgui[6].icon_state=M.skills[6].icon_state
	if(M.skills.len>=7)
		if(!src.skillgui[7])src.skillgui[7]=new/obj/skillbar/S7
		src.skillgui[7].icon=M.skills[7].icon
		src.skillgui[7].icon_state=M.skills[7].icon_state
	var/s=0
	for(var/i =1 to M.skills.len)
		if(M.equippedskill==M.skills[i])
			s=i
	for(var/obj/O in src.skillgui)
		src.screen|=O
	if(s)
		src.skillgui[s].Activate()

client/proc/removeskillbar()

	for(var/obj/O in src.skillgui)
		src.screen-=O
		src.skillgui-=O
	src.skillgui=null

client/proc/updateskillbar()
	var/mob/M=src.mob
	for(var/i =1 to M.skills.len)
		if(M.equippedskill==M.skills[i])
			src.skillgui[i].Activate()
		else
			if(src.skillgui.len>=i)
				src.skillgui[i].Deactivate()


client/var/tmp/list/skillgui
mob/proc
	Update_Counters()
		set waitfor = 0
		gui_counterbar.setValue(src.counters/src.maxcounters,5)


	Update_Blocks()
		set waitfor = 0
		gui_blockbar.setValue(src.blocks/src.maxblocks,5)


//==================================
// View readme.dm for documentation
//==================================

// demo settings

#define DEBUG




// chatbox settings

chatbox
	layer = FLOAT_LAYER+0.1
	plane = FLOAT_PLANE+1
	screen_loc = "RIGHT:-225,1:19"
	alpha=120
	maptext_height = 128
	maptext_width = 225

	maxlines = 50
	chatlines = 9

	font_family = "Arial"
	font_color = "#FFFFFF"

	text_shadow = "#222d"

chatbox_gui
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	alpha=70
	icon = 'chatbox_gui.dmi'
	MouseEntered()
		for(var/chatbox_gui/G in usr.client.screen)
			G.alpha=150
		for(var/chatbox/C in usr.client.screen)
			C.alpha=255
	MouseExited()
		for(var/chatbox_gui/G in usr.client.screen)
			G.alpha=70
		for(var/chatbox/C in usr.client.screen)
			C.alpha=120
		winset(usr,"input1","is-visible=false")
	chatbar
		icon= 'gui/textinput.dmi'
		screen_loc = "RIGHT:-16,BOTTOM:1"
		Click()
			for(var/chatbox_gui/G in usr.client.screen)
				G.alpha=255
			for(var/chatbox/C in usr.client.screen)
				C.alpha=255
			var/zoom=usr.client?.clean_map_scaling?._zoom
			var/width=usr.client?.clean_map_scaling?._map_size[1]
			var/height=usr.client?.clean_map_scaling?._map_size[2]
			if(!zoom)zoom=1
			//width - 266
			winset(usr,"input1","is-visible=true")
			winset(usr,"input1",list(focus="true",pos = "[width-(260*zoom)],[height-(13*zoom)]",size = "[round(240*zoom,1)]x[10*zoom]"))


	background
		icon = 'gui/chatbox.png'
		layer=FLOAT_LAYER-0.1
		screen_loc = "RIGHT:-16,1:16"
	//	mouse_opacity = 0

	start
		icon_state = "start"
		screen_loc = "RIGHT:-2,5"

	up
		icon_state = "up"
		screen_loc = "RIGHT:-2,4:16"

	down
		icon_state = "down"
		screen_loc = "RIGHT:-2,2"

	end
		icon_state = "end"
		screen_loc = "RIGHT:-2,1:16"


// implementation

mob

	// chatbox creation

	verb

	// chat examples

		chat_pm(mob/mob as mob, txt as text)
			if(istype(mob))
				_message(src, "\[to: [mob.name]\] [txt]", "#ffa000")
				_message(mob, "\[from: [name]\] [txt]", "#ffa000")

		chat_say(txt as text)
			_message(view(src,6), "[name]: [txt]")

		chat_world(txt as text)
			_message(world, "[name]: [txt]", rgb(50,250,100))

		chat_colored(txt as text,color as color)
			chat_say(_ftext(txt,color))

	// chatbox

		clear_chatbox()
			set category = "chatbox"
			if(client)
				client.chatbox_clear()

		hide_chatbox()
			set category = "chatbox"
			if(client)
				client.chatbox_show(0)

		show_chatbox()
			set category = "chatbox"
			if(client)
				client.chatbox_show()
