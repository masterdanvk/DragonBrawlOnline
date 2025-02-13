/*
Beams are a type of skill with important and more complicated behavior.
Beams can collide with other beams and perform a beam struggle, whereas other projectiles have more of a simple rock/paper/scissors interaction - instantly overpowering certain types.
The concept to a beam is simple, a datum called Beam combines the objects base/beam/head in addition to the procs which handle moving the beam forward or retracting it.
Beam information such as the user, and other beams it is clashing with is handled in the Beam datum, the objects referenced in that datum are used for their hit detection
and appearance.
The three objects in the beam are rotated based on the angle of the attack, and the beam is scaled/stretched along its x axis to create the effect of a beam traveling.

Certain beams like special beam cannon can not be stretched in this way and maintain their appearance. Those use statebased=1
which instead results in the appearance of the beam being entirely animated within the icon states of the beam itself. This is clunkier to do the
graphics for but has a lot of animation fidelity.

*/




mob/proc/FireBeam(charge,maxdistance,Beam/B)
	var/mob/T
	if(src.client)T=src.Target()
	else T=src.targetmob
	if(T)T.counterbeam=src
	src.mybeam=B
	B.owner=src
	src.usingskill=1
	var/shortestdist=999

	for(var/obj/Beam/b in view(src,10))
		if(b.head && b.BeamParent.owner!=src)
			var/vector/diff=b.pixloc-src.pixloc
			if(diff.size<shortestdist)
				shortestdist=diff.size
				src.aim=b.BeamParent.owner.pixloc-src.pixloc
	if(!src.aim)
		src.Refundskillcost()
		src.icon_state=""
		if(src.bdir==EAST)
			src.transform=matrix()
			src.rotation=0
		else
			src.transform=matrix().Scale(-1,1)
			src.rotation=0
		src.usingskill=0
		src.CheckCanMove()

	var/vector/aimvector=src.aim

	var/vector/stepvector
	if(aimvector)stepvector=vector(aimvector)
	if(!aimvector||!aimvector.size||!stepvector)
		src.Refundskillcost()
		src.usingskill=0
		src.canmove=1
		return
	stepvector.size=8
	B.length=vector(stepvector)
	var/angle=vector2angle(aimvector)
	B.angle=angle
	src.AngleRotateMob(angle)
	for(var/obj/O in B.parts)
		var/matrix/m=new/matrix()
		m.TurnWithPivot(angle,O.bound_width/2,0)
		O.transform=m
	B.base.pixloc=bound_pixloc(src,0)+stepvector*3+vector(0,-12)
	B.beam.pixloc=B.base.pixloc+stepvector*2
	B.head.pixloc=B.beam.pixloc+stepvector
	B.stepv=stepvector
	for(var/mob/Hit in bounds(B.head))
		if(Hit!=src)B.hitmobs|=Hit
	for(var/mob/Hit in bounds(B.base))
		if(Hit!=src)B.hitmobs|=Hit
	for(var/obj/Beam/b in obounds(B.head))
		if(b.BeamParent!=B)
			B.head.Bump(b)
	var/distremaining=maxdistance
	while(distremaining>0)
		distremaining-=8
		if(B)
			for(var/mob/M in B.hitmobs)
				if(!B.pierce)M.Move(M.pixloc+stepvector)
				M.icon_state="hurt1"
			if(!B.clash)
				if(B.head.Move(B.head.pixloc+stepvector))
					B.length+=stepvector
					var/matrix/m=new/matrix()

					if(!B.statebased)m.TurnandScaleWithPivot(angle,(B.length.size+2)/B.beam.bound_width,1,B.beam.bound_width/2,0)
					else
						B.base.icon_state="[round(B.length.size/17,1)]"
					B.beam.transform=m
				else
					distremaining-=8
		var/plcompare
		if(B?.clash)
			plcompare=PLcompare(src,B.clash.owner)
		var/i=0
		var/equalize=1
		while(B&&B.clash&&B.clash.head?.loc)
			if(equalize)
				equalize=0
				if(!B.equalizing)
					var/equalizer=(B?.length.size-B.clash?.length.size)/2
					while(B&&B.clash&&B.clash.head?.loc&&abs(equalizer)>8)
						B.equalizing=1
						B.clash.equalizing=1
						if(equalizer>8)
							B.clash?.MoveForward()
							equalizer-=8
						else if(equalizer<-8)
							B?.MoveForward()
							equalizer+=8
						sleep(1)
					sleep(5)

			B?.equalizing=0
			B?.clash?.equalizing=0
			sleep(1)
			i++
			if(!B || !B.clash)break
			while(B&&B.clash&&(B.equalizing || B.clash.equalizing))
				sleep(1)
			if(!B || !B.clash)break
			var/underdogadvantage=0
			if(B.length.size<B.clash.length.size&&i<20)underdogadvantage=10
			if(src.beamtime>=B.clash.owner.beamtime)
				if(prob(plcompare*10+20+underdogadvantage+B.clashwins*2))
					B.MoveForward()
					B.clashwins++
					B.clash?.clashwins--
			else
				if(prob(plcompare*10+10+underdogadvantage+B.clashwins*2))
					B.MoveForward()
					B.clashwins++
					B.clash?.clashwins--




		sleep(world.tick_lag)
	var/explode=1
	for(var/mob/Hit in B?.hitmobs)
		if(Hit.invulnerable || Hit==src)continue
		Hit.CheckCanMove()
		Hit.icon_state=""
		if(explode)
			explode=0
			Explosion(/obj/FX/Explosion,bound_pixloc(Hit,0))
			destroy_turfs(bound_pixloc(Hit,0),70)
		spawn()
			if(Hit.block)
				Hit.Damage(B.power*PLcompare(src,Hit)*(1-B.blockreduce/100),10,0,src)
			else
				Hit.Damage(B.power*PLcompare(src,Hit),10,0,src)
	sleep(world.tick_lag)
	if(B)
		for(var/obj/O in B.parts)
			O.loc=null
			B.parts-=O
	src.icon_state=""
	if(src.bdir==EAST)
		src.transform=matrix()
		src.rotation=0
	else
		src.transform=matrix().Scale(-1,1)
		src.rotation=0
	src.usingskill=0
	if(T&&T.counterbeam)T.counterbeam=null
	src.CheckCanMove()

