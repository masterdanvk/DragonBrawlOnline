

var/list/AI_Active=new/list()
mob/var/tmp
	posture=0 //0 is open/unassigned, 1 is gap closing, 2 is defensive, 3 is melee attacking, 4 is ki blasting / poking, 5 is trying to charge and position to use a special attack
	posturetime
	list/behaviors=list(5,10,50,10,25)

var/AItick=0
proc/AI_Loop()
	AItick++
	if(AItick>=5)
		AItick=0
		for(var/mob/M in AI_Active)
			world<<"M [M] in AI_Active"
			if(M.dead)
				AI_Active-=M
				continue
			if(!M.targetmob)
				if(M.lastattackedby)M.targetmob=M.lastattackedby //if there is another player who did damage but theres no target, they are the new target
			if(!M.targetmob)
				AI_Active-=M //if nobody has attacked this mob and they have no target, remove from active list
				continue
			if(!M.posture)
				M.posture=pick(
					prob(M.behaviors[1]);1,
					prob(M.behaviors[2]);2,
					prob(M.behaviors[3]);3,
					prob(M.behaviors[4]);4,
					prob(M.behaviors[5]);5)
				M.posturetime=world.time
			M.Face(M.targetmob)
			world<<"[M] posture [M.posture]"
			switch(M.posture)
				if(1)
					if(M.counters>=1&&M.ki>M.maxki/2)
						M.counters--
						M.Update_Counters()
						AI_Active-=M
						spawn(world.tick_lag)
							spawn(30)
								AI_Active|=M
								spawn()M.Chargestop()
								var/vector/dist=M.targetmob-M.pixloc
								if(dist.size<=32)
									M.posture=3
								else
									M.posture=pick(
										prob(M.behaviors[4]);4,
										prob(M.behaviors[5]);5)

							M.Charge()
					else
						AI_Active-=M
						spawn()
							M.AIMove(M.targetmob.pixloc)
							sleep(pick(10,15,20))
							M.posture=0
							AI_Active|=M
				if(2)
					var/vector/dist=M.targetmob.pixloc-M.pixloc
					if(dist.size<=64)
						if(prob(50))
							AI_Active-=M
							spawn()
								M.AIBlock()
								AI_Active|=M
						else if(prob(30))
							dist.size=200
							dist.Turn(pick(-90,90,-60,60,-30,30))
							AI_Active-=M
							spawn()
								M.AIMove(M.targetmob.pixloc+dist)
								sleep(pick(10,20,30,25,15))
								AI_Active|=M
						else
							M.posture=3
					else
						if(M.ki<M.maxki&&prob(30))
							AI_Active-=M
							spawn()
								M.AICharge()
								AI_Active|=M

						else
							dist.size=300
							dist.Turn(pick(-90,90,-60,60,-30,30))
							AI_Active-=M
							spawn()
								M.AIMove(M.targetmob.pixloc+dist)
								sleep(1)
								AI_Active|=M
								if(prob(20))M.posture=0
					if((world.time-M.posturetime)>=200 &&M.posture==2) M.posture=0
				if(3)
					AI_Active-=M
					spawn()
						M.AIMove(M.targetmob.pixloc,50)
						sleep(3)
						AI_Active|=M
						if(prob(15))M.posture=0
				if(4)
					var/vector/dist=M.targetmob.pixloc-M.pixloc
					if(dist.size<=64)
						AI_Active-=M
						spawn()
							dist.size=300
							dist.Turn(pick(-90,90,-60,60,-30,30))
							M.AIMove(M.targetmob.pixloc-dist)
							AI_Active|=M
					else
						if(M.ki>=5)
							M.aim=dist
							M.UseKiBlast()
							if(prob(30))M.posture=0
						else
							M.posture=2
				if(5)
					var/vector/dist=M.targetmob.pixloc-M.pixloc
					if(dist.size<=100)
						AI_Active-=M
						spawn()
							dist.size=300
							dist.Turn(pick(-90,90,-60,60,-30,30))
							M.AIMove(M.targetmob.pixloc-dist)
							AI_Active|=M
					else

						if(!M.equippedskill)M.equippedskill=M.skills[1]
						world<<"M.equippedskill = [M.equippedskill]"
						if(M.ki>(M.equippedskill.kicost))
							AI_Active-=M
							spawn()
								if(M.canmove)
									M.icon_state="blast1"
									sleep(M.equippedskill.ctime)
									M.aim=dist


									M.equippedskill.Use(M,M.equippedskill.ctime)
									M.Take_Ki(M.equippedskill.kicost)
									M.equippedskill=pick(M.skills)
									M.posture=0
									M.icon_state=""
									M.usingskill=0
								AI_Active|=M
						else
							M.posture=2





mob/proc/AIBlock()
	set waitfor = 0
	src.block=1
	animate(src,icon_state="block",time=4)
	src.movevector=vector(0,0)
	sleep(10)
	src.icon_state=""

mob/proc/AIMove(pixloc/P,iterations=20)
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
		sleep(world.tick_lag)
		i++
	if(src.icon_state=="dash1"||src.icon_state=="dash2")src.icon_state=""


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
	AI_Active+=m

	m.Move(0)
	m.movevector=vector(0,0)
	m.rotation=0
	m.RotateMob(vector(0,0),100)
	m.autoblocks=m.maxautoblocks
	m.tossed=0
	m.icon_state=""



