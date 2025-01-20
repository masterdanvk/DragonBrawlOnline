/*
Includes combat procs for things like the counter (hitting D before being hit) where you teleport behind
Blocking
Charging through a double tap of a direction key
Repulse (holding block and absorbing a certain number of melee attacks then results in a pushing effect)
Melee - punches and kicks, depending on how long the key is held for.
*/

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

mob/proc/Block()
	set waitfor = 0
	animate(src,icon_state="block",time=4)
	src.movevector=vector(0,0)
	sleep(4)
	if(src.dead)return
	if(src.client?.movekeydown) src.icon_state="dash2"
	else src.icon_state=""


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

mob/proc/Melee(duration)
	set waitfor = 0
	if(!src.attacking)

		src.attacking=1
		var/vector/gap
		var/mob/t
		var/backstab
		var/counter=0
		var/dist=90
		dist+=min(duration*6,40)
		var/mob/T=src.Target()
		var/vector/aim
		if(T)
			aim=bound_pixloc(T,0)-bound_pixloc(src,0)
			if(aim.size>100)T=null
		if(!T)aim= Dir2Vector(src.dir)
		aim.size=dist
		src.dir=Vector2Dir(aim)
		src.movevector=vector(0,0)
		src.RotateMob(aim,50)
		sleep(world.tick_lag)
		src.PixelMoves(aim,src.maxspeed*2)
		for(var/mob/M in bounds(bound_pixloc(src,src.dir)+aim,90))

			if(M.invulnerable||M==src)continue
			gap=M.pixloc-src.pixloc
			if(gap.size<dist && gap.size<=src.bound_width+90)
				dist=gap.size
				t=M
		src.canmove=0
		var/blocked=0
		if(t)

			var/bduration
			src.Face(t)
			bduration=world.time-t.blocktime
			if(bduration<=2 && t.counters>0)
				counter=1
				t.counters--
				t.Update_Counters()
				t.Counter(src)

			if(src.Backstab(t))
				backstab=1
			else
				if(t.autoblocks>0&&t.blocks>0)
					t.Block()
					t.autoblocks--
					t.blocks--
					t.Update_Blocks()
					blocked=1
				if(t.icon_state=="block"&&t.blocks>0)
					blocked=1
					t.blocks--
					t.Update_Blocks()
			gap.size=gap.size-16
			src.PixelMove(gap)
			gap.size=16
			animate(src,pixel_x=pixel_x+gap.x,pixel_y=pixel_y+gap.y,time=2,flags=ANIMATION_PARALLEL)
			animate(src,pixel_x=0,pixel_y=0,delay=3,time=1,flags=ANIMATION_PARALLEL)


		if(duration<5)
			animate(src,icon_state="punch1",time=2,flags=ANIMATION_PARALLEL)
			animate(src,icon_state="punch2",time=2,delay=2,flags=ANIMATION_PARALLEL)
			sleep(2)

			if(t)
				spawn()
					if(!blocked&&!counter)
						var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
						mid.size=mid.size/2
						Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid))
					else if(blocked)
						var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
						mid.size=mid.size/2
						Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.5,0.5)
			if(t&&!counter)
				spawn()t.Damage(2*PLcompare(src,t)/(1+blocked*3),6/(1+blocked*5),PLcompare(src,t)*10*(1- blocked+backstab),src)
				spawn()t.knockback(aim,8*PLcompare(src,t)/(1+blocked*3),src.maxspeed*2)
		else
			animate(src,icon_state="kick1",time=2,flags=ANIMATION_PARALLEL)
			animate(src,icon_state="kick2",time=2,delay=2,flags=ANIMATION_PARALLEL)
			sleep(2)
			if(t)
				spawn()
					if(!blocked&&!counter)
						var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
						mid.size=mid.size/2
						Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),1.4,1.4)
					else if(blocked)
						t.blocks-=8
						if(t.blocks<=0)
							t.blocks=0
							t.sendflying(aim,200,16) //blockbreak!
							blocked=0
						t.Update_Blocks()
						var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
						mid.size=mid.size/2
						Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.7,0.7)
			if(t&&!counter)
				spawn()t.Damage(6*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*25*(1- blocked+backstab*2),src)
				spawn()t.knockback(aim,16*PLcompare(src,t)/(1+blocked*3),src.maxspeed*2)
		sleep(2)
		src.Standstraight()
		src.attacking=0
		src.CheckCanMove()

		if(src.client?.movekeydown&&!src.dead) src.icon_state="dash2"
		else if(!src.dead) src.icon_state=""

mob/proc/Repulse(impact)
	if(!src.repulse)
		src.repulse=new/obj
		src.repulse.icon='forcepush.dmi'
		src.repulse.pixel_z=-55
		src.repulse.pixel_w=-57
		src.repulse.layer=MOB_LAYER+1
		src.repulse.density=0
		src.repulse.alpha=150
	var/obj/FX/Forcewave/F=src.repulse

	var/pixloc/origin=bound_pixloc(src,0)
	F.icon_state=""
	F.loc=src.loc
	F.pixloc=bound_pixloc(src,0)
	sleep(2)
	for(var/mob/M in bounds(origin,impact))
		if(M!=src)
			var/vector/diff=bound_pixloc(M,0)-origin
			if(abs(diff.size)<=impact)
				diff.size=round(impact,1)
				spawn()
					M.stunned=world.time+impact/32*10
					sleep(1)
					M.sendflying(diff,impact*4,16)
	sleep(2)
	F.icon_state="none"


mob/var/tmp/storedblock
mob/var/tmp/obj/repulse