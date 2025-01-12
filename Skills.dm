


mob/var/tmp/Skill/equippedskill
mob/var/tmp/kiblast=/obj/Kiblast/Basic
obj/var
	mob/owner
mob/proc/UseSkill(time)
	if(!src.equippedskill)return
	if(src.Take_Ki(src.equippedskill.kicost))
	//check ki sufficient
		src.equippedskill.Use(src,time)
	else
		var/red = list(100,40,40,40,40,40,40,40,40,40,40,40)
		animate(src.gui_kibar,color=red,time=3)
		sleep(3)
		animate(src.gui_kibar, color = null, time = 1)
		src.usingskill=0
		src.canmove=1
		src.icon_state=""
		return

mob/proc/UseKiBlast()
	if(src.holdskill)
		src.holdskill:loc=null
		src.holdskill=null
	if(src.Take_Ki(5))
	//check ki sufficient
		src.icon_state="blast2"
		var/obj/Kiblast/K=new src.kiblast
		src.Energy_Blast(0,K)
		src.icon_state=""
	else
		var/red = list(100,40,40,40,40,40,40,40,40,40,40,40)
		animate(src.gui_kibar,color=red,time=3)
		sleep(3)
		animate(src.gui_kibar, color = null, time = 1)
		src.usingskill=0
		src.canmove=1
		src.icon_state=""
		return


mob/verb/ChangeSkill()
	var/S=input(usr,"Change your skill","Skill",src.equippedskill) in typesof(/Skill)
	if(usr.skills.len<7)
		usr.skills+=new S
	else
		usr.skills[7]=new S
	usr.client?.initskillbar()


mob/proc/ChargeSkill()
	set waitfor = 0
	if(!src.equippedskill)return
	src.equippedskill.Charge(src)


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

mob/var/tmp/holdskill

