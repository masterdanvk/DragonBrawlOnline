
client/proc/UpdateMoveVector()
	var/olddir=src.mob.dir
	if(movemode=="loose")
		src.oldUpdateMoveVector()
		return

	if(!movekeydown && (!src.mob.movevector || !src.mob.movevector.size))return
	if(src.mob.usingskill)return
	var/vx=0
	var/vy=0
	var/vector/oldmove=vector(src.mob.movevector)
	if(!(("North" in keydown)&&("South" in keydown)))
		if("North" in keydown)vy=1
		else
			if("South" in keydown)vy=-1
	if(!(("East" in keydown)&&("West" in keydown)))
		if("East" in keydown)vx=1
		else
			if("West" in keydown)vx=-1
	if("Northeast" in keydown)
		vx=1
		vy=1
	else if("Northwest" in keydown)
		vx=-1
		vy=1
	else if("Southwest" in keydown)
		vx=-1
		vy=-1
	else if("Southeast" in keydown)
		vx=1
		vy=-1
	var/vector/V=vector(vx,vy)
	src.mob.facing=V
	var/d=0
	if(vx==1)d|=EAST
	if(vx==-1)d|=WEST
	if(vy==1)d|=NORTH
	if(vy==-1)d|=SOUTH
	if(d)src.mob.dir=d
	if(src.mob.aiming&&V.size)

		var/anglediff=vector2angle(V)
		if(src.mob.aim&&src.mob.aim.size)
			anglediff-=vector2angle(src.mob.aim)
		else
			src.mob.aim=V
			src.mob.aim.size=16
		if(abs(anglediff)<=20)
			src.mob.aim=V
			src.mob.aim.size=16
		else
			var/vector/adjust=vector(V)
			adjust.size=16
			src.mob.aim+=adjust
			src.mob.aim.size=16
		src.autoaim=0
		src.ShowAim()
		return
	if(src.autoaim==0)src.autoaim=1

	if(V.x==0&&V.y==0)
		src.mob.runningspeed=0
		if(src.mob.icon_state=="dash2")src.mob.icon_state=""
		if(src.mob.bdir==EAST)
			src.mob.transform=matrix()
			src.mob.rotation=0
		else
			src.mob.transform=matrix().Scale(-1,1)
			src.mob.rotation=0
		src.mob.movevector=vector(0,0)
		return

	//if(oldmove)V+=oldmove
	//var/vector/friction=vector(oldmove).Normalize()-vector(V).Normalize()
	//var/f=round(abs(friction.x)+abs(friction.y),0.1)
	if(olddir!=src.mob.dir)
		src.mob.runningspeed--
	else
		src.mob.runningspeed++

	if(src.mob.runningspeed<4)src.mob.runningspeed=4

	V.size=clamp(src.mob.runningspeed,6,src.mob.maxspeed)
	src.mob.runningspeed=V.size
	src.mob.step_size=V.size
	src.mob.movevector=V
	if(V.size>=8)
		if(src.mob.icon_state=="")
			src.mob.icon_state="dash2"
		src.mob.RotateMob(V,2)
	else
		src.mob.RotateMob(V,0)
	if(!oldmove||oldmove.size==0&&!src.mob.dead)
		if(src.mob.icon_state=="block")return
	//	src.mob.icon_state="dash2"
		src.mob.icon_state="dash1"
		spawn(5)
			if(src.mob.movevector.size>=3 && src.mob.canmove)
				src.mob.icon_state="dash2"
			else
				if(src.mob.icon_state=="dash1")src.mob.icon_state=""

mob/var/tmp/runningspeed=0

client/proc/oldUpdateMoveVector()

	if(!movekeydown && (!src.mob.movevector || !src.mob.movevector.size))return
	if(src.mob.usingskill)return
	var/vx=0
	var/vy=0
	var/vector/oldmove=src.mob.movevector
	if(!(("North" in keydown)&&("South" in keydown)))
		if("North" in keydown)vy=1
		else
			if("South" in keydown)vy=-1
	if(!(("East" in keydown)&&("West" in keydown)))
		if("East" in keydown)vx=1
		else
			if("West" in keydown)vx=-1
	if("Northeast" in keydown)
		vx=1
		vy=1
	else if("Northwest" in keydown)
		vx=-1
		vy=1
	else if("Southwest" in keydown)
		vx=-1
		vy=-1
	else if("Southeast" in keydown)
		vx=1
		vy=-1
	var/vector/V=vector(vx,vy)
	src.mob.facing=V
	var/d=0
	if(vx==1)d|=EAST
	if(vx==-1)d|=WEST
	if(vy==1)d|=NORTH
	if(vy==-1)d|=SOUTH

	if(d)src.mob.dir=d
	if(src.mob.aiming&&V.size)

		var/anglediff=vector2angle(V)
		if(src.mob.aim&&src.mob.aim.size)
			anglediff-=vector2angle(src.mob.aim)
		else
			src.mob.aim=V
			src.mob.aim.size=16
		if(abs(anglediff)<=20)
			src.mob.aim=V
			src.mob.aim.size=16
		else
			var/vector/adjust=vector(V)
			adjust.size=16
			src.mob.aim+=adjust
			src.mob.aim.size=16
		src.autoaim=0
		src.ShowAim()
		return
	if(src.autoaim==0)src.autoaim=1
	if(!(V.x==0&&V.y==0))
		V.size=max(src.mob.minspeed,src.mob.movevector?.size/2)
	else
		src.mob.movevector.size=src.mob.movevector.size-1.5
		if(src.mob.movevector.size<=3)
			src.mob.movevector=V
			if(src.mob.icon_state=="dash2")src.mob.icon_state=""
			if(src.mob.bdir==EAST)
				src.mob.transform=matrix()
				src.mob.rotation=0
			else
				src.mob.transform=matrix().Scale(-1,1)
				src.mob.rotation=0
		src.mob.step_size=max(src.mob.minspeed,src.mob.movevector.size)
//		world<<"UpdateMoveVector [V], [V.size]"
		return

	if(oldmove)V+=oldmove
	if(V.size>src.mob.step_size)
		src.mob.step_size=min(src.mob.maxspeed,src.mob.step_size+0.25)
	V.size=src.mob.step_size
	src.mob.movevector=V
	if(V.size>=8)
		if(src.mob.icon_state=="")
			src.mob.icon_state="dash2"
		src.mob.RotateMob(V,2)
	else
		src.mob.RotateMob(V,0)
	if(!oldmove||oldmove.size==0&&!src.mob.dead)
		if(src.mob.icon_state=="block")return
	//	src.mob.icon_state="dash2"
		src.mob.icon_state="dash1"
		spawn(5)
			if(src.mob.movevector.size>=3 && src.mob.canmove)
				src.mob.icon_state="dash2"
			else
				if(src.mob.icon_state=="dash1")src.mob.icon_state=""
