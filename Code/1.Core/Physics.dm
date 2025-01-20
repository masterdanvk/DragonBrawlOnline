/*
This handles the interaction of mobs bumping into things, knockbacks and the vector math of things bouncing off of surfaces.
*/
mob
	Bump(atom/o)
		..()
		if(src.dashing)
			src.Chargestop()
			if(istype(o,/mob))
				if(o:block)
					var/vector/V = bound_pixloc(o,0)-bound_pixloc(src,0)
					V.Turn(180)
					sendflying(V,V.size*3,8)
				else
					src.Melee(100)
		if(istype(o,/mob))
			var/mob/M=o
			if(M.dashing)M.Chargestop()

			var/vector/kbvector
			if(src.movevector)kbvector=vector(src.movevector)
			else kbvector=vector(0,0)
			kbvector+=(M.pixloc-src.pixloc)

			if(src.client)
				if(src.client.overworld)return
				if(src.client.keydown["A"]&&src.autoattack)
					spawn()
						if(!src.attacking)
							var/duration=world.time-src.client?.keydown["A"]
							src.Melee(duration)
						//	if(duration>5)src.Kick()
						//	else src.Punch()
							src.client?.keydown["A"]=world.time


				else

					if(M.canmove&&!M.tossed)
						kbvector.size=4
						M.Move(M.pixloc+kbvector)
				return
			else
				if(src.posture)
					var/duration=world.time-src.posturetime
					src.Melee(duration)
				//	if(duration>5)src.Kick()
				//	else src.Punch()
					src.posturetime=world.time

		if(src.bouncing && src.canmove)src.bouncing=0
		if(src.bouncing)return
		else
			src.bounce(o)


mob/proc/knockback(vector/V,distance,rate)
	if(tossed || src.usingskill)return
	var/vector/v=vector(V)
	v.size=distance
	var/vector/S=vector(v)
	S.size=rate
	src.canmove=0
	var/oldglide=src.glide_size

	while(distance>0)
		if(distance<rate)
			rate=distance
			S.size=rate
		src.step_size=src.glide_size=rate
		src.Move(src.pixloc+S)
		distance-=rate

		sleep(world.tick_lag)
	src.glide_size=oldglide
	sleep(1)
	src.Move(0)
	src.CheckCanMove()


mob/proc/sendflying(vector/V,distance,rate)
	if(tossed || src.usingskill)return
	src.tossed=1
	var/vector/v=vector(V)
	v.size=distance
	src.movevector=v
	var/vector/S=vector(v)
	S.size=rate
	src.canmove=0
	var/oldglide=src.glide_size
	src.glide_size=rate
	src.RotateMob(vector(-S.x,S.y),100)
	while(distance>0)

		src.step_size=rate
		src.icon_state="hurt2"
		src.Move(src.pixloc+S)
		distance-=rate
		src.movevector.size=distance
		sleep(world.tick_lag)
	src.glide_size=oldglide
	sleep(5)
	src.Move(0)
	src.movevector=vector(0,0)
	src.rotation=0
	src.RotateMob(vector(S.x,0),100)
	//src.autoblocks=src.maxautoblocks
	src.tossed=0
	src.CheckCanMove()
	if(!src.dead)src.icon_state=""

atom/var/bouncy=1
atom/movable/proc/bounce(atom/T)
	src.bouncing=1

	var/vector/normal=getnormal(src,T)
	if(normal.size==0)
		return

	var/vector/incident
	if(src.movevector)incident=vector(src.movevector)
	else incident=vector(0,0)
	if(incident.size==0)return
	var/vector/result=calculate_bounce(incident,normal)
	src.canmove=0
	var/distance=min(T.bouncy*src.movevector.size,1000)
	result.size=clamp(src.movevector.size,2,src.step_size)

	sleep(1)
	while(distance>0)
		distance-=min(distance,result.size)
		if(!src.Move(src.pixloc+result))
			distance=0
		sleep(world.tick_lag)
	sleep(1)
	src.bouncing=0
	if(istype(src,/mob))src:CheckCanMove()