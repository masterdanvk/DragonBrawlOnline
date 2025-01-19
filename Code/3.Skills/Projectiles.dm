

mob/proc/Energy_Blast(time,obj/Kiblast/K,vector/offset,icon/customki)
	if(!offset)offset=new/vector(0,0)
	K.owner=src
	if(customki)K.icon=customki
	if(!src.aim)
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
	var/turnd=round(rand(-K.spread,K.spread),1)
	if(aimvector)aimvector.Turn(turnd)

	if(!aimvector||!aimvector.size)
		src.usingskill=0
		src.canmove=1
		return
	var/vector/stepvector=vector(aimvector)
	stepvector.size=K.speed
	if(!stepvector)
		src.usingskill=0
		src.canmove=1
		return
	var/angle=vector2angle(aimvector)
	if(K.carryowner)
		src.RotateMob(stepvector,100)
	var/matrix/m=new/matrix()
	if(K.rotate)
		m.TurnWithPivot(angle,K.bound_width/2,0,K.axisflip)
		K.transform=m
	K.pixloc=bound_pixloc(src,0)+stepvector+offset+vector(K.xoffset,K.yoffset)
	K.stepv=stepvector

	spawn(3)
		if(src.icon_state=="blast1")
			src.icon_state=""
	src.usingskill=0
	src.CheckCanMove()
	for(var/mob/Hit in bounds(K))
		if(Hit!=src)K.hitmobs|=Hit
	var/distremaining=K.distance
	var/list/hitlist=new/list
	K.step_size=K.speed
	turnd*=2
	var/vector/offsetleft=vector(offset)
	var/correctpace=turnd*K.speed/K.distance
	while(distremaining>0)

		distremaining-=K.speed

		if(K.push)
			for(var/mob/M in K.hitmobs)
				M.Move(M.pixloc+stepvector)
				M.icon_state="hurt1"
		else
			if(K.hitmobs.len && !K.pierce)
				distremaining=0
				break

		var/vector/offsetchg=vector(offsetleft)
		if(offsetchg.size>3)offsetchg.size=3
		offsetleft.size=offsetleft.size-offsetchg.size
		if(K.homing)
			var/mob/target
			if(src.lastattacked&&src.lastattacked.z==src.z)target=src.lastattacked
			else if(src.lastattackedby&&src.lastattackedby.z==src.z)target=src.lastattackedby
			else
				for(var/mob/M in bound_pixloc(K,80))
					target=M

			if(target)
				var/curangle=vector2angle(stepvector)
				var/vector/idealvector=target.pixloc-K.pixloc
				var/idealangle=vector2angle(idealvector)
				if(abs(curangle-idealangle)==180)
					stepvector.Turn(180)
				if(abs(curangle-idealangle)<=10)
					var/vsize=stepvector.size
					stepvector=idealvector
					stepvector.size=vsize
				else
					var/anglediff=idealangle-curangle
					if((anglediff>0 && anglediff<=180)||(anglediff<0 && anglediff<-180))
						stepvector.Turn(-10)
					else
						stepvector.Turn(10)
				m=new/matrix()
				if(K.rotate)
					m.TurnWithPivot(vector2angle(stepvector),K.bound_width/2,0,K.axisflip)
					K.transform=m



		K.Move(K.pixloc+stepvector-offsetchg)
		if(K.carryowner)
			step(K.owner,stepvector)
		//	K.owner.Move(K.pixloc+stepvector-offsetchg)
		for(var/mob/Hit in K?.hitmobs)
			if(Hit.invulnerable || Hit==src||(Hit in hitlist))
				if(K.repeathit)
					K.repeathit=0
					var/hom=K.homing
					K.homing=0
					spawn(5)
						K.repeathit=1
						K.homing=hom
						hitlist-=Hit
						K.hitmobs-=Hit
				continue
			Hit.CheckCanMove()
			hitlist|=Hit
			Hit.icon_state=""
			if(K.explode)
				K.explode=0
				K.Explode()
			spawn()
				if(Hit.block)
					Hit.Damage(K.power*PLcompare(src,Hit)*(1-K.blockreduce/100),K.impact,0,src)
				else
					Hit.Damage(K.power*PLcompare(src,Hit),K.impact,0,src)
					Hit.icon_state="hurt1"
					spawn(5)
						if(Hit&&Hit.icon_state=="hurt1")Hit.icon_state=""
			//	world<<"Damage from [K] is [K.power*PLcompare(src,Hit)]"
		sleep(world.tick_lag)
		if(turnd)
			stepvector.Turn(-correctpace)
			turnd-=correctpace
			angle=vector2angle(stepvector)
			m=new/matrix()
			if(K.rotate)
				m.TurnWithPivot(angle,K.bound_width/2,0,K.axisflip)
				K.transform=m
	if(!K.persist)K.Explode()
	var/list/hits=K.hitmobs
	for(var/mob/Hit in hits)
		if(Hit.invulnerable || Hit==src||(Hit in hitlist))continue
		Hit.CheckCanMove()
		hitlist|=Hit
		Hit.icon_state="hurt1"
		spawn(5)
			if(Hit.icon_state=="hurt1")
				Hit.icon_state=""
		spawn()Hit.Damage(K.power*PLcompare(src,Hit),K.impact,0,src)
	sleep(world.tick_lag)
	if(!K.persist)
		if(K)K.loc=null