Skill
	var/icon
	var/counters=0
	var/icon_state
	icon='skills.dmi'
	var/kicost=0
	var/channel=0
	var/ctime=0
	var/state1="blast1"
	var/state2="blast2"
	proc/Use()
	proc/Charge()

	Kamehameha
		icon_state="kamehameha"
		ctime=4
		kicost=60
		counters=1
		state1="kame1"
		state2="kame2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Kamehameha)
	Galekgun
		icon_state="galekgun"
		ctime=4
		kicost=60
		counters=1
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Galekgun)
	Doublesunday
		ctime=4
		kicost=60
		counters=1
		icon_state="doublesunday"
		state1="kame1"
		state2="kame2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Doublesunday)
	Mouthblast
		ctime=7
		kicost=80
		counters=1
		state1="mouth1"
		state2="mouth2"
		icon_state="mouthblast"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,600,new/Beam/Mouthblast)
	Masenko
		ctime=4
		kicost=50
		counters=1
		icon_state="masenko"
		state1="masenko1"
		state2="masenko2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Masenko)
	Dondonpa
		ctime=3
		kicost=40
		counters=1
		icon_state="dondonpa"
		state1="don1"
		state2="don2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Dondonpa)
	Tribeam
		ctime=3
		kicost=60
		counters=1
		icon_state="tribeam"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Tribeam)
	Specialbeamcannon
		ctime=10
		kicost=60
		state1="sbc1"
		state2="sbc2"
		icon_state="specialbeamcannon"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,275,new/Beam/Specialbeamcannon)

	Destructodisc
		ctime=5
		kicost=40
		state1="ddisc1"
		state2="ddisc2"
		icon_state="destructodisc"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			var/obj/Kiblast/Destructodisc/D
			if(!user.holdskill)D=new/obj/Kiblast/Destructodisc
			else
				D=user.holdskill
			user.Energy_Blast(time,D,vector(0,30))
			user.icon_state=""

		Charge(mob/user)
			if(user.ki>=kicost)
				var/obj/Kiblast/Destructodisc/D=new/obj/Kiblast/Destructodisc(bound_pixloc(user,0)+vector(-32,30))
				user.holdskill=D
	Spiritbomb
		ctime=15
		kicost=40
		icon_state="spiritbomb"
		state1="spiritbomb"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Spiritbomb/S
			if(!user.holdskill)S=new/obj/Kiblast/Spiritbomb
			else
				S=user.holdskill
			S.power*=1+0.05*S.charge
			user.Energy_Blast(time,S,vector(0,80+S.charge))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""

		Charge(mob/user)
			if(user.ki>=kicost)
				user.icon_state="spiritbomb"
				var/obj/Kiblast/Spiritbomb/S=new/obj/Kiblast/Spiritbomb(bound_pixloc(user,0)+vector(0,100))
				user.holdskill=S
				src.channel=1
				S.transform=(new/matrix).Scale(0.5)
				S.bound_width*=0.5
				S.bound_height*=0.5
				S.bound_x*=0.5
				S.bound_y*=0.5
				S.pixel_x=-64
				S.pixel_y=-64
				while(src.channel)
					sleep(5+S.charge/2)
					S.charge++
					S.transform*=1.05
					S.bound_width*=1.05
					S.bound_height*=1.05
					S.bound_x*=1.05
					S.bound_y*=1.05
					S.pixloc=S.pixloc+vector(0,2)
	Spiritball
		ctime=3
		kicost=50
		icon_state="spiritball"
		Use(mob/user,time)

			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Spiritbomb/S
			if(!user.holdskill)S=new/obj/Kiblast/Spiritball
			else
				S=user.holdskill
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""

	HellzoneGrenade
		ctime=3
		kicost=50
		icon_state="hellzonegrenade"
		Use(mob/user,time)

			var/mob/target=user.Target()
			if(!target)return
			src.channel=0
			var/c=12
			var/list/L=new/list()
			user.usingskill=1
			while(c>0)

				sleep(0.5)
				user.icon_state="blast2"
				var/obj/Kiblast/HellzoneGrenade/S=new/obj/Kiblast/HellzoneGrenade
				spawn(10)
				//	S.color= "#ff0000" for testing only
					S.pierce=0
					S.push=1
				var/vector/spread=vector(96,0)
				if(c%2)
					spread.Turn(90+(c-12)*360/12)
				else
					spread.Turn(90-(c-12)*360/12)
				var/pixloc/dest=bound_pixloc(target,0)+spread
				S.pixloc=bound_pixloc(user,0)
				spawn()user.Shootto(S,dest)
				if(c%2)sleep(1)
				L+=S
				user.icon_state="blast1"


				c--

			sleep(15)
			user.usingskill=0
			user.CheckCanMove()
			for(var/obj/Kiblast/O in L)
				if(!O.loc)continue
				O.persist=0
				O.explode=1
				O.push=0
				O.pierce=1
				O.power*=3
				O.distance=96
				O.spread=0
				spawn()user.Shootto(O,bound_pixloc(target,0))



			if(user.icon_state=="blast2")user.icon_state=""


	Wolffangfist
		ctime=3
		kicost=40
		icon_state="wolffangfist"
		Use(mob/user,time)
			animate(user,icon_state="punch1",flags=ANIMATION_PARALLEL,time=2)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,delay=1,time=2)
			animate(user,icon_state="punch1",flags=ANIMATION_PARALLEL,delay=2,time=3)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,delay=3,time=4)
			animate(user,icon_state="punch1",flags=ANIMATION_PARALLEL,delay=4,time=5)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,delay=5,time=6)
			user.Energy_Blast(time,new/obj/Kiblast/WFF)


	Dragonfist
		ctime=3
		kicost=80
		icon_state="dragonfist"
		Use(mob/user,time)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,time=2)
			user.Energy_Blast(time,new/obj/Kiblast/Dragonfist,vector(0,-96))

	ExplosiveDemonWave
		ctime=5
		kicost=33
		state1="dwave1"
		state2="dwave2"
		icon_state="explosivedemonwave"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="punch2"
			if(!user.aim)
				user.icon_state=""
				if(user.bdir==EAST)
					user.transform=matrix()
					user.rotation=0
				else
					user.transform=matrix().Scale(-1,1)
					user.rotation=0
				user.usingskill=0
				user.CheckCanMove()
			var/vector/aimvector=user.aim

			if(!aimvector||!aimvector.size)
				user.usingskill=0
				user.canmove=1
				return
			aimvector.size=18
			var/obj/W=new/obj/FX/ExplosiveDemonWave()
			var/matrix/m=matrix()
			var/ang=-vector2angle(aimvector)
			user.AngleRotateMob(-ang)
			m.TurnandScaleWithPivot(-ang,W.scale/4,W.scale,W.bound_width/2,0)
			W.transform=m
			var/matrix/m2=matrix().TurnandScaleWithPivot(-ang,W.scale*1.25,W.scale*1.25,W.bound_width/2,0)

			W.alpha=100
			animate(W,transform=m2,alpha=255,easing=CUBIC_EASING,time=1.5)

			W.pixloc=bound_pixloc(user,0)+aimvector
			for(var/mob/M in bounds(W.pixloc,120))
				if(M.invulnerable||M==user)continue
				spawn()M.Damage(15*PLcompare(user,M),45,PLcompare(user,M)*50,user)
			sleep(1.5)
			animate(W,transform=m2,alpha=0,time=1.5)
			sleep(3.5)
			user.usingskill=0
			user.CheckCanMove()
			W.loc=null

	Solarflare
		ctime=6
		kicost=30
		state1=""
		state2="tayo"
		icon_state="solarflare"
		Use(mob/user,time)
			spawn(2)
				user.usingskill=0
				user.CheckCanMove()
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="block"
			for(var/mob/M in oview(3,user))
				M.icon_state="hurt1"
				M.stunned=world.time+50
				spawn(50)
					M.icon_state=""
			user.canmove=0
			var/obj/FX/Solarflare/S=new/obj/FX/Solarflare(bound_pixloc(user,0))
			sleep(5)
			user.canmove=1
			del(S)
			user.icon_state=""

	Burningattack
		ctime=9
		kicost=35
		icon_state="burningattack"
		state1="burning1"
		state2="burning2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Burningattack/S=new/obj/Kiblast/Burningattack
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""
	Bigbangattack
		ctime=10
		kicost=60
		icon_state="bigbangattack"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Bigbangattack/S=new/obj/Kiblast/Bigbangattack
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""

	Pushup
		ctime=5
		kicost=20
		icon_state="spiritshot"
		state1="block"
		state2="blast2"
		Use(mob/user,time)
			spawn(4)
				user.usingskill=0
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state=""
			for(var/mob/Hit in bounds(bound_pixloc(user,0),400))
				if(Hit==user)continue
				if(Hit.block)
					Hit.Damage(30*PLcompare(user,Hit)*(0.40),20,0,user)
				else
					Hit.Damage(30*PLcompare(user,Hit),80,0,user)

				spawn()
					Hit.sendflying(vector(0,300),(400),16)


			user.CheckCanMove()
	Spiritshot
		ctime=10
		kicost=30
		icon_state="spiritshot"
		state1="block"
		state2="explode"
		Use(mob/user,time)
			spawn(4)
				user.usingskill=0
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state=""
			for(var/mob/Hit in bounds(bound_pixloc(user,0),64))
				if(Hit==user)continue
				if(Hit.block)
					Hit.Damage(30*PLcompare(user,Hit)*(0.40),20,0,user)
				else
					Hit.Damage(30*PLcompare(user,Hit),80,0,user)
			user.Repulse(128)
			user.CheckCanMove()

	Explosivewave
		ctime=10
		kicost=30
		icon_state="explosivewave"
		state1="block"
		state2="ewave"
		Use(mob/user,time)
			spawn(4)
				user.usingskill=0
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			var/vector/aimvector=user.aim
			var/pixloc/P
			var/mob/M=user.Target()
			if(!M)
				var/vector/V=vector(aimvector)
				V.size=256
				P=bound_pixloc(user,0)+V

			else
				P=bound_pixloc(M,0)
			if(!P)return
			sleep(4)
			var/obj/FX/Explosivewave/E=new/obj/FX/Explosivewave(P+vector(0,32))
			sleep(4)
			for(var/mob/Hit in bounds(P,64))
				if(Hit==user)continue
				if(Hit.block)
					Hit.Damage(45*PLcompare(user,Hit)*(0.40),20,0,user)
				else
					Hit.Damage(45*PLcompare(user,Hit),80,0,user)
				Hit.stunned=max(Hit.stunned,world.time+10)
				Hit.icon_state="hurt1"
				spawn(5)Hit.icon_state=""

			user.CheckCanMove()

			sleep(2)

			E.loc=null

	Energyblast
		ctime=5
		kicost=60
		icon_state="energyblast"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Energyblast/S=new/obj/Kiblast/Energyblast
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""
	Saturdaycrush
		ctime=10
		kicost=60
		icon_state="saturdaycrush"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Bigbangattack/S=new/obj/Kiblast/Saturdaycrush
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""
	Kiblast
		Slicing
			icon_state="sliceblast"
		Fingerlaser
			icon_state="fingerlaser"
		Gun
			icon_state="gun"
		kicost=5
		ctime=0
		icon_state="kiblast"
		Use(mob/user,time)
			user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/K=new user.kiblast
			user.Energy_Blast(time,K)
			user.icon_state=""

		Charge(mob/user)
			src.channel=1
			while(user.ki>=kicost && src.channel && !user.dead && user.client?.keydown["S"])
				user.Take_Ki(src.kicost)
				user.icon_state="blast1"
				sleep(1.5)
				if(src.channel)
					user.icon_state="blast2"
					var/obj/Kiblast/K=new user.kiblast
					spawn()user.Energy_Blast(0,K)
				sleep(1)



