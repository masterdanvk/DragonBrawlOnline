var
	name_entry_pages = list("upper" = list(list("0","1","2","3","4","5","6","7","8","9"),
										   list("A","B","C","D","E","F","G","H","I","J"),
										   list("K","L","M","N","O","P","Q","R","S","T"),
										   list("U","V","W","X","Y","Z"," ","_","-","#")
									  ),

							"lower" = list(list("0","1","2","3","4","5","6","7","8","9"),
										   list("a","b","c","d","e","f","g","h","i","j"),
										   list("k","l","m","n","o","p","q","r","s","t"),
										   list("u","v","w","x","y","z"," ","_","-","#")
									  )
					   )

	name_entry_separator = "<BR>"

	name_entry_columns = init_name_entry_columns()


proc/init_name_entry_columns()
	var/list/page, list/output = list(), list/columns

	for(var/id in name_entry_pages)
		columns = list()
		page = name_entry_pages[id]

		//conform the rows to have the same number of characters
		var/rows = length(page), cols = 0

		//figure out the longest row
		for(var/row in 1 to rows)
			cols = max(length(page[row]),cols)

		columns.len = cols

		//add nulls to the end of any short rows
		for(var/row in 1 to rows)
			var/old_len = length(page[row])

			if(old_len < cols)
				page[row]:len = cols

		//build the text rows
		for(var/col in 1 to cols)
			columns[col] = page[1][col]

			for(var/row in 2 to rows)
				columns[col] += "[name_entry_separator][page[row][col]]"

		//add the page columns to the output list
		output[id] = columns

	//return the output list
	return output


