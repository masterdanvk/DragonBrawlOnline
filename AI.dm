

var/list/AI_Active=new/list()
mob/var/tmp
	posture=0 //0 is open/unassigned, 1 is gap closing, 2 is defensive, 3 is melee attacking, 4 is ki blasting / poking, 5 is trying to charge and position to use a special attack
	posturetime
	list/behaviors=list(5,10,50,10,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
	activeai=0
	moving=0
	obj/detector
	obj/detector2
	wanderlist[0]
	wander=0
	canaggro=1
	aggrotag=0
var/AItick=0
mob/var/skillcooldown
proc/AI_Loop()
	AItick++
	if(AItick>=5)
		AItick=0
		for(var/mob/M in AI_Active)
			if(M.stunned&&M.stunned>world.time)
				continue
			if(M.dead)
				AI_Active-=M
				continue
			if(M.lastloc!=M.loc)
				M.storeddamage=0
				M.lastloc=M.loc
			if(M.storeddamage>=5)
				M.posture=6
			if(M.targetmob&&M.targetmob.dead)
				M.targetmob=null

			if(!M.targetmob)
				if(M.lastattackedby && M.lastattackedby.z==M.z)M.targetmob=M.lastattackedby //if there is another player who did damage but theres no target, they are the new target
			if(!M.targetmob)
				AI_Active-=M //if nobody has attacked this mob and they have no target, remove from active list
				RefreshChunks|=M
				continue
			M.activeai=1
			if(!M.posture)
				M.posture=pick(
					prob(M.behaviors[1]);1,
					prob(M.behaviors[2]);2,
					prob(M.behaviors[3]);3,
					prob(M.behaviors[4]);4,
					prob(M.behaviors[5]);5)
				M.posturetime=world.time
			M.Face(M.targetmob)
			if(M.block && M.icon_state!="block")M.block=0
			switch(M.posture)
				if(1)
					if((world.time-M.posturetime)>=100 &&M.posture==1)
						M.posture=0
						M.canmove=1
						M.aiming=0
						M.usingskill=0
						M.bouncing=0
						M.block=0
					if(M.counters>=1&&M.ki>M.maxki/2)
						M.counters--
						M.Update_Counters()
						AI_Active-=M
						spawn(world.tick_lag)
							spawn(30)
								AI_Active|=M
								spawn()M.Chargestop()
								var/vector/dist
								if(M.targetmob)dist=M.targetmob.pixloc-M.pixloc
								if(dist&&dist.size<=32)
									M.posture=3
								else
									M.posture=pick(
										prob(M.behaviors[4]);4,
										prob(M.behaviors[5]);5)

							M.Charge()
							M.activeai=0
					else
						AI_Active-=M
						spawn()
							M.AIMove(M.targetmob.pixloc)
							sleep(pick(10,15,20))
							M.posture=0
							AI_Active|=M
							M.activeai=0
				if(2)
					var/vector/dist
					if(M?.pixloc&&M.targetmob?.pixloc)dist=M.targetmob.pixloc-M.pixloc
					else
						M.posture=0
						return
					if(dist.size<=64)
						if(M.blocks>=1)
							if(prob(30))
								AI_Active-=M
								spawn()
									M.AIBlock()
									AI_Active|=M
									M.activeai=0
							else if(prob(50))
								dist.size=200
								dist.Turn(pick(-90,90,-60,60,-30,30))
								AI_Active-=M
								var/turf/T=locate(M.targetmob.pixloc+dist)
								if(T&&!T.density)
									spawn()
										M.AIMove(M.targetmob.pixloc+dist)
										sleep(pick(10,20,30,25,15))
										AI_Active|=M
										M.activeai=0
								else
									AI_Active|=M
									M.activeai=0
							else
								M.posture=3
								M.activeai=0
						else
							M.blocks++
							M.Update_Blocks()
							M.posture=0

					else
						if(M.ki<M.maxki&&prob(30))
							AI_Active-=M
							spawn()
								M.AICharge()
								AI_Active|=M
								M.activeai=0

						else
							dist.size=300
							dist.Turn(pick(-90,90,-60,60,-30,30))
							AI_Active-=M
							spawn()
								M.AIMove(M.targetmob.pixloc+dist)
								sleep(1)
								AI_Active|=M
								M.activeai=0
								if(prob(20))M.posture=0
					if((world.time-M.posturetime)>=200 &&M.posture==2)
						M.posture=0
						M.canmove=1
						M.aiming=0
						M.usingskill=0
						M.bouncing=0
						M.block=0
				if(3)
					if((world.time-M.posturetime)>=200 &&M.posture==3)
						M.posture=0
						M.canmove=1
						M.aiming=0
						M.usingskill=0
						M.bouncing=0
						M.block=0
					AI_Active-=M
					spawn()
						M.AIMoveto(M.targetmob,50)
						sleep(3)
						AI_Active|=M
						M.activeai=0
						if(prob(15))M.posture=0
				if(4)
					var/vector/dist=M.targetmob.pixloc-M.pixloc
					if((world.time-M.posturetime)>=100 &&M.posture==4)
						M.posture=0
						M.canmove=1
						M.aiming=0
						M.usingskill=0
						M.bouncing=0
						M.block=0
					if(dist.size<=64)
						AI_Active-=M
						spawn()
							dist.size=300
							dist.Turn(pick(-90,90,-60,60,-30,30))
							M.AIMove(M.targetmob.pixloc-dist)
							AI_Active|=M
							M.activeai=0

					else
						if(M.ki>=5)
							M.aim=dist
							M.UseKiBlast()
							if(prob(30))M.posture=0

						else
							M.posture=2
						M.activeai=0
				if(5)
					var/vector/dist=M.targetmob.pixloc-M.pixloc
					if((world.time-M.posturetime)>=100 &&M.posture==5)
						M.posture=0
						M.canmove=1
						M.aiming=0
						M.usingskill=0
						M.bouncing=0
						M.block=0
					if(dist.size<=100)
						AI_Active-=M
						spawn()
							dist.size=300
							dist.Turn(pick(-90,90,-60,60,-30,30))
							M.AIMove(M.targetmob.pixloc-dist)
							AI_Active|=M
							M.activeai=0
					else

						if(!M.equippedskill)M.equippedskill=M.skills[1]
						if(M.ki>(M.equippedskill.kicost)&&M.activeai!=2)
							M.activeai=2
							M.Take_Ki(M.equippedskill.kicost)
							AI_Active-=M
							spawn()
								if(M.canmove&& world.time>(M.skillcooldown))
									M.icon_state="blast1"
									sleep(M.equippedskill.ctime)
									M.aim=dist

									M.skillcooldown=world.time+20
									M.equippedskill.Use(M,M.equippedskill.ctime)


									M.equippedskill=pick(M.skills)
									M.posture=0
									M.icon_state=""
									M.usingskill=0
								AI_Active|=M
								M.activeai=0
						else
							M.posture=2
							M.activeai=0
				if(6) //escape
					M.Counter(M.targetmob)
					M.posture=pick(1,3,5)

mob/var/tmp/turf/lastloc


mob/proc/Detect(mob/A)
	set waitfor = 0

	if((!A.team||A.team!=src.team) && (!src.targetmob || src.targetmob.z!=A.z|| src.targetmob.dead) && !src.dead && !A.dead)
		walk(src,0)
		src.targetmob=A
		Awaken(src,src.targetmob)

mob/proc/Wander(mob/A)
	set waitfor = 0
	set background = 1
	if(A==src)return
	src.wanderlist|=A
	if(src.wander)return
	src.wander=1
	while(src.wanderlist.len&&!src.dead)
		var/i=10
		while(i>0&&!(src in AI_Active)&&!src.dead)
			src.AIMove(src.pixloc+vector(pick(24,32,48,64,-24,-32,-48,-64,0),pick(24,32,48,64,-24,-32,-48,-64,0)),5)

			sleep(10)
			if(src.chunk!=src.loc?:chunk)RefreshChunks|=src
			i--
		if(src in AI_Active || src.dead)
			return
		var/detrange=src.wanderrange*chunksize*32*1.41
		for(var/mob/M in src.wanderlist)
			var/vector/V=M.pixloc-src.pixloc
			if(V.size>=detrange)
				src.wanderlist-=M



mob/proc/AIBlock()
	src.block=1
	src.blocks+=1
	if(src.blocks>src.maxblocks)src.blocks=src.maxblocks
	else
		src.Update_Blocks()
	animate(src,icon_state="block",time=4)
	src.movevector=vector(0,0)
	sleep(30)
	src.icon_state=""

mob/var/tmp/hue=0
mob/var/tmp/shiny=0
mob/proc/shiny()
	if(shiny)return
	shiny=1
	while(src&&shiny)
		sleep(1)
		src.hue+=10
		if(src.hue>360)src.hue-=360
		src.filters += filter(
			type = "color",
			space = FILTER_COLOR_HSV,
		 	color = list(1,0,0, 0,1,0, 0,0,1, src.hue/360,0,0)
		 	)

mob/New()
	..()
	if(src.hue)
		src.filters += filter(
			type = "color",
			space = FILTER_COLOR_HSV,
		 	color = list(1,0,0, 0,1,0, 0,0,1, src.hue/360,0,0)
		 	)
mob/Click()
	src.Check_Vars()


mob/verb/MakeShiny(mob/M in view(10))
	if(M.shiny)
		M.shiny=0
		M.color=null
	else M.shiny()

mob/verb/ChangeHue(mob/M in view(10))
	var/hueshift=input(usr,"Set a hue shift from 0 to 360","Hue") as num
	M.hue=hueshift
	M.filters=null
	M.filters += filter(
		type = "color",
		space = FILTER_COLOR_HSV,
	 	color = list(1,0,0, 0,1,0, 0,0,1, M.hue/360,0,0)
	 	)


mob/proc/AIMove(pixloc/P,iterations=20)
	if(src.moving)return
	src.moving=1
	var/i=0
	if(src.tossed && src.icon_state!="hurt2")src.tossed=0
	src.CheckCanMove()
	while(((src.canmove && !src.tossed))&&i<=iterations && (P-src.pixloc).size>10)
		src.step_size=src.maxspeed*0.8
		if(i<=3)
			src.icon_state="dash1"
		else
			src.icon_state="dash2"
		var/vector/stepv=P-src.pixloc
		stepv.size=src.step_size
		src.RotateMob(stepv,5)
		src.Move(stepv)
		src.movevector=stepv
		sleep(world.tick_lag)
		i++
	if(src.icon_state=="dash1"||src.icon_state=="dash2")src.icon_state=""
	src.moving=0

mob/proc/AIMoveto(mob/M,iterations=20)
	if(src.moving)return
	src.moving=1
	var/i=0
	if(src.tossed && src.icon_state!="hurt2")src.tossed=0
	src.CheckCanMove()
	while(((src.canmove && !src.tossed))&&i<=iterations&&M&&M.z==src.z&&!M.dead)
		src.step_size=src.maxspeed*0.8
		if(i<=3)
			src.icon_state="dash1"
		else
			src.icon_state="dash2"
		var/vector/stepv=M.pixloc-src.pixloc
		stepv.size=src.step_size
		src.RotateMob(stepv,5)
		src.Move(stepv)
		src.movevector=stepv
		sleep(world.tick_lag)
		i++
	if(src.icon_state=="dash1"||src.icon_state=="dash2")src.icon_state=""
	src.moving=0

mob/proc/AICharge()
	src.charging=1
	src.canmove=0
	src.aura.icon_state="none"
	src.auraover.icon_state="none"
	src.vis_contents|=src.aura
	src.vis_contents|=src.auraover
	src.aura.icon_state="start"
	src.auraover.icon_state="start"
	spawn(3)
		src.aura.icon_state="aura"
		src.auraover.icon_state="aura"
	var/i=0
	while(src.charging&&i<=30)
		i+=5
		if(src.ki<src.maxki)
			src.Get_Ki(min((src.maxki-src.ki),10))
		sleep(5)
	src.charging=0
	src.vis_contents-=src.aura
	src.vis_contents-=src.auraover
	src.canmove=1





mob/proc/FaceAI(mob/T)
	src.RotateMob((T.pixloc-src.pixloc),20)


client/verb/SpawnAI()
	var/P =input(usr,"What powerlevel to spawn?","Powerlevel",1000) as num
	var/list/M=typesof(/mob)
	M-=/mob
	M-=/mob/picking
	var/pick=input(usr,"Select a mob to spawn","Spawn") in M
	var/mob/m=new pick (usr.pixloc)
	m.Set_PL(P)
	m.targetmob=src.mob
	m.CheckCanMove()
	sleep(20)
	AI_Active|=m

	m.Move(0)
	m.movevector=vector(0,0)
	m.rotation=0
	m.RotateMob(vector(0,0),100)
	m.autoblocks=m.maxautoblocks
	m.tossed=0
	m.icon_state=""



