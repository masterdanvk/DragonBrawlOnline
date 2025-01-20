/*
This is where world variables, key basic procs such as damage, death, knockback and gravity are handled.
This is also where the world/Tick() loop is handled.

Todo:
	A cancel button on the battle GUI window.
	Manage when ESC is available
	Character select, maptext on which character and border for selected character

*/
#define commafy(x) comma_expression.Replace(num2text(x,12),"$&,") //this is a super handy formula that presents numbers with commas for powerlevels.
#define DEBUG

world
	hub = "Masterdan.DragonBrawlOnline"
	visibility = 1
	hub_password="JN1Vh8KBRoJVFvWu"
	name = "Dragon Brawl Online V1.0 - 516"
	tick_lag= 0.25 // 40 frames per second
	icon_size = 32	// 32x32 icon size
	view = "20x15"
	movement_mode=PIXEL_MOVEMENT_MODE

client/perspective=EDGE_PERSPECTIVE

var/regex/comma_expression = new("(\\d)(?=(\\d{3})+$)","g") // hidden init proc, I know I know.


var/activemobs[0]



client
	var
		chatactive=0
	tick_lag = 0.01
	Move(atom/NewLoc, Dir)
		walk(mob,0)
		return mob.Step(Dir)

atom/movable
	step_size = 4
	var
		move_speed = 4
		scale=1

	appearance_flags = LONG_GLIDE

	proc
		Step(Dir = src.dir, Dist = move_speed, Delay)
			glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
			return step(src,Dir,Dist)

mob
	Step(Dir = src.dir, Dist = move_speed, Delay = step_delay)
		if(next_move>world.time) return 0
		glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
		next_move = world.time + Delay
		return step(src,Dir,Dist)





mob/verb/spawnmob()
	var/list/M=typesof(/mob)
	M-=/mob
	M-=/mob/picking
	var/pick=input(usr,"Select a mob to spawn","Spawn") in M
	new pick (usr.pixloc)


var/punchin=0


mob/proc/Set_PL(p)
	src.pl=p
	src.Refresh_Scouter()


atom/movable
	var/tmp
		vector/movevector=vector(0,0)
		usingskill=0
		canmove=1
		bouncing=0

mob
	on_crossed(atom/A)

client
	var
		image/aimimage


mob/proc/Gravity()
	set waitfor = 0
	if(src.falling)return
	sleep(2+src.flyinglevel*3)
	if(src.falling)return
	src.falling=1
	var/pace=-16+(src.flyinglevel*4)
	while(istype(src.loc,/turf/blank/sky))
		step(src,vector(0,pace))
		sleep(1)
	src.falling=0



world/turf=/turf/blank


mob/proc/Heal(heal)
	src.hp+=heal
	if(src.hp>src.maxhp)src.hp=src.maxhp
	gui_hpbar.setValue(src.hp/src.maxhp,10)


mob/proc/Damage(damage,impact,critchance,mob/damager)
	if(src.team && src.team==damager.team)return 0
	if(!src.client && src.canaggro && (!src.targetmob||src.aggrotag))
		src.Detect(damager)
	var/vector/v=src.pixloc-damager.pixloc
	var/crit=prob(critchance)
	damager.lastattacked=src
	damager.Show_target(src)
	src.lastattackedby=damager
	src.lasthostile=world.time
	damager.lasthostile=world.time
	src.Show_target(damager)
	storeddamage++
	if(src.block)src.storedblock++
	if(crit)
		src.Flash(1.5,100)
		v.size=impact*10
		src.hp-=damage*3
		var/vector/diff=(bound_pixloc(damager,0)-bound_pixloc(src,0))
		diff.size=8
		Explosion(/obj/FX/Smash,bound_pixloc(src,0)+diff)
		src.sendflying(v,(v.size*3+300),16)
	else
		src.Flash(0.5,30)
		v.size=impact
		src.hp-=damage
		if(src.hp<=0)src.invulnerable=1
		src.knockback(v,v.size,16)
	gui_hpbar.setValue(src.hp/src.maxhp,10)
	if(src.hp<=0)
		src.Die(damager)