Beam/proc/MoveForward()
	if(src.clash)
		src.clash.MoveBackward()
	if(src.head.Move(src.head.pixloc+src.stepv))
		src.length+=src.stepv
		var/matrix/m=new/matrix()
		if(!statebased)m.TurnandScaleWithPivot(src.angle,(src.length.size+2)/src.beam.bound_width,1,src.beam.bound_width/2,0)
		else
			src.base.icon_state="[round(src.length.size/17,1)]"
		src.beam.transform=m

Beam/proc/MoveBackward()

	if(src.head.Move(src.head.pixloc-src.stepv))
		src.length-=src.stepv
	//	world<<"[src.head] length [src.length.size]"
		if(src.length.size<=24)
			src.clash?.head.icon_state="head"
			src.clash?.head.appearance_flags=KEEP_TOGETHER
			src.head.loc=null
			src.beam.loc=null
			src.base.loc=null
			src.clash?.clash=null
			src.clash=null
			var/mob/O=src.owner
			O.canmove=0
			O.usingskill=0
			spawn(10)O.CheckCanMove()
			del(src)

		var/matrix/m=new/matrix()
		spawn(world.tick_lag)
			if(!statebased)m.TurnandScaleWithPivot(src.angle,(src.length.size+2)/src.beam.bound_width,1,src.beam.bound_width/2,0)
			else
				src.base.icon_state="[round(src.length.size/17,1)]"
			src.beam.transform=m
	else
		src.clash?.head.icon_state="head"
		src.clash?.head.appearance_flags=KEEP_TOGETHER
		src.head.loc=null
		src.beam.loc=null
		src.base.loc=null
		src.clash?.clash=null
		src.clash=null
		var/mob/O=src.owner
		O.canmove=0
		O.usingskill=0
		spawn(10)O.CheckCanMove()
		del(src)
