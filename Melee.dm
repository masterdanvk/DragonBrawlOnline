mob/proc/Melee(duration)
	set waitfor = 0
	if(!src.attacking)

		src.attacking=1
		var/vector/gap
		var/mob/t
		var/backstab
		var/counter=0
		var/dist=60
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
		for(var/mob/M in bounds(bound_pixloc(src,src.dir)+aim,60))

			if(M.invulnerable||M==src)continue
			gap=M.pixloc-src.pixloc
			if(gap.size<dist && gap.size<=src.bound_width+40)
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
			gap.size=gap.size-4
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
				spawn()t.Damage(3*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*20*(1- blocked+backstab),src)
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
						var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
						mid.size=mid.size/2
						Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.7,0.7)
			if(t&&!counter)
				spawn()t.Damage(9*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*50*(1- blocked+backstab),src)
				spawn()t.knockback(aim,16*PLcompare(src,t)/(1+blocked*3),src.maxspeed*2)
		sleep(2)
		src.Standstraight()
		src.attacking=0
		src.CheckCanMove()

		if(src.client?.movekeydown&&!src.dead) src.icon_state="dash2"
		else if(!src.dead) src.icon_state=""