obj/gui/name_entry
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

	//the cursor helps visualize which letter you have selected
	cursor
		id = "cursor"
		vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_HIDE

		icon = 'name_entry_cursor.dmi'
		icon_state = "0"
		icon_w = 4

		mouse_opacity = 0

		var
			col = 0
			row = 0
			size = 0

		var/tmp
			obj/gui/name_entry/cursor_part/edge

		proc
			Resize(w)
				if(w==size) return
				edge.pixel_w = w - 32
				size = w

		New()
			edge = new()
			vis_contents += edge

	cursor_part
		vis_flags = VIS_INHERIT_ICON | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		icon_state = "1"
		icon_w = 4

	//the input bar allows normal key entry
	input_bar
		id = "input_bar"
		vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER

		icon = 'name_entry_bar.dmi'

		pixel_z = 113
		pixel_w = 24

		maptext_x = 4
		maptext_y = 1
		maptext_width = 264
		maptext_height = 24

		var/tmp
			list/allowed_keys = list()
			cursor_time = 0

		proc
			UpdateMaptext(value,delay=cursor_time - world.time)
				animate(src,maptext="<span style='text-align:center;vertical-align:middle'><span style='color:#FFFFFF00;'>|[value]</span>|</span>",time=5,loop=-1,delay=delay)
				animate(maptext="<span style='text-align:center;vertical-align:middle;color:#FFFFFF00'>|[value]|</span>",time=5)

		MouseDown()
			usr.client.GUIFocus(src)

		onKeyDown(button)
			if(length(vis_locs))
				var/obj/gui/menu/name_entry/menu = vis_locs[1]

				switch(button)
					if("Back","Shift","GamepadFace2","GamepadR1")
						menu.onKeyDown(button)

					if("Return","Escape","GamepadStart","GamepadSelect","GamepadUp","GamepadDown","GamepadLeft","GamepadRight","GamepadUpLeft","GamepadUpRight","GamepadDownLeft","GamepadDownRight")
						usr.client.GUIFocus(menu)
						menu.onKeyDown(button)

					else
						var/character = menu.Button2Char(button)
						if(character)
							menu.onKeyEntry(character)

		onKeyUp(button)
			if(length(vis_locs))
				var/obj/gui/menu/name_entry/menu = vis_locs[1]

				switch(button)
					if("Back","Shift","GamepadFace2","GamepadR1")
						menu.onKeyUp(button)

		onFocus()
			if(length(vis_locs))
				var/obj/gui/menu/name_entry/menu = vis_locs[1]
				cursor_time = world.time
				UpdateMaptext(menu.value)

		onBlur()
			maptext = ""

	//the content panel displays the pages of the text entry menu, and delegates input controls over the maptext to the menu
	content_panel
		id = "content_panel"

		maptext_x = 20
		maptext_y = 9
		maptext_width = 264
		maptext_height = 24

		pixel_z = 104
		pixel_w = 8

		var
			width = 0
			height = 0

		var/tmp
			active_page = "upper"

			list/columns
			obj/gui/name_entry/mouse_catcher/mouse_catcher

			row_size = 0
			col_size = 0

			rows = 0
			cols = 0

		New()
			if(active_page)
				setPage(active_page)

			..()

		proc
			setPage(page)
				if(page==active_page && columns)
					return

				var/list/active = name_entry_columns[page]
				if(active)
					cols = length(active)
					var/obj/gui/name_entry/text_column/child

					//if this UI isn't initialized, initialize it.
					if(!columns)
						rows = length(name_entry_pages[active_page])

						columns = new/list(cols)

						for(var/col in 1 to cols)
							//create the text column
							child = new/obj/gui/name_entry/text_column()
							columns[col] = child

							//position the column relative to its peers
							child.maptext_x = width
							child.maptext_y = -child.maptext_height + 1

							//expand this element's size
							width += child.maptext_width
							height = max(height,child.maptext_height)

						//store the row metrics
						row_size = child.maptext_height / rows
						col_size = child.maptext_width

						//create the mouse catcher object
						mouse_catcher = new/obj/gui/name_entry/mouse_catcher()
						mouse_catcher.Resize(width,height)

						//set up vis children
						vis_contents.Add(columns,mouse_catcher)

					//assign the text columns to the children
					for(var/col in 1 to cols)
						child = columns[col]
						child.maptext = "[child.maptext_prefix][active[col]][child.maptext_suffix]"

					//store the active page
					active_page = page

			//called when the name field has changed
			onChanged(new_value)
				maptext = "<span style='text-align:center;vertical-align:middle'>[new_value]</span>"

		//attempt to keep the cursor in sync with the mouse
		MouseMove(atom/location,control,params)
			var/list/p = params2list(params)

			var/col = clamp( floor( (text2num(p["icon-x"]) - 1) / col_size) + 1, 1, cols + 1)
			var/row = clamp( floor( (text2num(p["icon-y"]) * -1) / row_size) + 1, 1, rows)

			if(length(vis_locs))
				vis_locs[1]:onKeyHover(col,row)

		//make sure the cursor is synced with the mouse
		MouseEntered(atom/location,control,params)
			MouseMove(location,control,params)

		//tell the menu to hide the cursor when the mouse has left the selection area
		MouseExited(atom/location,control,params)
			if(length(vis_locs))
				vis_locs[1]:onHoverExit(id)

		//tell the menu that a character slection was made with the mouse
		MouseDown(atom/location,control,params)
			MouseMove(location,control,params)
			if(active_page)
				if(length(vis_locs))
					vis_locs[1]:onKeyEntry()
					vis_locs[1]:RestoreFocus()


	//text columns help lay out the text entry panel's pages
	text_column
		mouse_opacity = 0

		maptext_width = 24
		maptext_height = 100

		var
			maptext_prefix = "<span style='text-align:center;vertical-align:top;line-height:2;text-shadow:1px 1px 0 #2E3747'>"
			maptext_suffix = "</span>"

	button
		maptext_x = 4
		maptext_y = 4
		maptext_width = 56
		maptext_height = 18
		pixel_w = 248

		icon = 'name_entry_button.dmi'
		icon_state = "0"

		var
			maptext_prefix = "<span style='text-align:center;vertical-align:middle;text-shadow:0 -1px 0 #E5B444'>"
			maptext_suffix = "</span>"

		New()
			maptext = "[maptext_prefix]<img src=\ref['name_entry_icons.dmi'] ICONSTATE='[maptext]' width=12 height=12>[maptext][maptext_suffix]"
			..()

		//shift the button downard when pressed
		MouseDown()
			Hold()

			if(length(vis_locs))
				vis_locs[1]?:onButtonPress(id)
				vis_locs[1]?:RestoreFocus()


		//shift the button back up when released
		MouseUp()
			Release()

		//shift the button back up when dropped
		MouseDrop()
			Release()

		proc
			//call to animate a key press
			Press()
				animate(src,icon_state = "1", maptext_y = 2,time=0)
				animate(time=1)
				animate(icon_state = "0", maptext_y = 4,time=0)

				if(length(vis_locs))
					vis_locs[1]?:onButtonPress(id)

			//called to change the visual state to pressed
			Hold()
				icon_state = "1"
				maptext_y = 2

			//called to change the visual state to released
			Release()
				icon_state = "0"
				maptext_y = 4

		back
			id = "back_button"
			maptext = "Back"
			pixel_z = 110 - 24

		clear
			id = "clear_button"
			maptext = "Clear"
			pixel_z = 110 - 50

		shift
			id = "shift_button"
			maptext = "Shift"
			pixel_z = 110 - 76

		done
			id = "done_button"
			maptext = "Done"
			pixel_z = 110 - 102

	//The mouse catcher helps to predict which letter the mouse is over when using the mouse to interact with the UI like an on-screen keyboard.
	mouse_catcher
		vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_INHERIT_ID

		icon = 'name_entry_cursor.dmi'
		icon_state = "mask"
		alpha = 0
		pixel_z = 4

		mouse_opacity = 2

		var
			icon_width = 32
			icon_height = 32

		proc
			//resize the mouse catcher to align with the top of the content panel
			Resize(w,h)
				transform = matrix(w / icon_width, 0, (w - icon_width) / 2, 0, h / icon_height, (h + icon_height) / -2 + 1)