Beam/var/equalizing=0




obj/var/Beam/BeamParent
Beam
	Dondonpa
		power=30
		New()
			..()
			src.base=new/obj/Beam/Dondonpa/Base
			src.head=new/obj/Beam/Dondonpa/Head
			src.beam=new/obj/Beam/Dondonpa/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Masenko
		power=38
		New()
			..()
			src.base=new/obj/Beam/Masenko/Base
			src.head=new/obj/Beam/Masenko/Head
			src.beam=new/obj/Beam/Masenko/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Galekgun
		power=50
		New()
			..()
			src.base=new/obj/Beam/Galekgun/Base
			src.head=new/obj/Beam/Galekgun/Head
			src.beam=new/obj/Beam/Galekgun/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Doublesunday
		power=50
		New()
			..()
			src.base=new/obj/Beam/Doublesunday/Base
			src.head=new/obj/Beam/Doublesunday/Head
			src.beam=new/obj/Beam/Doublesunday/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Mouthblast
		power=80
		New()
			..()
			src.base=new/obj/Beam/Mouthblast/Base
			src.head=new/obj/Beam/Mouthblast/Head
			src.beam=new/obj/Beam/Mouthblast/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Tribeam
		power=50

		New()
			..()
			src.base=new/obj/Beam/Tribeam/Base
			src.head=new/obj/Beam/Tribeam/Head
			src.beam=new/obj/Beam/Tribeam/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Kamehameha
		power=50
		New()
			..()
			src.base=new/obj/Beam/Kamehameha/Base
			src.head=new/obj/Beam/Kamehameha/Head
			src.beam=new/obj/Beam/Kamehameha/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Specialbeamcannon
		statebased=1
		pierce=1
		power=80
		blockreduce=0
		New()
			..()
			src.base=new/obj/Beam/SBC/Base
			src.head=new/obj/Beam/SBC/Head
			src.beam=new/obj/Beam/SBC/Beam
			src.base.BeamParent=src
			src.head.BeamParent=src
			src.beam.BeamParent=src
			parts=new/list
			parts+=src.base
			parts+=src.head
			parts+=src.beam
	Del()
		for(var/obj/O in src.parts)
			O.loc=null
			src.parts-=O
		var/Beam/C=src.clash
		if(C)
			C.clash=null
			src.clash=null
		..()
	var
		vector/length
		obj/base
		obj/head
		obj/beam
		list/parts
		mob/owner
		mob/target
		Beam/clash
		hitmobs[0]
		power=50
		vector/stepv
		angle
		clashwins
		statebased=0
		pierce=0
		blockreduce=25



