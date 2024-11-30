


mob/var/tmp/Skill/equippedskill
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
		src.Energy_Blast(0,new/obj/Kiblast/Basic)
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
	usr.equippedskill=new S

mob/proc/ChargeSkill()
	set waitfor = 0
	if(!src.equippedskill)return
	src.equippedskill.Charge(src)


mob/proc/Energy_Blast(time,obj/Kiblast/K,vector/offset)
	if(!offset)offset=new/vector(0,0)
	K.owner=src
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
	aimvector.Turn(turnd)
	var/vector/stepvector=vector(aimvector)
	if(!aimvector||!aimvector.size||!stepvector)
		src.usingskill=0
		src.canmove=1
		return
	stepvector.size=K.speed
	var/angle=vector2angle(aimvector)
	var/matrix/m=new/matrix()
	if(K.rotate)
		m.TurnWithPivot(angle,K.bound_width/2,0)
		K.transform=m
	K.pixloc=bound_pixloc(src,0)+stepvector+offset
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

		K.Move(K.pixloc+stepvector-offsetchg)
		for(var/mob/Hit in K?.hitmobs)
			if(Hit.invulnerable || Hit==src||(Hit in hitlist))continue
			Hit.CheckCanMove()
			hitlist|=Hit
			Hit.icon_state=""
			if(K.explode)
				K.explode=0
				K.Explode()
			spawn()Hit.Damage(K.power*PLcompare(src,Hit),K.impact,0,src)
		sleep(world.tick_lag)
		if(turnd)
			stepvector.Turn(-correctpace)
			turnd-=correctpace
			angle=vector2angle(stepvector)
			m=new/matrix()
			if(K.rotate)
				m.TurnWithPivot(angle,K.bound_width/2,0)
				K.transform=m
	K.Explode()
	for(var/mob/Hit in K?.hitmobs)
		if(Hit.invulnerable || Hit==src||(Hit in hitlist))continue
		Hit.CheckCanMove()
		hitlist|=Hit
		Hit.icon_state=""
		spawn()Hit.Damage(K.power*PLcompare(src,Hit),K.impact,0,src)
	sleep(world.tick_lag)
	if(K)K.loc=null



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
		passthroughobjs=1
		push=1
		Bump(atom/A)
			if(istype(A,/mob) && !A:invulnerable)
				src.hitmobs|=A

		Explode()
			src.icon=null
			Explosion(/obj/FX/Explosion,bound_pixloc(src,0),0,1+src.charge*0.05,1+src.charge*0.05)
			destroy_turfs(bound_pixloc(src,0),max(40,16*(1+0.5*src.charge)))
			for(var/mob/M in bound_pixloc(src,0),max(40,16*(1+0.5*src.charge)))
				src.hitmobs|=M
			..()
	Destructodisc
		icon='destructodisc.dmi'
		layer=MOB_LAYER
		bound_width=63
		bound_height=23
		bound_x=0
		density=1
		spread=0
		distance=500
		speed=8
		power=50
		impact=0
		rotate=0
		pierce=1
		Bump(atom/A)
			if(istype(A,/obj)&&A:destructible)
				A:Destroy_Landscape()
			..()
		Explode()
			src.icon=null
			..()
	Basic
		icon='kiblast.dmi'
		bound_width=19
		bound_height=19
		bound_x=8
		density=1
		spread=20
		distance=400
		speed=12
		power=3
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
			..()

mob/var/tmp/holdskill

Skill
	var/kicost=0
	var/channel=0
	var/ctime=0
	proc/Use()
	proc/Charge()

	Kamehameha
		ctime=4
		kicost=60
		Use(mob/user,time)
			user.FireBeam(time,500,new/Beam/Kamehameha)
	Galekgun
		ctime=4
		kicost=60
		Use(mob/user,time)
			user.FireBeam(time,500,new/Beam/Galekgun)
	Masenko
		ctime=4
		kicost=50
		Use(mob/user,time)
			user.FireBeam(time,500,new/Beam/Masenko)
	Tribeam
		ctime=3
		kicost=60
		Use(mob/user,time)
			user.FireBeam(time,500,new/Beam/Tribeam)
	Specialbeamcannon
		ctime=10
		kicost=60
		Use(mob/user,time)
			user.FireBeam(time,275,new/Beam/Specialbeamcannon)

	Destructodisc
		ctime=5
		kicost=40
		Use(mob/user,time)
			user.icon_state="blast2"
			var/obj/Kiblast/Destructodisc/D
			if(!user.holdskill)D=new/obj/Kiblast/Destructodisc
			else
				D=user.holdskill
			user.Energy_Blast(time,D,vector(0,30))
			user.icon_state=""

		Charge(mob/user)
			if(user.ki>=kicost)
				user.icon_state="blast1"
				var/obj/Kiblast/Destructodisc/D=new/obj/Kiblast/Destructodisc(bound_pixloc(user,0)+vector(-32,30))
				user.holdskill=D
	Spiritbomb
		ctime=15
		kicost=40
		Use(mob/user,time)
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
				var/obj/Kiblast/Spiritbomb/S=new/obj/Kiblast/Spiritbomb(bound_pixloc(user,0)+vector(0,80))
				user.holdskill=S
				src.channel=1
				S.transform=(new/matrix).Scale(0.5)
				S.bound_width*=0.5
				S.bound_height*=0.5
				S.pixel_x=-64
				S.pixel_y=-64
				while(src.channel)
					sleep(5+S.charge/2)
					S.charge++
					S.transform*=1.05
					S.bound_width*=1.05
					S.bound_height*=1.05
					S.pixloc=S.pixloc+vector(0,2)

	Kiblast
		kicost=5
		ctime=0
		Use(mob/user,time)
			user.icon_state="blast2"
			user.Energy_Blast(time,new/obj/Kiblast/Basic)
			user.icon_state=""

