var
	alist/FX

//World
//	New()
//		..()
//		FX=new/alist

obj
	personalelectricity
		layer=MOB_LAYER+1
		density=0
		icon='elec2.dmi'
		bound_width=64
		bound_height=64
		pixel_w=-16
	lightningarmor
		layer=MOB_LAYER+1
		density=0
		icon='elec3.dmi'
		bound_width=64
		bound_height=64
		pixel_w=-16
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
		ExplosiveDemonWave
			icon='explosivedemonwave.dmi'
			bound_width=90
			bound_height=64
			pixel_z=-42
			bound_x=14
			pixel_w=0
			bound_x=0
			density=0

		Solarflare
			icon='solarflare.dmi'
			pixel_z=-32
			pixel_w=-72
			duration=5
			bound_width=144 //144,96
			bound_height=96
			density=0
		Forcewave
			icon='fx_push.dmi'
			duration=9
			bound_width=96
			bound_height=96
			density=0
			pixel_z=-32
		//	pixel_w=-48
			alpha=200

		Explosivewave
			icon='explosivewave.dmi'
			duration=6
			bound_width=128
			bound_height=128
			density=0
			pixel_z=-64
			pixel_w=-64

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


atom/proc/Flash(t=1.5,intensity)
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
			if(istype(o,P))
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
	O.transform=null
	if(!FX["[P]"])FX["[P]"]=new/list
	FX["[P]"]|=O
	O.loc=null

mob/proc/Create_Aura(color)
	var/obj/O=new/obj
	var/obj/U=new/obj
	U.layer=MOB_LAYER-0.2
	O.layer=MOB_LAYER+0.1
	if(src.aura)del(src.aura)
	if(src.auraover)del(src.auraover)
	src.aura=U
	src.auraover=O
	U.icon='Icons/Effects/aura.dmi'
	O.icon='Icons/Effects/aura.dmi'
	U.icon_state="none"
	O.icon_state="none"
	O.alpha=80
	U.alpha=200
	O.pixel_x=-36
	U.pixel_x=-36
	U.pixel_z=-4
	O.pixel_z=-4
	var/col
	switch(color)
		if("Blue")
			col=rgb(50,80,180)
		if("White")
			O.alpha=50
			col=rgb(160,160,160)
		if("Yellow")
			O.alpha=50
			col=rgb(225,210,30)
		if("Lightyellow")
			O.alpha=50
			U.alpha=150
			col=rgb(255,240,150)
		if("Red")
			O.alpha=50
			col=rgb(225,50,50)
		if("Lightgreen")
			O.alpha=50
			U.alpha=150
			col=rgb(100,180,130)

		if("Purple")
			O.alpha=50
			col=rgb(222,132,255)
		if("SSJ2")
			O.alpha=50
			col=rgb(225,210,30)
			O.vis_contents+=new/obj/electricity
			U.vis_contents+=new/obj/dustup
		if("Lightningarmor")
			O.alpha=50
			col=rgb(255,240,150)
			O.transform=matrix().Scale(1.3).Translate(0,15)
			U.transform=matrix().Scale(1.3).Translate(0,15)
			O.vis_contents+=new/obj/lightning
			U.vis_contents+=new/obj/dustup
		if("Orange")
			O.alpha=50
			col=rgb(185,110,30)
			O.transform=matrix().Scale(1.3).Translate(0,15)
			U.transform=matrix().Scale(1.3).Translate(0,15)
			U.vis_contents+=new/obj/dustup
	U.icon+=col
	O.icon+=col

obj/electricity
	layer=MOB_LAYER+0.2
	icon='elec.dmi'
	bound_width=69
	bound_height=65
	pixel_w=14
	appearance_flags=RESET_ALPHA

obj/lightning
	layer=MOB_LAYER+0.2
	icon='lightning.dmi'
	bound_width=69
	bound_height=65
	pixel_w=14
	appearance_flags=RESET_ALPHA
obj/dustup
	appearance_flags=RESET_TRANSFORM|RESET_ALPHA
	icon='dustup.dmi'
	bound_width=256
	bound_height=96
	pixel_w=-80
	pixel_z=-48