obj/gui/menu/name_entry
	content_blueprint = /obj/gui/name_entry

	icon = 'name_entry.dmi'
	maptext_x = 48
	maptext_y = 150
	maptext_width = 224
	maptext_height = 18

	width = 320
	height = 176

	var
		result = null
		__active_input

		max_length = 16
		min_length = 3

		key_press_lag = 5
		key_repeat_lag = 1

	var/tmp
		value = ""
		list/repeating_keys

								 //capital letters
		list/allowed_keys = list("Shift+A"="A", "Shift+B"="B", "Shift+C"="C", "Shift+D"="D", "Shift+E"="E", "Shift+F"="F", "Shift+G"="G",
								 "Shift+H"="H", "Shift+I"="I", "Shift+J"="J", "Shift+K"="K", "Shift+L"="L", "Shift+M"="M", "Shift+N"="N",
								 "Shift+O"="O", "Shift+P"="P", "Shift+Q"="Q", "Shift+R"="R", "Shift+S"="S", "Shift+T"="T", "Shift+U"="U",
								 "Shift+V"="V", "Shift+W"="W", "Shift+X"="X", "Shift+Y"="Y", "Shift+Z"="Z",
								 //lowercase letters
								 "A"="a", "B"="b", "C"="c", "D"="d", "E"="e", "F"="f", "G"="g", "H"="h", "I"="i", "J"="j", "K"="k", "L"="l", "M"="m",
								 "N"="n", "O"="o", "P"="p", "Q"="q", "R"="r", "S"="s", "T"="t", "U"="u", "V"="v", "W"="w", "X"="x", "Y"="y", "Z"="z",
								 //numbers
								 "1"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "7"="7", "8"="8", "9"="9", "0"="0",
								 //special character
								 "Space"=" ", "Shift+-"="_", "-"="-", "Shift+3"="#")

	proc
		Input(user=usr, prompt, min_length=src.min_length, max_length=src.max_length)
			src.min_length = min_length
			src.max_length = max_length

			if(istype(user,/mob))
				user = user:client

			if(istype(user,/client))
				user:screen += src
				maptext = "<span style='text-align:center;vertical-align:middle;text-shadow:1px 1px 0 #2E3747'>[prompt]</span>"
				user:GUIFocus(src)
				repeating_keys = list()
			else
				return null

			//wait for the menu to receive a value from the user
			result = null
			__active_input = args
			while(result==null && __active_input==args && user)
				//trigger key repeat logic every tick
				RepeatKeys()
				sleep(world.tick_lag)

			//clean up the menu
			if(__active_input==args)
				__active_input = null
				repeating_keys.len = 0

				if(user)
					user:screen -= src
					if(user:focus_target==src)
						user:GUIFocus(null)
					return result

		//call to generate error messages or finalize the input
		Validate()
			var/len = length(value)

			if(len > max_length)
				onError("Name longer than [max_length] characters.")
			else if(len < min_length)
				onError("Name shorter than [min_length] characters.")
			else
				return value

		//temporarily shows an error message in the title bar
		onError(error)
			var/old_title = maptext
			animate(src,maptext="<span style='text-align:center;vertical-align:middle;text-shadow:1px 1px 0 #2E3747;color:#C00000'>[error]</span>",time=30)
			animate(maptext=old_title)

		//called to update the cursor size and position when a button is hovered
		onButtonHover(id)
			var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]
			var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

			switch(id)
				if("back_button")
					cursor.row = 1
				if("clear_button")
					cursor.row = 2
				if("shift_button")
					cursor.row = 3
				if("done_button")
					cursor.row = 4
				else
					return

			cursor.vis_flags &= ~VIS_HIDE

			cursor.col = panel.cols + 1

			cursor.pixel_w = (cursor.col - 1) * panel.col_size + panel.pixel_w
			cursor.pixel_z = cursor.row * -panel.row_size + 1 + panel.pixel_z

			cursor.Resize(72)

		//called to tell the cursor to press on whatever is under it
		onCursorPress()
			var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]

			var/id = CursorButtonId()
			if(id)
				vis_registry[id]:Press()

			else if(cursor.vis_flags & VIS_HIDE)
				onKeyHover(cursor.col,cursor.row)

			else
				onKeyEntry()

		//called when a button is pressed
		onButtonPress(id)
			switch(id)
				if("back_button")
					var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

					if(length(value)>1)
						value = copytext(value,1,-1)
					else
						value = ""

					panel.onChanged(value)

					var/obj/gui/name_entry/input_bar/bar = vis_registry["input_bar"]
					if(bar.maptext)
						bar.UpdateMaptext(value)

				if("clear_button")
					var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

					value = ""

					panel.onChanged(value)

				if("shift_button")
					var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

					if(panel.active_page=="upper")
						panel.setPage("lower")
					else
						panel.setPage("upper")

				if("done_button")
					result = Validate()

		//called to tell the cursor to update its position within the text page
		onKeyHover(col,row)
			var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]
			var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

			cursor.vis_flags &= ~VIS_HIDE

			row = clamp(row,1,panel.rows)
			col = clamp(col,1,panel.cols)

			if(cursor.row!=row || cursor.col!=col)
				cursor.row = row
				cursor.col = col

				cursor.pixel_w = (col - 1) * panel.col_size + panel.pixel_w
				cursor.pixel_z = row * -panel.row_size + 1 + panel.pixel_z

				cursor.Resize(32)

		//called to tell the cursor to hide itself when leaving the text page
		onHoverExit(id)
			var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]
			cursor.vis_flags |= VIS_HIDE

		//called when the text page is clicked on. By default, add a letter to the input value
		onKeyEntry(character)
			if(length(value) < max_length)
				var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

				if(!character)
					var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]
					character = name_entry_pages[panel.active_page][cursor.row][cursor.col]

				value = "[value][character]"

				panel.onChanged(value)

				var/obj/gui/name_entry/input_bar/bar = vis_registry["input_bar"]
				if(bar.maptext)
					bar.UpdateMaptext(value)

		//called to move the cursor by a direction (keyboard/gamepad movement)
		MoveCursor(dir)
			var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]
			var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

			var/col = cursor.col, row = cursor.row
			switch(dir & 3)
				if(NORTH)
					if(row>1)
						row -= 1
					else
						row = panel.rows
					. |= NORTH
				if(SOUTH)
					if(row>=panel.rows)
						row = 1
					else
						row += 1
					. |= SOUTH
			switch(dir & 12)
				if(EAST)
					if(col>=panel.cols + 1)
						col = 1
					else
						col += 1
					. |= EAST
				if(WEST)
					if(col>1)
						col -= 1
					else
						col = panel.cols + 1
					. |= WEST

			if(.)
				if(col >= panel.cols + 1)
					cursor.row = row
					cursor.col = col
					onButtonHover(CursorButtonId())
				else
					onKeyHover(col,row)

		//call to mark a key as being repeated
		RepeatKey(button,time)
			repeating_keys[button] = time


		//repeats key inputs after a delay
		RepeatKeys()
			for(var/button,time in repeating_keys)
				if(time <= world.time)
					repeating_keys -= button
					onKeyDown(button,lag=key_repeat_lag)

		//get a valid character for the button
		Button2Char(button)
			switch(vis_registry["content_panel"]?:active_page)
				if("upper")
					. = allowed_keys["Shift+[button]"] || allowed_keys[button]
				if("lower")
					. = allowed_keys[button]

		//get a valid name for the button the cursor is currently pointing to
		CursorButtonId()
			var/obj/gui/name_entry/cursor/cursor = vis_registry["cursor"]
			var/obj/gui/name_entry/content_panel/panel = vis_registry["content_panel"]

			if(cursor.col == panel.cols + 1)
				switch(cursor.row)
					if(1)
						return "back_button"
					if(2)
						return "clear_button"
					if(3)
						return "shift_button"
					if(4)
						return "done_button"

			return null

		//return the focus to this from the bar
		RestoreFocus()
			if(usr.client.focus_target == vis_registry["input_bar"])
				usr.client.GUIFocus(src)

	//take focus from the input bar when clicking on the background
	MouseDown()
		RestoreFocus()

	//called by the client when this input is focused and they press a key, or by RepeatKeys()
	onKeyDown(button,lag=key_press_lag)
		switch(button)
			//non-repeating keys
			if("Shift","GamepadR1")
				vis_registry["content_panel"]:setPage("upper")
				vis_registry["shift_button"]:Hold()
				lag = 1#INF
			if("Escape","GamepadSelect")
				onButtonHover("clear_button")
				lag = 1#INF
			if("Return","GamepadStart")
				if(CursorButtonId()=="done_button")
					onButtonPress("done_button")
				else
					onButtonHover("done_button")
				lag = 1#INF
			if("Space","GamepadFace1")
				onCursorPress()
				lag = 1#INF

			//repeating keys
			if("Back","GamepadFace2")
				onButtonPress("back_button")
				vis_registry["back_button"]:Hold()
			if("North","GamepadUp")
				MoveCursor(NORTH)
			if("South","GamepadDown")
				MoveCursor(SOUTH)
			if("East","GamepadRight")
				MoveCursor(EAST)
			if("West","GamepadLeft")
				MoveCursor(WEST)
			if("Northeast","GamepadUpRight")
				MoveCursor(NORTHEAST)
			if("Northwest","GamepadUpLeft")
				MoveCursor(NORTHWEST)
			if("Southeast","GamepadDownRight")
				MoveCursor(SOUTHEAST)
			if("Southwest","GamepadDownLeft")
				MoveCursor(SOUTHWEST)

			//unhandled keys
			else
				var/character = Button2Char(button)
				if(character)
					var/obj/gui/name_entry/input_bar/bar = vis_registry["input_bar"]
					usr.client.GUIFocus(bar)
					onKeyEntry(character)

				lag = 1#INF

		if(lag!=1#INF)
			RepeatKey(button,world.time + (lag || world.tick_lag))

	//called by the client when this input is focused and they release a key.
	onKeyUp(button)
		switch(button)
			if("Shift","GamepadR1")
				vis_registry["content_panel"]:setPage("lower")
				vis_registry["shift_button"]:Release()

			if("Back","GamepadFace2")
				vis_registry["back_button"]:Release()

		repeating_keys -= button

	//hide the cursor and stop repeating keys when losing focus
	onBlur()
		repeating_keys.len = 0
		vis_registry["cursor"]:vis_flags |= VIS_HIDE