mob/proc
	Die(mob/damager)
		if(src.dead)return
		src.Standstraight()
		if(src.spawnings.len)
			for(var/mob/S in src.spawnings)
				spawn()S.Die()
		src.invulnerable=1
		src.vis_contents=null
		src.dead=1
		src.density=0

		src.canmove=0
		src.Clear_target()
		var/state
		if("dead" in icon_states(src.icon))
			src.icon_state="dead"
			state="dead"
		else
			src.icon_state="hurt1"
			state="hurt1"

		if(damager)
			world<<"[src] has been killed by [damager]"
			_message(world, "[src] has been killed by [damager]", rgb(200,100,100))

		if(damager)damager.Clear_target()
		var/matrix/M=src.transform
		if(state=="hurt1")M.Turn(-60)


		animate(src,transform=M,time=3)
		while(src.loc?:ground==0)
			src.Move(vector(0,-16))
			sleep(world.tick_lag)

		if(src.holdskill)
			src.holdskill:loc=null
			src.holdskill=null
		if(src.client)src.client.keydown=new/alist()
		sleep(20)
		src.icon_state=state

		if(src.client?.inbattle)
			while(src.client && src.client.inbattle)
				sleep(20)
			animate(src,alpha=0,time=30)
			src.loc=null
			if(src.client)
				src.client.overworld=0
				src.client.oworldpixloc=null
				src.client.Character_Select()
		else
			animate(src,alpha=0,time=30)
			sleep(100)
			if(!src.client)
				src.loc=null
				if(src.npcrespawn)
					sleep(1000)
					src.hp=src.maxhp
					src.alpha=255
					src.icon_state=""
					src.ki=src.maxki
					src.pl=src.basepl
					src.density=1
					src.dead=0
					src.invulnerable=0
					src.canmove=1
					src.loc=src.initloc
			else
				src.client.overworld=0
				src.client.oworldpixloc=null
				src.client?.edge_limit=null
				src.client.Character_Select()


proc/PLcompare(mob/atk,mob/def) //the idea that a powerlevel should be a linear damage multiplyer is bad game design, at worst opponents will be 4x more damaging and take 1/5 damage which is effectively 1:20. Powerlevels still important but not crushing and no fun.
	var/ratio=atk.pl/def.pl
	if(ratio>100)return 4
	else if(ratio>10) return 3
	else if(ratio>5) return 2
	else if(ratio>3) return 1.5
	else if(ratio>2) return 1.3
	else if(ratio>1.7) return 1.2
	else if(ratio>1.5) return 1.15
	else if(ratio>1.3) return 1.1
	else if(ratio>1.1) return 1.05
	else if(ratio>=1) return 1
	else if(ratio>0.8) return 0.9
	else if(ratio>0.6) return 0.8
	else if(ratio>0.5) return 0.7
	else if(ratio>0.4) return 0.6
	else if(ratio>0.3) return 0.5
	else if(ratio>0.2) return 0.4
	else if(ratio>0.1) return 0.35
	else if(ratio>0.01) return 0.25
	else return 0.20




obj
	step_size = 8

client
	var
		alist/keydown
		movekeydown=0


client/proc/Talkto(client/C)
	var/choice=src.ShowDialogue("[C.name]","How do you want to interact with this Player?",list("PVP Challenge","Custom Fight (PVP)","Custom Fight (Coop)","Leave"))
	switch(choice)
		if("PVP Challenge")
			var/response=C.ShowDialogue("[src.name]","[src.name] wants to duel you!",list("No thanks","Sure!"))
			if(response=="Sure!")
				src.PVP(C)
		if("Custom Fight (PVP)")
			var/response=C.ShowDialogue("[src.name]","[src.name] wants to fight you in a custom match",list("No thanks","Sure!"))
			if(response=="Sure!")
				var/list/players[8]
				players[5]=C
				Customfight(players)
		if("Custom Fight (Coop)")
			var/response=C.ShowDialogue("[src.name]","[src.name] wants to fight you in a custom match",list("No thanks","Sure!"))
			if(response=="Sure!")
				var/list/players[8]
				players[2]=C
				Customfight(players)