mob/proc/Shootto(obj/Kiblast/K,pixloc/P)
	K.owner=src

	if(!P || !K.pixloc)return
	var/vector/stepvector=P-K.pixloc
	var/distremaining=stepvector.size
	stepvector.size=K.speed
	K.stepv=stepvector
	for(var/mob/Hit in bounds(K))
		if(Hit!=src)K.hitmobs|=Hit
	var/list/hitlist=new/list
	K.step_size=K.speed
	if(K.rotate)
		var/matrix/m=matrix()
		m.TurnandScaleWithPivot(vector2angle(stepvector),K.scale,K.scale,K.bound_width/2,0,K.axisflip)
		K.transform=m
	while(distremaining>0)

		distremaining-=K.speed

		if(K.push)
			for(var/mob/M in K.hitmobs)
				M.Move(M.pixloc+stepvector)
				M.icon_state="hurt1"
		else
			if(K.hitmobs.len && !K.pierce)
				distremaining=0
				break
		K.Move(K.pixloc+stepvector)

		for(var/mob/Hit in K?.hitmobs)
			if(Hit.invulnerable || Hit==src||(Hit in hitlist))
				continue
			Hit.CheckCanMove()
			hitlist|=Hit
			Hit.icon_state=""
			if(K.explode)
				K.explode=0
				K.Explode()
			spawn()
				if(Hit.block)
					Hit.Damage(K.power*PLcompare(src,Hit)*(1-K.blockreduce/100),K.impact,0,src)
				else
					Hit.Damage(K.power*PLcompare(src,Hit),K.impact,0,src)
					Hit.icon_state="hurt1"
					spawn(5)
						if(Hit&&Hit.icon_state=="hurt1")Hit.icon_state=""

		sleep(world.tick_lag)
	if(K&&!K.persist)K.Explode()
	var/list/hits=K.hitmobs
	for(var/mob/Hit in hits)
		if(Hit.invulnerable || Hit==src||(Hit in hitlist))continue
		Hit.CheckCanMove()
		hitlist|=Hit
		Hit.icon_state="hurt1"
		spawn(5)
			if(Hit.icon_state=="hurt1")
				Hit.icon_state=""
		spawn()Hit.Damage(K.power*PLcompare(src,Hit),K.impact,0,src)
	sleep(world.tick_lag)
	if(K&&!K.persist)K.loc=null

