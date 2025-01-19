
world
	hub = "Masterdan.DragonBrawlOnline"
	visibility = 1
	hub_password="JN1Vh8KBRoJVFvWu"
	name = "Dragon Brawl Online V1.0 - 516"

var/regex/comma_expression = new("(\\d)(?=(\\d{3})+$)","g") // hidden init proc, I know I know.

#define commafy(x) comma_expression.Replace(num2text(x,12),"$&,")


 #define DEBUG
var/activemobs[0]
world

	tick_lag= 0.25 // 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	view = "20x15"		// show up to 6 tiles outward from center (13x13 view)
	movement_mode=PIXEL_MOVEMENT_MODE

client/perspective=EDGE_PERSPECTIVE

proc/Awaken(mob/m,mob/opponent)
	m.targetmob=opponent
	m.CheckCanMove()
	AI_Active|=m
	m.Move(0)
	m.movevector=vector(0,0)
	m.rotation=0
	m.RotateMob(vector(0,0),100)
//	m.autoblocks=m.maxautoblocks
	m.tossed=0
	m.icon_state=""


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
	var
		step_delay = 0.25
		tmp/next_move = 0
		tmp/stunned

	Step(Dir = src.dir, Dist = move_speed, Delay = step_delay)
		if(next_move>world.time) return 0
		glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
		next_move = world.time + Delay
		return step(src,Dir,Dist)

mob
	Login()
		..()
		src.client?.removeskillbar()
		src.name=src.client.name
		src.team=src.ckey
		if(!istype(src,/mob/picking))
			src.client?.initskillbar()
			if(src.client && !src.client.chatinit)
				spawn(2)
					src.client.chatinit=1
					client.chatbox_build() // build the chatbox
					client.chatlog = "outputwindow.output" // set chatlog
					_message(world, "[name] has logged in.", "yellow") // notify world



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




mob/var/skills[]
mob/var/alist/unlocked[]
mob/var/tmp/spawnings[0]

mob/proc
	Kaioken(mult=4.2)
		src.icon_state="transform"
		src.form="kaioken"
		src.icon_state=""
		src.Set_PL(round(src.basepl*mult,1))
		src.Create_Aura("Red")
		src.vis_contents|=src.aura
		src.vis_contents|=src.auraover
		src.aura.icon_state="start"
		src.auraover.icon_state="start"

		sleep(2)
		src.aura.icon_state="aura"
		src.auraover.icon_state="aura"
		sleep(4)
		src.filters += filter(
			type = "color",,
		 	color = list(255,220,220)
		 	)

		src.aura.icon_state=""
		src.auraover.icon_state=""
		sleep(10)
		src.vis_contents-=src.aura
		src.vis_contents-=src.auraover

	Kaioken_end()
		src.icon_state=""
		src.Set_PL(round(src.basepl,1))
		src.form=null
		src.filters=null
		src.Create_Aura("White")

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


mob/var/tmp/flyinglevel=3
mob/var/tmp/falling=0
world/turf=/turf/blank


mob/proc/Heal(heal)
	src.hp+=heal
	if(src.hp>src.maxhp)src.hp=src.maxhp
	gui_hpbar.setValue(src.hp/src.maxhp,10)

mob/var/tmp/storeddamage=0

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

mob/var/tmp/obj/hitbox

proc/PLcompare(mob/atk,mob/def)
	var/ratio=atk.pl/def.pl
//	world<<"ratio [ratio]"
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

mob/proc/Block()
	set waitfor = 0
	animate(src,icon_state="block",time=4)
	src.movevector=vector(0,0)
	sleep(4)
	if(src.dead)return
	if(src.client?.movekeydown) src.icon_state="dash2"
	else src.icon_state=""

obj
	step_size = 8

client
	var
		alist/keydown
		movekeydown=0



mob/proc/Counter(mob/M)

	var/obj/fade=new/obj(src.pixloc)
	fade.icon='fade.dmi'
	var/obj/olay=new/obj
	olay.appearance=src
	olay.blend_mode=BLEND_INSET_OVERLAY
	fade.blend_mode=BLEND_MULTIPLY
	fade.appearance_flags=KEEP_TOGETHER
	fade.vis_contents+=olay

	if(M)
		if(!M.client)M.stunned=world.time+20
		else M.stunned=world.time+5
		var/vector/V=M.pixloc-src.pixloc
		V.size=V.size*2
		var/pixloc/destination=src.pixloc+V
		var/turf/T=destination.loc
		if(T&&!T.density)
			src.pixloc=destination
		src.Face(M)


	spawn(5)
		fade.loc=null
		fade.vis_contents-=olay

mob/var/tmp/chargecd


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


mob/var/tmp
	obj/dash
	obj/dash2
	dashing=0

mob/proc
	Charge()
		if(!src.dashing && !src.client?.overworld)
			var/mob/target
			var/X=0
			var/Y=0
			if(src.dir==NORTH||src.dir==NORTHEAST||src.dir==NORTHWEST)Y=0.5
			else if(src.dir==SOUTH||src.dir==SOUTHEAST||src.dir==SOUTHWEST)Y=-0.5
			if(src.dir==WEST||src.dir==NORTHWEST||src.dir==SOUTHWEST)X=-1
			else if(src.dir==EAST||src.dir==NORTHEAST||src.dir==SOUTHEAST)X=1

			var/list/mobs=new/list
			for(var/turf/T in block(src.x-8+X*7,src.y-8+Y*7,src.z,src.x+8+X*7,src.y+Y*7+8))
				for(var/mob/M in T)
					if(M!=src)mobs+=M
			if(src.targetmob in mobs)
				target=src.targetmob
			else if(src.lastattacked in mobs)
				target=src.lastattacked
			else if(src.lastattackedby in mobs)
				target=src.lastattackedby
			else if(mobs.len)
				target=pick(mobs)

			if(!target)return


			var/obj/A
			var/obj/B

			if(src.dash)
				A=src.dash
			else
				A=new/obj
			if(src.dash2)
				B=src.dash2
			else
				B=new/obj
			A.layer=MOB_LAYER+0.1
			A.density=0
			A.icon=aura.icon
			A.icon_state="dash"
			A.alpha=100
			A.bound_width=80
			A.bound_height=106
			A.pixel_y=-26
			A.pixel_w=-24
			B.layer=OBJ_LAYER
			B.density=0
			B.icon=aura.icon
			B.icon_state="dash"
			B.alpha=180
			B.bound_width=80
			B.bound_height=106
			B.pixel_y=-26
			B.pixel_w=-24
			src.dash=A
			src.dash2=B
			src.dashing=1
			src.vis_contents+=src.dash
			src.vis_contents+=src.dash2
			src.icon_state="dash2"
			var/oldstep=src.step_size
			var/i=0
			while(src.dashing && src.ki>1)
				i++
				if(i>=5)
					src.Take_Ki(1)
					i=0
				var/vector/stepvector=target.pixloc-src.pixloc
				src.step_size=src.maxspeed
				stepvector.size=src.step_size
				Move(src.pixloc+stepvector)
				sleep(world.tick_lag)
			src.step_size=oldstep
			if(src.icon_state=="dash2")src.icon_state=""



	Chargestop()
		src.vis_contents-=src.dash
		src.vis_contents-=src.dash2
		src.dashing=0


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




//	world<<"UpdateMoveVector [V], [V.size]"

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

mob/var/autoattack=0
//bumping code
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
