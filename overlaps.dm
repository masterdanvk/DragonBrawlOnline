world/Tick()
	var/regen=0
	regentick++
	if(regentick==50)
		regen=1
		regentick=0
	for(var/mob/M in world)
		if(M.canmove && !M.tossed)
			M.client?.UpdateMoveVector()
			try
				if(!(M.Move(M.pixloc+M.movevector)))
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




//bumping code
mob
	Bump(atom/o)
		..()
		if(istype(o,/mob))
			var/mob/M=o
			var/vector/kbvector=vector(src.movevector)
			kbvector+=(M.pixloc-src.pixloc)
			if(src.client)
				if(src.client.keydown["A"])
					spawn()
						if(!src.attacking)
							var/duration=world.time-src.client?.keydown["A"]
							if(duration>5)src.Kick()
							else src.Punch()
							src.client?.keydown["A"]=world.time


				else
					if(M.canmove&&!M.tossed)M.Move(M.pixloc+kbvector.size=4)
				return
			else
				if(src.posture)
					var/duration=world.time-src.posturetime
					if(duration>5)src.Kick()
					else src.Punch()
					src.posturetime=world.time

		if(src.bouncing && src.canmove)src.bouncing=0
		if(src.bouncing)return
		else
			src.bounce(o)