obj/Beam
	appearance_flags=KEEP_TOGETHER
	var
		head=0
		beamstruggle=0

	Cross(atom/A)
		if(istype(A,/mob)&&src.owner==A) return 1
		if(istype(A,/obj))
			if(!A.density)
				return 1
			if(A:owner&&A:owner==src.owner)
				return 1
			if(istype(A,/obj/Kiblast))
				return 1

		if(istype(A,/mob) && src.BeamParent.pierce)
			if(istype(A,/mob) && !A:invulnerable)
				src.BeamParent.hitmobs|=A
			return 1
		..()
	on_cross(atom/A)
		if(istype(A,/mob)&&src.owner==A) return 1
		if(istype(A,/obj))
			if(!A.density)return 1
			if(A:owner&&A:owner==src.owner)
				return 1
			if(istype(A,/obj/Kiblast)&&!istype(A,/obj/Kiblast/Spiritbomb))
				return 1
		if(istype(A,/mob) && src.BeamParent.pierce)
			if(istype(A,/mob) && !A:invulnerable)
				src.BeamParent.hitmobs|=A
			return 1
		..()
	SBC
		icon=null

		Base
			icon='specialbeamcannon2.dmi'
			icon_state="0"
			layer=OBJ_LAYER+0.1
			bound_width=256
			pixel_z=6

		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=32
			density=1
			head=1
		Beam
			icon=null

	Tribeam
		icon='tribeam.dmi'
		Base
			icon=null
			layer=OBJ_LAYER+0.1

		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1
			alpha=180
		Beam
			icon=null
	Masenko
		icon='masenko.dmi'
		Base
			icon_state="start"
			layer=OBJ_LAYER+0.1
			bound_width=64
			pixel_z=-16
		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1
		Beam
			icon_state="yellow"
			icon='beam.dmi'
			bound_width=8
			pixel_z=-16
	Doublesunday
		icon='doublesunday.dmi'
		Base
			icon_state="start"
			layer=OBJ_LAYER+0.1
			bound_width=64
			pixel_z=-16
		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1
		Beam
			icon_state="doublesunday"
			icon='beam.dmi'
			bound_width=8
			pixel_z=-16
	Mouthblast
		icon='mouthblast.dmi'
		Base
			icon_state="start"
			layer=OBJ_LAYER+0.1
			bound_width=64
			pixel_z=-16
		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1
		Beam
			icon_state="mouthblast"
			icon='beam.dmi'
			bound_width=8
			pixel_z=-16
	Galekgun
		icon='galekgun.dmi'
		Base
			icon_state="start"
			layer=OBJ_LAYER+0.1
			bound_width=64
			pixel_z=-16
		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1
		Beam
			icon_state="purple"
			icon='beam.dmi'
			bound_width=8
			pixel_z=-16
	Dondonpa
		icon='dondonpa.dmi'
		Base
			icon_state="start"
			layer=OBJ_LAYER+0.1
			bound_width=64
			pixel_z=-16
		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1

		Beam
			icon_state="dondonpa"
			icon='beam.dmi'
			bound_width=8
			pixel_z=-16
	Kamehameha
		icon='kamehameha.dmi'
		Base
			icon_state="start"
			layer=OBJ_LAYER+0.1
			bound_width=64
			pixel_z=-16
		Head
			icon_state="head"
			layer=MOB_LAYER+0.2
			bound_width=64
			pixel_z=-16
			density=1
			head=1

		Beam
			icon_state="blue"
			icon='beam.dmi'
			bound_width=8
			pixel_z=-16
	Bump(atom/A)
		if(istype(A,/obj)&&A:destructible)
			A:Destroy_Landscape()
		if(istype(A,/mob) && !A:invulnerable &&!src.BeamParent.clash)
			if(src.BeamParent && src.BeamParent!=A)
				src.BeamParent.hitmobs|=A
				A:stunned=world.time+10

		if(istype(A,/obj/Beam)&&abs(A:BeamParent.angle-src.BeamParent.angle)>140&&abs(A:BeamParent.angle-src.BeamParent.angle)<220)
			if(src.BeamParent && A:BeamParent && src.BeamParent!=A:BeamParent && A:head && !A:BeamParent.clash && !src.BeamParent.clash)
				src.BeamParent.clash=A:BeamParent
				A:BeamParent.clash=src.BeamParent

				src.BeamParent.head.icon_state="clash"
				A:BeamParent.head.icon_state="clash"
		if(istype(A,/obj/Kiblast/Spiritbomb))
			src.BeamParent.base.loc=null
			src.BeamParent.head.loc=null
			src.BeamParent.beam.loc=null
		else if(istype(A,/obj/Kiblast))
			var/obj/Kiblast/B=A
			if(B.destroyable)
				B.Explode()
				B.loc=null


		..()


