/*
The backend GUI behavior for Ter's GUILib - used for the gui_name_entry components.


*/


obj/gui
	var
		id
	var/tmp
		menu_id

	New(atom/NewLoc,obj/gui/menu/menu)
		if(menu)
			menu_id = "\ref[menu]"
		..()

	proc
		onFocus(client/client)
			set waitfor = 0

		onBlur(client/client)
			set waitfor = 0

		onKeyDown(button)
			set waitfor = 0

		onKeyUp(button)
			set waitfor = 0

obj/gui/menu
	var
		content_blueprint
	var/tmp
		alist/vis_registry
		width = 32
		height = 32

	New()
		vis_registry = alist()

		if(content_blueprint)
			Blueprint(content_blueprint)

		if(!screen_loc)
			screen_loc = "CENTER:[(32 - width) / 2],CENTER:[(32 - height) / 2]"

		..()

	proc
		Blueprint(root)
			for(var/component in (typesof(root) - root))
				var/id = initial(component:id)
				if(id)
					var/obj/gui/c = new component(null,src)
					vis_contents += c
					vis_registry[id] = c

client
	var/tmp
		obj/gui/focus_target
	proc
		GUIFocus(obj/gui/target)
			if(focus_target)
				focus_target.onBlur(src)
				focus_target = null

			if(target)
				focus_target = target
				focus_target.onFocus(src)