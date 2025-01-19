
client
	var/tmp/chatlog
	var/tmp/chatboxlist[0]
	// don't touch
	var/tmp/chatbox/_chatbox

	proc
		chatbox_build()
			chatbox_remove()
			_chatbox = new
			screen += _chatbox._shadow
			screen += _chatbox
			for(var/gui in typesof(/chatbox_gui))
				switch(gui)
					if(/chatbox_gui)
					else
						var/G=new gui
						screen += G
						chatboxlist|=G

		chatbox_remove()
			if(_chatbox)
				if(_chatbox._shadow)
					del _chatbox._shadow
				del _chatbox
			for(var/chatbox_gui/extra in screen)
				del extra

		chatbox_clear()
			if(_chatbox)
				_chatbox._clear()

		chatbox_show(setting=TRUE)
			if(_chatbox)
				_chatbox.invisibility = setting ? 0 : 101
				if(_chatbox._shadow)
					_chatbox._shadow.invisibility = setting ? 0 : 101
			for(var/chatbox_gui/extra in screen)
				extra.invisibility = setting ? 0 : 101

		chatlog_record(str)
			if(chatlog)
				src << output("[str]",chatlog)

		chatlog_clear()
			if(chatlog)
				src << output(null,chatlog)
		chatbox_showscreen()
			if(_chatbox)
				_chatbox.invisibility = 0
				src.screen|=_chatbox
				if(_chatbox._shadow)
					_chatbox._shadow.invisibility = 0
			for(var/chatbox_gui/extra in screen)
				extra.invisibility = 0
			for(var/G in chatboxlist)
				screen|=G