obj/Kiblast
	proc/Explode()
	Cross(atom/A)
		if(istype(A,/mob)&&src.owner==A) return 1
		if(istype(A,/obj))
			if(src.passthroughobjs)return 1
			if(A:owner&&A:owner==src.owner)
				return 1
		if(istype(A,/mob) && src.pierce)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A
			return 1
		..()
	on_cross(atom/A)
	//	world<<"on_cross [A] [A.type]"
		if(istype(A,/mob)&&src.owner==A) return 1
		if(!A.density) return 1
		if(istype(A,/obj))
			if(src.passthroughobjs)return 1
			if(A:owner&&A:owner==src.owner)
				return 1

		if(istype(A,/mob) && src.pierce)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A
			return 1
		..()
	Bump(atom/A)
	//	world<<"src[src] bumped [A]"
		if(istype(A,/mob) && !A:invulnerable)
			src.hitmobs|=A



		else if(istype(A,/obj/Beam)||istype(A,/obj/Kiblast/Spiritbomb))
			src.Explode()
			src.loc=null
		else if(src.destroyable&&istype(A,/obj/Kiblast)&&A:owner!=src.owner)
			src.Explode()
			src.loc=null

		//else
		//	src.loc=null

		..()
	var
		pierce=0
		push=0
		stun=0
		spread=0
		hitmobs[0]
		vector/stepv
		distance=300
		speed=8
		power
		impact=0
		rotate=1
		explode=0
		charge=0
		passthroughobjs=0
		homing=0
		repeathit=0
		carryowner=0
		axisflip=0
		blockreduce=50
		xoffset=0
		yoffset=0
		persist=0
		destroyable=0


	Spiritbomb
		icon='spiritbomb.dmi'
		layer=MOB_LAYER+1
		bound_width=128
		bound_height=128
		density=1
		spread=0
		distance=500
		speed=6
		power=50
		impact=0
		rotate=0
		pierce=0
		blockreduce=25

		passthroughobjs=1
		push=1
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			Explosion(/obj/FX/Explosion,bound_pixloc(src,0),0,1+src.charge*0.05,1+src.charge*0.05)
			destroy_turfs(bound_pixloc(src,0),max(40,16*(1+0.5*src.charge)))
			if(bounds(bound_pixloc(src,0)))
				for(var/mob/M in bounds(bound_pixloc(src,0),max(40,16*(1+0.5*src.charge))))
					if(M!=src.owner)src.hitmobs|=M
				//	sleep(1)
			src.loc=null
			..()
	Destructodisc
		icon='destructodisc.dmi'
		layer=MOB_LAYER
		bound_width=63
		bound_height=23
		density=1
		spread=0
		distance=500
		speed=8
		power=50
		impact=0
		rotate=0
		pierce=1
		blockreduce=0
		Bump(atom/A)
			if(istype(A,/obj)&&A:destructible)
				A:Destroy_Landscape()
			..()
		Explode()
			src.icon=null
			src.loc=null
			..()
	HellzoneGrenade
		icon='spiritball.dmi'
		layer=MOB_LAYER
		bound_width=32
		bound_height=21
		density=1
		spread=0
		distance=500
		speed=8
		power=1
		impact=0
		push=0
		pierce=1
		homing=0
		repeathit=0
		spread=0
		explode=0
		persist=1
		scale=0.5
		destroyable=1
		New()
			..()
			src.scale=pick(0.6,0.40,0.5,0.55,0.35)
			src.transform=matrix().Scale(src.scale)

		Bump(atom/A)
			if(istype(A,/obj)&&A:destructible)
				A:Destroy_Landscape()
			..()
		Explode()
			src.icon=null
			Explosion(/obj/FX/Explosion,bound_pixloc(src,0),0,0.5,0.5)
			src.loc=null
			..()
	Spiritball
		icon='spiritball.dmi'
		layer=MOB_LAYER
		bound_width=64
		bound_height=42
		density=1
		spread=0
		distance=1000
		speed=12
		power=20
		impact=0
		pierce=1
		homing=1
		repeathit=1
		Bump(atom/A)
			if(istype(A,/obj)&&A:destructible)
				A:Destroy_Landscape()
			..()
		Explode()
			src.icon=null
			Explosion(/obj/FX/Explosion,bound_pixloc(src,0),0,0.5,0.5)
			src.loc=null
			..()
	WFF
		icon='wolffangfist.dmi'
		alpha=150
		layer=MOB_LAYER+1
		bound_width=96
		bound_height=64
		icon_z=32
		distance=400
		speed=12
		power=40
		carryowner=1
		pierce=1
		axisflip=1
		blockreduce=65
		density=0

	Dragonfist
		icon='dragonfist.dmi'
		alpha=150
		layer=MOB_LAYER+1
		bound_width=283
		bound_height=171
		pixel_z=-70
		pixel_w=-40
		distance=500
		speed=12
		power=65
		carryowner=1
		pierce=1
		axisflip=1
		blockreduce=35

	Energyblast
		icon='energyblast.dmi'
		layer=MOB_LAYER+1
		bound_width=64
		bound_height=64
		yoffset=-16
		density=1
		spread=0
		distance=500
		speed=8
		power=40
		impact=60
		explode=0
		push=1
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			spawn()
				Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
				destroy_turfs(bound_pixloc(src,0),100)
				for(var/mob/M in bound_pixloc(src,0),100)
					if(M!=src.owner)src.hitmobs|=M

					sleep(1)
			spawn(5)src.loc=null
			..()

	Burningattack
		icon='burningattack.dmi'
		layer=MOB_LAYER+1
		bound_width=124
		bound_height=135
		yoffset=-67
		density=1
		spread=0
		distance=500
		speed=12
		power=34
		impact=30
		explode=1
		push=0
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			spawn()
				Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
				destroy_turfs(bound_pixloc(src,0),40)
				for(var/mob/M in bound_pixloc(src,0),40)
					if(M!=src.owner)src.hitmobs|=M

					sleep(1)
			spawn(5)src.loc=null
			..()
	Bigbangattack
		icon='bigbangattack.dmi'
		layer=MOB_LAYER+1
		bound_width=105
		bound_height=106
