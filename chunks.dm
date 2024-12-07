/*
So my ideal chunking system would be like this:
Every chunk has a "home" location (SW corner), an active flag, and a list of player mobs within it.
Chunks also have a proc to grab the neighboring chunk in any of 8 directions.
There's a global associative list of unique chunks that need to be updated during the world tick.
There's a global associative list of active chunks.
Chunks have an UpdateNeighbors() proc that adds themselves and all their neighbors to the global update list.
Whenever a player moves, they check if they're in the same chunk. If not, the old chunk removes them from the list and they get added to the new chunk's list. Both chunks call UpdateNeighbors().
During the beginning of world.Tick(), all chunks in the update list are traversed. Their active flag is set based on whether they or any of their neighbors have active players.
If the active status changes, a start or stop proc is called to handle any relevant tasks, and they either get added to or removed from the active list.
Next in world.Tick(), each chunk's AI stuff runs.
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
			world.log<<"[aggros] aggrod [src] t=[aggros.targetmob]"
			if(aggros.targetmob||aggros.dead) continue

			aggros.Detect(src)

		for(var/mob/aggros in c.mobdetecting)
			world.log<<"[aggros] wander [src] t=[aggros.targetmob]"
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


mob
	var
		chunkslistening[0]

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

mob
	var
		chunk/chunk
		chunksdetecting[0]
		chunksaggroing[0]



//turfmatrix=new/list(maxX,maxY)