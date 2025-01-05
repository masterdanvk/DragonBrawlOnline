
client/var/list/gdialogue[0]
client/var/obj/gui/dialogue/main/parentdialogue

client/proc/BuildDialogue()
	var/list/d =typesof(/obj/gui/dialogue)
	var/obj/gui/dialogue/main/M
	for(var/D in d)
		var/obj/O=new D
		gdialogue+=O
		if(istype(O,/obj/gui/dialogue/main))
			M=O
			src.parentdialogue=O

	for(var/obj/gui/dialogue/O in gdialogue)
		switch(O.type)
			if(/obj/gui/dialogue/option)
				M.options[1]=O
			if(/obj/gui/dialogue/option/o2)
				M.options[2]=O
			if(/obj/gui/dialogue/option/o3)
				M.options[3]=O
			if(/obj/gui/dialogue/option/o4)
				M.options[4]=O
			if(/obj/gui/dialogue/option/o5)
				M.options[5]=O
			if(/obj/gui/dialogue/)
				M.title=O

client/proc/ShowDialogue(title,body,list/options)
	var/obj/gui/dialogue/main/M=src.parentdialogue
	src.indialogue=1
	src.screen|=M.title
	M.maptext="<span style='text-align:left;vertical-align:top;font-size:10px;'>[body]</span>"
	M.title.maptext="<span style='text-align:center;vertical-align:bottom;font-size:10px;'>[title]</span>" //text-shadow:0 -1px 0 #FFFFFF
	src.choices=null
	if(options.len)
		src.choices=options
		M.options[1].dir=SOUTH
		for(var/obj/gui/dialogue/option/O in M.options)
			O.icon_state="inactive"
			if(O!=M.options[1]&&O!=M.options[options.len]) O.dir=EAST
			if(O.optioncount<=options.len)
				O.maptext="[options[O.optioncount]]"
				src.screen|=O


		M.options[1].icon_state="active"
		src.pendingchoice=1
		M.options[options.len].dir=NORTH

		src.choice=null
		src.screen|=M
		while(!src.choice)
			sleep(10)
		for(var/obj/O in gdialogue)
			src.screen-=O

		return options[src.choice]
	else
		src.screen|=M





client/var/choice=null
client/var/pendingchoice=null
client/var/choices[0]
client/var/indialogue=0

client/New()
	..()
	src.BuildDialogue()

client/proc/NextChoice()
	src.pendingchoice++
	if(src.pendingchoice>src.choices.len)src.pendingchoice=1
	var/obj/gui/dialogue/option/A=src.parentdialogue.options[src.pendingchoice]
	A.icon_state="active"
	for(var/obj/gui/dialogue/option/O in src.gdialogue)
		if(O!=A)
			O.icon_state="inactive"


client/proc/PrevChoice()
	src.pendingchoice--
	if(src.pendingchoice<=0)src.pendingchoice=src.choices.len
	var/obj/gui/dialogue/option/A=src.parentdialogue.options[src.pendingchoice]
	A.icon_state="active"
	for(var/obj/gui/dialogue/option/O in src.gdialogue)
		if(O!=A)
			O.icon_state="inactive"

client/proc/MakeChoice()
	src.choice=src.pendingchoice
	src.indialogue=0
	src.screen-=src.gdialogue


obj/gui

	dialogue //parent does the title
		layer = FLOAT_LAYER
		plane = FLOAT_PLANE+4
		screen_loc="CENTER-8:+22,CENTER+5:+6"
		maptext_width=200
		maptext_height=30
		main
			icon='gui/dialoguewide.dmi'
			screen_loc="CENTER-8,CENTER:-8"
			maptext_x=21
			maptext_y=7
			maptext_width=500
			maptext_height=160
			var/options[5]
			var/obj/title
			plane=FLOAT_PLANE


		option
			var/optioncount=1
			maptext_x=38
			maptext_y=7
			maptext_width=480
			plane=FLOAT_PLANE+5
			layer=FLOAT_LAYER+0.01
			icon='gui/optionswide.dmi'
			dir=EAST
			icon_state="inactive"
			screen_loc="CENTER-8,CENTER-1:-2" //24 pixels down each iteration
			o2
				optioncount=2
				screen_loc="CENTER-8,CENTER-1:-26"
				plane=FLOAT_PLANE+6
			o3
				optioncount=3
				screen_loc="CENTER-8,CENTER-2:-18"
				plane=FLOAT_PLANE+7
			o4
				optioncount=4
				screen_loc="CENTER-8,CENTER-3:-10"
				plane=FLOAT_PLANE+8
			o5
				optioncount=5
				screen_loc="CENTER-8,CENTER-5:-1"
				plane=FLOAT_PLANE+9
			Click()
				usr.client.choice=src.optioncount
				usr.client.screen-=usr.client.gdialogue
				usr.client.indialogue=0

			MouseEntered()
				src.icon_state="active"
				usr.client?.pendingchoice=src.optioncount
				for(var/obj/gui/dialogue/option/O in usr.client?.gdialogue)
					if(O!=src)
						O.icon_state="inactive"



