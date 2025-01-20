/*
Handles the majority of onscreen GUI objects for the players name (attached to their mob), hp, ki, block, counters, powerlevel and player's
mob preview (portrait). This also handles the skillbar which can have up to 7 skills, Q/W alternate between these skills.
The target, set based on attacking or being attacked, will show a flipped GUI in the top right corner so you can track their hp, powerlevel, etc.
It is possible to restrict and limit this sort of information being available to the player based on things like sensory proficiency, having a scouter equipped, etc.
By default these quality of life features are all on.

*/

client/var/name

client/var/fullscreen=0
client/verb/FullScreen()
	if(src.fullscreen=="true")src.fullscreen="false"
	else
		src.fullscreen="true"
	winset(src, "mainwindow", "is-fullscreen=[src.fullscreen]")
client/verb/changeview(var/i as text)
	src.view=i



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
			spawn(1)
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






mob/var/tmp/client/oldclient
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
		pixel_w=0//-18
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
		screen_loc = "CENTER:-16,CENTER:-8"
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

client/var/lastupdateskill
client/var/skillbarchanging=0

client/proc/updateskillbar()
	src.lastupdateskill=world.time+10
	var/mob/M=src.mob
	for(var/i =1 to M.skills.len)
		if(M.equippedskill==M.skills[i])
			src.skillgui[i].Activate()
		else
			if(src.skillgui.len>=i)
				src.skillgui[i].Deactivate()
	if(src.skillbarchanging) return
	src.skillbarchanging=1
	src.ShowSkills()
	while(world.time<src.lastupdateskill)
		sleep(10)
	src.HideSkills()
	src.skillbarchanging=0


client/var/tmp/list/skillgui
mob/proc
	Update_Counters()
		set waitfor = 0
		gui_counterbar.setValue(src.counters/src.maxcounters,5)


	Update_Blocks()
		set waitfor = 0
		gui_blockbar.setValue(src.blocks/src.maxblocks,5)



#define DEBUG




mob
	proc/Reset_Portrait()
		if(src.bdir==WEST)
			src.transform=null
			src.gui_portrait.appearance=src.appearance
			src.transform=new/matrix().Scale(-1,1)
		else
			src.gui_portrait.appearance=src.appearance


mob/proc/Refresh_Scouter()
	var/text_pl
	if(src.pl>=10000000)
		text_pl="[round(src.pl/1000000,0.1)] M"
	else if(src.pl>=1000)
		text_pl=commafy(src.pl)
	else
		text_pl="[src.pl]"
	src.gui_pl.maptext="<span style='font-family:Calibri;font-size:12pt;'><font color=white>[text_pl]</span></font>"

client
	proc
		HideSkills()
			for(var/obj/skillbar/S in src.screen)
				var/matrix/M=matrix()
				if(S.selected)M.Scale(0.75,0.75).Translate(0,-125)
				else M.Scale(0.5,0.5).Translate(0,-125)
				animate(S,alpha=0,transform=M,time=30)

		ShowSkills()
			for(var/obj/skillbar/S in src.screen)
				var/matrix/M=matrix()
				if(S.selected)M.Scale(0.75,0.75)
				else M.Scale(0.5,0.5)
				animate(S,alpha=255,transform=M,time=3)