//		xoffset=-52
		yoffset=-53
//		bound_x=-52
//		bound_y=-53
//		pixel_z=-53
		density=1
		spread=0
		distance=500
		speed=8
		power=40
		impact=60
		explode=0
		push=1
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			spawn()
				Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
				destroy_turfs(bound_pixloc(src,0),100)
				for(var/mob/M in bound_pixloc(src,0),100)
					if(M!=src.owner)src.hitmobs|=M

					sleep(1)
			spawn(5)src.loc=null
			..()
	Saturdaycrush
		icon='saturdaycrush.dmi'
		layer=MOB_LAYER+1
		bound_width=74
		bound_height=112
		yoffset=-56
		density=1
		spread=0
		distance=500
		speed=8
		power=40
		impact=60
		explode=0
		push=1
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			spawn()
				Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
				destroy_turfs(bound_pixloc(src,0),100)
				for(var/mob/M in bound_pixloc(src,0),100)
					if(M!=src.owner)src.hitmobs|=M

					sleep(1)
			spawn(5)src.loc=null
			..()
	Mouthblast
		icon='mouthblast.dmi'
		layer=MOB_LAYER+1
		bound_width=74
		bound_height=112
		bound_x=-37
		bound_y=-56
		pixel_z=-56
		density=1
		spread=0
		distance=600
		speed=12
		power=60
		impact=120
		explode=0

		push=1
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			spawn()
				Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
				destroy_turfs(bound_pixloc(src,0),100)
				for(var/mob/M in bound_pixloc(src,0),100)
					if(M!=src.owner)src.hitmobs|=M

					sleep(1)
			spawn(5)src.loc=null
			..()
	Sliceblast
		icon='sliceblast.dmi'
		bound_width=32
		bound_height=64
		density=1
		spread=0
		distance=250
		yoffset=-28
		xoffset=6
		speed=12
		power=4
		pierce=1
		New()
			..()
			animate(src,alpha=150,time=1.5)

		Bump(atom/A)
			if(istype(A,/obj))
				if(A:destructible)
					A:Destroy_Landscape()
				src.Explode()
				src.loc=null
			..()
		Explode()

			src.icon=null
			src.loc=null
			..()
	Fingerlaser
		icon='fingerlaser.dmi'
		bound_width=32
		bound_height=17
		density=1
		spread=0
		distance=400
		xoffset=-10
		yoffset=-18
		speed=12
		power=4
		impact=1
		explode=1

		Bump(atom/A)
			if(istype(A,/obj))
				if(A:destructible)
					A:Destroy_Landscape()
				src.Explode()
				src.loc=null
			..()
		Explode()
			src.icon=null
			Explosion(/obj/FX/Explosion,bound_pixloc(src,0),0,0.25,0.25)
			src.loc=null
			..()
	Gun
		icon='bullet.dmi'
		bound_width=32
		bound_height=17
		yoffset=27
		density=1
		spread=0
		distance=400
		yoffset=-27
		xoffset=-10
		speed=16
		power=0.1
		impact=0
		explode=1

		Bump(atom/A)
			if(istype(A,/obj))
				src.Explode()
				src.loc=null
			..()
		Explode()
			src.loc=null
			..()
	Basic
		icon='kiblast.dmi'
		bound_width=19
		bound_height=19
		icon_w=8
		density=1
		spread=20
		distance=400
		speed=12
		power=5
		impact=5
		explode=1
		Bump(atom/A)
			if(istype(A,/obj))
				if(A:destructible)
					A:Destroy_Landscape()
				src.Explode()
				src.loc=null
			..()
		Explode()
			src.icon=null
			Explosion(/obj/FX/Explosion,bound_pixloc(src,0),0,0.5,0.5)
			src.loc=null
			..()
