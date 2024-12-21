
_defaults/chatbox_gui
	parent_type = /atom/movable
	icon = null
	layer = FLY_LAYER


chatbox_gui
	parent_type = /_defaults/chatbox_gui

	Click()
		..()
		if(istype(usr,/mob))
			_onclick(usr:client)

	proc
		_onclick(client/client)

	background

	start
		_onclick(client/client)
			if(client&&client._chatbox)
				client._chatbox._pagestart()

	up
		_onclick(client/client)
			if(client&&client._chatbox)
				client._chatbox._pageup()

	down
		_onclick(client/client)
			if(client&&client._chatbox)
				client._chatbox._pagedown()

	end
		_onclick(client/client)
			if(client&&client._chatbox)
				client._chatbox._pageend()

