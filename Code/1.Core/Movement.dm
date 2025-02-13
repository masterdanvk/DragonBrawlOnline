/*
Movement is handled in the world Tick() which is kept in Base.dm.
However, the translation of input (from Controls.dm into mob variables that govern momentum/movement is handled here.
This works by simply translating keys held down into a vector thats length is the players speed. This vector is used in Tick() to move the mob.
*/
client/proc/UpdateMoveVector()
	var/olddir=src.mob.dir
	if(src.overworld)
		src.overworldmove()
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
	if(d&&src.mob.dir!=d)src.mob.dir=d
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
	if(src.mob.falling&&V.y>0&&src.mob.flyinglevel<3)
		V.y=0
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

client/proc/overworldmove()

	if(!movekeydown && (!src.mob.movevector || !src.mob.movevector.size))return
	var/vx=0
	var/vy=0

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
	var/ostepsize=src.mob.step_size
	src.mob.step_size=4
	step(src.mob,d,4)
	src.mob.step_size=ostepsize
