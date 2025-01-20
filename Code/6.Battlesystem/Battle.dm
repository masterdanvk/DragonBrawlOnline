/*
The battle system is a simple proc which takes in an instance and list of players (clients) and mobrefs (objects which visually represent and reference to mobs)
This system takes in these parameters from battlegui, which itself pulls Instances from Instances.dm.
Effectively what this does is start a match by spawning a copy of a stage map and pull in waves of mobs from team 1 and team 2.
When a team's mobs are depleted (they Die()), the other team will be called a victor and the battle will end.
AI mobs will be awakened and pick a random opponent.


*/
proc/Battle(list/Players,list/Mobrefs,Instance/I)

	var/Map/map = maps.copy(I.stage)
	var/obj/stagetag/T=stageobjs[I.stage]//load level
	for(var/client/C in Players)
		C.inbattle=1
		C.LeaveOverworld()
		C.oldmob=C.mob
		C.oldloc=C.mob.loc
		C.mob.loc=null
		C.edge_limit = T.dimensions
	var/list/mobs[8]
	var/list/activeteam1=new/list()
	var/list/activeteam2=new/list()
	var/list/Good=new
	var/list/Evil=new
	var/list/computerallies=new/list()
	var/list/computerenemies=new/list()
	var/wave=1
	var/wave2=1

	for(var/i in 1 to 8)
		mobs[i]=new/list()
		for(var/i2 in 1 to 7)
			if(Mobrefs[i]&&Mobrefs[i][i2])
				if(Mobrefs[i][i2].ref)
					mobs[i]+=Mobrefs[i][i2].ref

					if(i<=4)
						Mobrefs[i][i2].ref.team="Good"
						Mobrefs[i][i2].ref.pnum=i2
						Good+=Mobrefs[i][i2].ref

					else
						Mobrefs[i][i2].ref.team="Evil"
						Mobrefs[i][i2].ref.pnum=i2
						Evil+=Mobrefs[i][i2].ref


	for(var/i in 1 to 4)
		if(Mobrefs[i][wave]&&Mobrefs[i][wave].ref)
			Mobrefs[i][wave].ref.loc=locate(T.Start.x-(i)-3,T.Start.y,map.z)
			Mobrefs[i][wave].ref.team="Good"
			activeteam1|=Mobrefs[i][wave].ref

			if(!Players[i])spawn(5)if(activeteam2.len)Awaken(Mobrefs[i][wave].ref,pick(activeteam2))
			else
				Players[i].mob=Mobrefs[i][wave].ref
				Players[i].mob.team="Good"
	for(var/i in 5 to 8)
		if(Mobrefs[i][wave2]&&Mobrefs[i][wave2].ref)
			Mobrefs[i][wave2].ref.loc=locate(T.Start.x+(i-4)+3,T.Start.y,map.z)
			Mobrefs[i][wave2].ref.team="Evil"
			activeteam2|=Mobrefs[i][wave2].ref
			if(!Players[i])spawn(5)if(activeteam1.len)Awaken(Mobrefs[i][wave2].ref,pick(activeteam1))
			else
				Players[i].mob=Mobrefs[i][wave2].ref
				Players[i].mob.team="Evil"
	sleep(20)
	for(var/mob/C in computerallies)
		spawn()Awaken(C,pick(activeteam2))
	for(var/mob/C in computerenemies)
		spawn()Awaken(C,pick(activeteam1))

	while(Good.len && Evil.len)
		sleep(100)
		for(var/mob/m in activeteam1)
			if(m.dead)
				Good-=m
				var/num=m.pnum
				activeteam1-=m
				if(m in computerallies)
					computerallies-=m
					mobs[num]-=m

				else if(m.client)
					mobs[num]-=m

		for(var/mob/m in activeteam2)
			if(m.dead)
				Evil-=m
				var/num=m.pnum
				activeteam2-=m
				if(m in computerenemies)
					computerenemies-=m
					mobs[num]-=m

				else if(m.client)
					mobs[num]-=m

		if(!activeteam1.len)
			wave++
			for(var/i in 1 to 4)
				if(Mobrefs[i][wave]&&Mobrefs[i][wave].ref)
					Mobrefs[i][wave].ref.loc=locate(T.Start.x-i,T.Start.y,map.z)
					Mobrefs[i][wave].ref.team="Good"
					activeteam1|=Mobrefs[i][wave].ref
					if((Players.len>=i||!Players[i]) && !activeteam2.len)
						computerallies|=Mobrefs[i][wave].ref
						Awaken(Mobrefs[i][wave].ref,pick(activeteam2))
					else
						if(Players.len>=i)
							Players[i].mob=Mobrefs[i][wave].ref
							Players[i].mob.team="Good"

		if(!activeteam2.len)
			wave2++
			for(var/i in 5 to 8)
				if(Mobrefs[i][wave2]&&Mobrefs[i][wave2].ref)
					Mobrefs[i][wave2].ref.loc=locate(T.Start.x+(i-4),T.Start.y,map.z)
					Mobrefs[i][wave2].ref.team="Evil"
					activeteam2|=Mobrefs[i][wave2].ref
					if((Players.len>=i||!Players[i]) && activeteam1.len)
						computerenemies|=Mobrefs[i][wave2].ref
						Awaken(Mobrefs[i][wave2].ref,pick(activeteam1))
					else
						if(Players.len>=i)
							Players[i].mob=Mobrefs[i][wave2].ref
							Players[i].mob.team="Evil"

		for(var/mob/A in computerenemies)
			if(!A.targetmob || A.targetmob.dead)
				if(activeteam1?.len)
					Awaken(A,pick(activeteam1))
		for(var/mob/A in computerallies)
			if(!A.targetmob || A.targetmob.dead)
				if(activeteam2?.len)
					Awaken(A,pick(activeteam2))
	if(!activeteam1.len)
		for(var/i in 1 to 4)
			if(Players[i])
				Players[i].screen|=Defeat
		for(var/i in 5 to 8)
			if(Players[i])
				Players[i].screen|=Victory
		world.log<<"Team 2 won!"
	else
		world.log<<"Team 1 won!"
		for(var/i in 5 to 8)
			if(Players[i])
				Players[i].screen|=Defeat
		for(var/i in 1 to 4)
			if(Players[i])
				Players[i].screen|=Victory

	sleep(50)
	map.free()

	for(var/client/C in Players)
		C.screen-=Defeat
		C.screen-=Victory
		if(C.oldmob)
			C.mob=C.oldmob
			C.mob.loc=C.oldloc
			spawn()C.VisitOverworld()
		else
			C.mob.Die()
		C.edge_limit=null
		C.inbattle=0
	for(var/mob/m in mobs)
		m.loc=null
	for(var/mob/m in Good)
		m.loc=null
	for(var/mob/m in Evil)
		m.loc=null