client/proc/ShowAim()
	if(!src.aimimage)
		src.aimimage=new/image('aim.dmi',src.mob)
		src.aimimage.appearance_flags=RESET_TRANSFORM
	else
		src.aimimage.loc=src.mob
	var/matrix/m=new/matrix()

	var/vector/offset
	if(src.mob.aim&&istype(src.mob.aim,/vector)&&src.mob.aim.size)
		offset=vector(src.mob.aim)
		offset.size=32
	else
		offset=src.mob.AutoAim(Dir2Vector(dir))
		offset.size=32
	if(!offset || !offset.size)
		offset=Dir2Vector(src.mob.dir)
		offset.size=32

	src.mob.aim=offset
	var/angle=vector2angle(src.mob.aim)
	if(src.mob.aim&&src.mob.aim.size)m.Turn(angle)
	src.aimimage.transform=m
	src.aimimage.pixel_x=4
	src.aimimage.pixel_y=22
	src.aimimage.pixel_x+=offset.x
	src.aimimage.pixel_y+=offset.y
	var/flip=1
	if(src.mob.bdir==EAST)
		if(angle>90)
			angle-=180
			src.mob.bdir=WEST
			flip=-1
		if(angle<-90)
			angle+=180
			src.mob.bdir=WEST
			flip=-1
	else
		if(angle<90 && angle>-90)
			src.mob.bdir=EAST
			flip=-1

	src.mob.transform.Scale(flip,1)
	src.images|=src.aimimage
	if(src.autoaim)
		sleep(2)
		var/mob/targ=src.mob.Target()
		if(src.autoaim&&(src.aimimage in src.images)&&targ&&targ.pixloc)
			src.mob.aim=targ.pixloc-src.mob.pixloc
			spawn()src.ShowAim()

client/proc/HideAim()
	if(src.aimimage in src.images)src.images-=src.aimimage

client/var/autoaim=1
var/regentick=0
var/regenworldtick=0

world/Tick()
	var/regen=0
	regentick++
	regenworldtick++
	if(regenworldtick>5000)
		regenworldtick=0
		spawn()Restore()
	if(regentick==50)
		regen=1
		regentick=0
	for(var/C in clients)
		var/title="([world.cpu]%)"
		winset(C, "mainwindow", "title=[title]")
		var/mob/M = C:mob
		if(M)
			if(!M.attacking&&M.canmove && !M.tossed&&(!M.stunned||M.stunned<=world.time))
				M.client?.UpdateMoveVector()
				try
					if(!(M.PixelMove(M.movevector)))
						M.movevector=vector(0,0)
				catch
				if(regen && (world.time-M.lasthostile)>60)
					if(M.hp<M.maxhp)
						M.hp=min(M.maxhp,M.hp+M.hpregen)
						M.gui_hpbar.setValue(M.hp/M.maxhp,10)

				if(regen && (world.time-M.lasthostile)>20)
					if(M.blocks<M.maxblocks)
						M.blocks=min(M.blocks+2,M.maxblocks)

						M.Update_Blocks()
					if(M.counters<M.maxcounters)
						M.counters++
						M.Update_Counters()
	AI_Loop()
	for(var/mob/M in RefreshChunks)
		RefreshChunks-=M
		spawn()M.Chunkupdate()

var/clients[0]

mob/proc/Standstraight()
	if(src.bdir==EAST)
		src.transform=matrix()
		src.rotation=0
	else
		src.transform=matrix().Scale(-1,1)
		src.rotation=0



mob/proc/CheckCanMove()
	if(!src.charging&&!src.tossed&&!src.usingskill&&!src.block&&!src.aiming)
		src.canmove=1

mob/proc/Take_Ki(amount)
	if(src.ki>=amount)
		src.ki-=amount
		gui_kibar.setValue(src.ki/src.maxki,20)
		return 1
	else
		return 0

mob/proc/Get_Ki(amount)
	src.ki+=amount
	if(src.ki>src.maxki)src.ki=src.maxki
	gui_kibar.setValue(src.ki/src.maxki,10)
