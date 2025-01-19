client/verb/SayGamepad()
	var/obj/gui/menu/name_entry/picker = new()
	var/n = picker.Input(src,"What do you want to say?")

	src.mob.chat_say(_ftext(n,"lightgrey"))

client/var/tmp/chatinit=0

mob/verb/say(i as text)
	//world<<"[usr.client.name]: [i]"
	chat_say(_ftext(i,"lightgrey"))

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
	icon = 'gui/chatbox_gui.dmi'
	MouseEntered()
		for(var/chatbox_gui/G in usr.client.screen)
			G.alpha=150
		for(var/chatbox/C in usr.client.screen)
			C.alpha=255
	MouseExited()
		for(var/chatbox_gui/G in usr.client.screen)
			if(usr.client.overworld)G.alpha=70
			else
				G.alpha=0
		for(var/chatbox/C in usr.client.screen)
			if(usr.client.overworld)C.alpha=120
			else
				C.alpha=0
		winset(usr,"input1","is-visible=false")
	proc/Show()
		for(var/chatbox_gui/G in usr.client.screen)
			G.alpha=70
		for(var/chatbox/C in usr.client.screen)
			C.alpha=120
		winset(usr,"input1","is-visible=false")
	proc/Hide()
		for(var/chatbox_gui/G in usr.client.screen)
			G.alpha=0
		for(var/chatbox/C in usr.client.screen)
			C.alpha=0
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

	verb


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