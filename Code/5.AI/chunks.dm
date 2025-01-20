/*
All maps included on compile are "chunked", this is a concept where each 5x5 square of turfs are stored in a global list. This is helpful for AI aggro detection.
When an AI moves, it will mark itself within the chunks that it can "see" with its detection range. New maps will not automatically be chunked, and therefor
AI with a roaming detection range or an aggro detection range will not function on those runtime generated maps. You can easily "chunk" new maps into the chunk list, but this isnt
done by default.
Chunks are far more cpu effective for AI detection than the AI constantly looking at all surrounding turfs on some interval. It allows AI behavior to be triggered by moving into their
detection radius, which takes far less effort for the server.
Chunks can also be helpful for detection and movement on a minimap system, which this demo does not include.

*/

var
	chunksize=5
	chunkinitialized=0
	updatechunks[0]
	activechunks[0]
	changedchunks[0]
	chunks[][][]
	RefreshChunks[0]

var
	turfcolors[0]
	turfmatrix[][][]
	obj/minimap
	maxX
	maxY



mob
	var/tmp
		wanderrange=0
		aggrorange=0
		initialchunk=0

mob/proc/Chunkupdate()

	while(!chunkinitialized)
		sleep(10)
	var/turf/t=src.loc
	var/chunk/c=t?.chunk

	if(!c)return
	if(src.initialchunk&&src.chunk&&src.chunk==c)return
	src.initialchunk=1
	if(!src.client && src.targetmob && src in AI_Active) return
	if(src.chunk)
		src.chunk.moblist-=src
		if(!src.chunksdetecting)src.chunksdetecting=new/list
		if(!src.chunksaggroing)src.chunksaggroing=new/list
		for(var/chunk/C in src.chunksdetecting)
			C.moblist-=src
			C.mobaggroing-=src
			C.mobdetecting-=src
		for(var/chunk/C in src.chunksaggroing)
			C.moblist-=src
			C.mobaggroing-=src
			C.mobdetecting-=src
	src.chunk=c
	var/range=max(src.wanderrange,src.aggrorange)
	if(!src.client && range)
		var/r=range-1
		var/I=-r

		while(I<=r)
			var/I2=-r
			while(I2<=r)
				var/skip=0
				if(c.X+I<=0||c.Y+I2<=0)skip=1
				else if(chunks.len<c.Z||chunks[c.Z].len<c.X+I||chunks[c.Z][c.X+I].len<c.Y+I2)skip=1



				if(!skip)

					var/chunk/C=chunks[c.Z][c.X+I][c.Y+I2]
					var/i = max(abs(I),abs(I2))
					if(aggrorange>=(i)&&aggrorange)
						C.mobaggroing|=src
						src.chunksaggroing|=C
					else
						C.mobdetecting|=src
						src.chunksdetecting|=C
				I2++
			I++

	if(src.client) //players triggering detection
		for(var/mob/aggros in c.mobaggroing)
			//world.log<<"[aggros] aggrod [src] t=[aggros.targetmob]"
			if(aggros.targetmob||aggros.dead) continue

			aggros.Detect(src)

		for(var/mob/aggros in c.mobdetecting)
			//world.log<<"[aggros] wander [src] t=[aggros.targetmob]"
			if(src in aggros.wanderlist) continue
			aggros.Wander(src)



turf/Entered(mob/A)
	..()
	if(istype(A,/mob))
		if(A.client&&(!A.chunk || src.chunk!=A.chunk))
			RefreshChunks|=A





world/proc/InitiateChunks()
	set background = 1
	var/ox=1
	var/oy=1
	var/oz=1
	var/OX=1
	var/OY=1
	chunks=new/list(world.maxz,world.maxx/chunksize,world.maxy/chunksize)
	while(oz<=world.maxz)
		while(ox<=world.maxx)
			while(oy<=world.maxy)
				var/chunk/C = new/chunk
				var/ix=0
				var/iy=0
				while(ix<chunksize)
					while(iy<chunksize)
						var/turf/t=locate(ox+ix,oy+iy,oz)
						for(var/mob/M in t)
							M.chunk=C
							C.moblist+=M
							C.active=1
							RefreshChunks|=M
						t.chunk=C
						iy++
					iy=0
					ix++
				C.startx=ox
				C.endx=ox+chunksize-1
				C.starty=oy
				C.endy=oy+chunksize-1
				C.Z=oz
				oy+=chunksize
				chunks[oz][OX][OY]=C
			//	world.log<<"[OX] [OY] [oz] has a chunk [C]"
				C.Y=OY
				C.X=OX
				if(OY>maxY)maxY=OY
				OY++

			oy=1
			OY=1
			ox+=chunksize
			if(OX>maxX)maxX=OX
			OX++
		ox=1
		OX=1

		oz++

	chunkinitialized=1


//	world<<"maxX[maxX] maxY[maxY]"



chunk
	var
		turf/home
		turflist[0]
		moblist[0]
		active=0
		startx
		endx
		starty
		endy
		mobaggroing[0]
		mobdetecting[0]

		X
		Y
		Z

turf
	var
		chunk/chunk






//turfmatrix=new/list(maxX,maxY)