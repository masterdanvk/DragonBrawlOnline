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
		portrait_offset=0
	New()
		..()
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
		person.pixel_z+=src.portrait_offset
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
			var/obj/O=new/obj
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

mob/proc
	Update_Counters()
		set waitfor = 0
		gui_counterbar.setValue(src.counters/src.maxcounters,5)


	Update_Blocks()
		set waitfor = 0
		gui_blockbar.setValue(src.blocks/src.maxblocks,5)

