var
	alist/FX

//World
//	New()
//		..()
//		FX=new/alist

obj
	FX
		density=0
		layer=MOB_LAYER+1
		var
			duration=3
		New()
			..()
			if(!FX["[src.type]"])FX["[src.type]"]=new/list()
			FX["[src.type]"]|=src
		Del()
			FX["[src.type]"]-=src
			..()

		Smack
			icon='fx_smack.dmi'
			pixel_z=-32
			pixel_w=-32
			duration=5
			bound_width=32
			bound_height=64
			alpha=200
		Smash
			icon='fx_smash.dmi'
			pixel_z=-32
			pixel_w=-32
			duration=6
			bound_width=64
			bound_height=64
			alpha=180
		Explosion
			icon='fx_explosion.dmi'
			pixel_z=-48
			pixel_w=-48
			duration=12
			bound_width=96
			bound_height=96
			alpha=200


mob/proc/Flash(t=1.5,intensity)
	var/white_flash = list(intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100,intensity/100)
	animate(src, color = white_flash, time = t)
	sleep(t)
	animate(src, color = null, time = 1)
proc/Explosion(P,pixloc/L,rotation,scalex,scaley)
	set waitfor = 0

	if(!ispath(P))
		world<<"P isnt a path"
		return
	if(!istype(L,/pixloc))
		//world<<"L is not a pixloc"
		return
	var/obj/FX/O

	if(FX["[P]"]&&FX["[P]"].len)
		for(var/obj/FX/o in FX["[P]"])
			O=o
			FX["[P]"]-=o
			break
	if(!O)O=new P
	O.pixloc=L
	if(rotation||scalex||scaley)
		var/matrix/m=new/matrix
		m.Translate(-O.bound_width/2,0)
		m.Turn(rotation)
		if(scalex&&scaley)m.Scale(scalex,scaley)
		m.Translate(O.bound_width/2,0)
		O.transform=m
	O.icon_state="explode"
	sleep(O.duration)
	O.icon_state=""
	O.loc=null
	O.transform=null
	if(!FX["[P]"])FX["[P]"]=new/list
	FX["[P]"]|=O
