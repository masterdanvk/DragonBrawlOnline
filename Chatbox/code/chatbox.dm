
_defaults/chatbox
	parent_type = /atom/movable
	icon = null
	screen_loc = "1:16,1:16"
	maptext_height = 128
	maptext_width = 256
	layer = FLY_LAYER+1
	mouse_opacity = 0

	var
		maxlines = 8
		chatlines = 8

		font_family
		font_color
		font_size=1

		text_shadow

chatbox
	parent_type = /_defaults/chatbox

	var
	// dont touch
		chatbox_msgs/_msgs
		_pageup = 0
		_updates = 0
		_active = 0

	proc
		_clear()
			_msgs.Clear()
			_pageup = 0
			_update()

		_pagestart()
			_pageup = _msgs&&(_msgs.len-1)
			_update()

		_pageup()
			_pageup = min(_pageup+1,_msgs&&(_msgs.len-1))
			_update()

		_pagedown()
			_pageup = max(_pageup-1,0)
			_update()

		_pageend()
			_pageup = 0
			_update()

		_update()
			if(_active)
				_updates++
				return
			_active = 1
			spawn(-1)
				_updates=0
				do
					var/tag = "chatmsg[rand(1000)]"
					var/text = _getlog(tag)
					var/default = "<style>body {font-family: '[font_family]'; font-size: [font_size||"2"]; color: [font_color||"black"];}</style>"
					maptext = default + "<style>[tag] {color: inherit;}</style>" + text
					_shadow.maptext = text_shadow ? default + "<style>[tag] {color: [text_shadow] ! important;}</style>" + text : null
					sleep(world.tick_lag)
				while(_got_updates())
				_active = 0

		_enter(chatbox_msg/msg)
			if(!msg)
				return
			if(!_msgs)
				_msgs = new(maxlines)
			_msgs.Add(msg)
			_update()

		_getlog(tag)
			if(!_msgs || !_msgs.len)
				return null
			var/fulltext
			var/lines = 0
			for(var/i = _msgs.len - _pageup , i>0 && lines<chatlines , i--)
				var/chatbox_msg/msg = _msgs.Get(i)
				fulltext = "\n<[tag]>[msg.text]</[tag]>[fulltext]"
				lines++
			return fulltext

		_got_updates()
			.=_updates
			_updates=0

	var/chatbox/shadow/_shadow

	New()
		_shadow = new

	shadow
		mouse_opacity = 0

		New()
			var/global
				original_screen_loc
				new_screen_loc

			if(original_screen_loc!=screen_loc)
				var
					separator = findtext(screen_loc,",")
					screen_x = copytext(screen_loc,1,separator)
					screen_y = copytext(screen_loc,separator+1)
					map
					screen_px
					screen_py
					i

				i = findtext(screen_x,":")
				if(i)
					map = copytext(screen_x,1,i)
					if(findtext(screen_x,":",i+1))
						screen_x = copytext(screen_x,i+1)
					else
						switch(uppertext(map))
							if("NORTH","SOUTH","EAST","WEST","CENTER")
								map = null
							else
								if( !_number(map) )
									screen_x = copytext(screen_x,i+1)
								else
									map = null

				i = findtext(screen_x,":")
				screen_px = ( i && text2num(copytext(screen_x,i+1,0)) ) + 1
				screen_x = copytext(screen_x,1,i)

				i = findtext(screen_y,":")
				screen_py = ( i && text2num(copytext(screen_y,i+1,0)) ) - 1
				screen_y = copytext(screen_y,1,i)

				original_screen_loc = screen_loc
				new_screen_loc = "[map?"[map]:" :][screen_x]:[screen_px],[screen_y]:[screen_py]"

			screen_loc = new_screen_loc


		proc
			_number(text)
				for(var/i in 1 to length(text))
					switch(text2ascii(text,i))
						if(48 to 57)
						else
							return FALSE
				return TRUE
