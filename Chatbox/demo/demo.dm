//==================================
// View readme.dm for documentation
//==================================

// demo settings

#define DEBUG




// chatbox settings

chatbox
	layer = FLOAT_LAYER+0.1
	plane = FLOAT_PLANE
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
