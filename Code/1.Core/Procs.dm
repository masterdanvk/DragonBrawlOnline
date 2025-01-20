/*
This handles important commonly used procs in addition to reciprocal procs on common interactions.
For instance, when an atom/movable crosses another atom, it also calls on_cross for that atom so that its easier to write code
for interactions such as being hit by a projectile for instance.

*/

atom
	movable
		var
			force_move=0

		Cross(atom/movable/crossing)
			if(crossing.force_move)
				return 1
			. = crossing && crossing.on_cross(src, ..())

		Crossed(atom/movable/crossing)
			if(!crossing) return
			crossing.on_crossed(src)

		Uncross(atom/movable/uncrossing)
			if(uncrossing.force_move)
				return 1
			. = uncrossing && uncrossing.on_uncross(src, ..())

		Uncrossed(atom/movable/uncrossing)
			if(!uncrossing) return
			uncrossing.on_uncrossed(src)


		proc

			on_cross(atom/movable/crossed, supercall)
				//set waitfor = 0
				return supercall

			on_crossed(atom/movable/crossed)
				set waitfor = 0

			on_uncross(atom/movable/uncrossed, supercall)
				//set waitfor = 0
				return supercall

			on_uncrossed(atom/movable/uncrossed)
				set waitfor = 0

			on_enter(atom/entering, atom/old_loc, supercall)
				//set waitfor = 0
				return supercall

			on_entered(atom/entered, atom/old_loc)
				set waitfor = 0

			on_exit(atom/exiting, atom/new_loc, supercall)
				//set waitfor = 0
				return supercall

			on_exited(atom/exited, atom/new_loc)
				set waitfor = 0


mob/proc/Backstab(mob/M)
	var/vector/attackvector=M.pixloc-src.pixloc
	attackvector.Normalize()
	var/vector/defendvector=Dir2Vector(M.dir)
//	world<<"[defendvector.Dot(attackvector)] >= [attackvector.size * defendvector.size * cos(45)] result [defendvector.Dot(attackvector) >= attackvector.size * defendvector.size * cos(45)]"
	if(defendvector.Dot(attackvector) >= attackvector.size * defendvector.size * cos(45))
		return 1
	return 0

matrix
	proc/TurnWithPivot(clockwise_degrees, pivot_x, pivot_y,flipaxis=0)
		if(flipaxis)
			if(clockwise_degrees>=90)
				return Translate(pivot_x, pivot_y).Turn(-(clockwise_degrees-180)).Scale(-1,1).Translate(-pivot_x, -pivot_y)
			else if(clockwise_degrees<=-90)
				return Translate(pivot_x, pivot_y).Turn(-(clockwise_degrees+180)).Scale(-1,1).Translate(-pivot_x, -pivot_y)
		return Translate(pivot_x, pivot_y).Turn(clockwise_degrees).Translate(-pivot_x, -pivot_y)

	proc/TurnandScaleWithPivot(clockwise_degrees,scale_x,scale_y,pivot_x, pivot_y,flipaxis=0)
		if(flipaxis)
			if(clockwise_degrees>=90)
				return Translate(pivot_x, pivot_y).Scale(scale_x,scale_y).Turn(clockwise_degrees-180).Scale(-1,1).Translate(-pivot_x, -pivot_y)
			else if(clockwise_degrees<=-90)
				return Translate(pivot_x, pivot_y).Scale(scale_x,scale_y).Turn(clockwise_degrees+180).Scale(-1,1).Translate(-pivot_x, -pivot_y)
		return Translate(pivot_x, pivot_y).Scale(scale_x,scale_y).Turn(clockwise_degrees).Translate(-pivot_x, -pivot_y)

mob/proc/Face(mob/M)
	if(!M||!src||!M.pixloc||!src.pixloc)return
	var/vector/V=M.pixloc-src.pixloc
	src.dir=Vector2Dir(V)
	src.RotateMob(V,100)


proc/Vector2Dir(vector/V)
	var/a=round(vector2angle(V),45)
	if(abs(a)>360)a=a%360
	if(a<0)a+=360
	switch(a)
		if(0) return EAST
		if(45) return NORTHEAST
		if(90) return NORTH
		if(135) return NORTHWEST
		if(180) return WEST
		if(135) return NORTHWEST
		if(225) return SOUTHWEST
		if(270) return SOUTH
		if(315) return SOUTHEAST
	return EAST







proc/vector2angle(vector/v)
	return -arctan(v)

proc/Dir2Vector(dir)
	switch(dir)
		if(EAST)
			return vector(1,0)
		if(WEST)
			return vector(-1,0)
		if(NORTH)
			return vector(0,1)
		if(SOUTH)
			return vector(0,-1)
		if(NORTHEAST)
			return vector(0.707,0.707)
		if(NORTHWEST)
			return vector(-0.707,0.707)
		if(SOUTHEAST)
			return vector(0.707,-0.707)
		if(SOUTHWEST)
			return vector(-0.707,-0.707)

proc/Dir2Angle(dir)
	switch(dir)
		if(NORTH)return 90
		if(SOUTH)return 270
		if(EAST)return 0
		if(NORTHEAST)return 45
		if(SOUTHEAST)return 315
		if(WEST)return 180
		if(NORTHWEST)return 135
		if(SOUTHWEST)return 225

proc/angle2vector(angle,dist)
	var/vx=round(cos(angle)*dist,1)
	var/vy=round(sin(angle)*dist,1)
	return vector(vx,vy)

proc/anglebetweenvectors(vector/V1,vector/V2)
	if(V1&&V1.size&&V2&&V2.size)
		return arccos(V1.Dot(V2)/(V1.size*V2.size))
	else
		return 0

proc/calculate_bounce(vector/incident_vector, vector/normal_vector)
	// Ensure the normal vector is normalized
	normal_vector.Normalize()
	 // Calculate the dot product
	var/dot_product = incident_vector.Dot(normal_vector)

	// Calculate the bounce vector

	var/bounce_vector = incident_vector - (normal_vector * 2 * dot_product)
	return bounce_vector



proc/getnormal(atom/movable/mover,atom/obstacle)
	var/pixloc/mtr = bound_pixloc(mover,NORTHEAST) - bound_pixloc(obstacle,SOUTHWEST)
	var/pixloc/mbl = bound_pixloc(mover,SOUTHWEST) - bound_pixloc(obstacle,NORTHEAST)
	var/vector/normal = vector(0,0)
	if(abs(mtr.y)<=0) //collided on NORTH normal
		normal.y = 1
	else if(abs(mbl.y)<=1) //collided on SOUTH normal
		normal.y = -1
	if(abs(mtr.x)<=1) //collided on WEST normal
		normal.x = -1
	else if(abs(mbl.x)<=1) //collided on EAST normal
		normal.x = 1
	normal.Normalize()
	return normal

//from Crazah
proc
	color2matrix(var/color)
		var/list/rgb = rgb2num(color)
		if(!length(rgb)) return null

		var/r = rgb[1] / 255
		var/g = rgb[2] / 255
		var/b = rgb[3] / 255

		// Return the full 20-element RGBA matrix
		// Format: [rr,rg,rb,ra, gr,gg,gb,ga, br,bg,bb,ba, ar,ag,ab,aa, cr,cg,cb,ca]
		return list(
			r,   0,   0,   0,  // Red row
			0,   g,   0,   0,  // Green row
			0,   0,   b,   0,  // Blue row
			0,   0,   0,   1,  // Alpha row (identity)
			0,   0,   0,   0   // Color offset row (no offset)
			)
	matrix2rgb(list/matrix)
		if(!islist(matrix) || length(matrix) != 20)
			throw EXCEPTION("Invalid matrix passed to matrix2rgb()")
		var/r = round(matrix[1] * 255)
		var/g = round(matrix[6] * 255)
		var/b = round(matrix[11] * 255)
		return rgb(r, g, b)

proc/color_matrix_rotate_hue(angle)
	var/sin = sin(angle)
	var/cos = cos(angle)
	var/cos_inv_third = 0.333*(1-cos)
	var/sqrt3_sin = sqrt(3)*sin
	return list(
		round(cos+cos_inv_third, 0.001), round(cos_inv_third+sqrt3_sin, 0.001), round(cos_inv_third-sqrt3_sin, 0.001), 0,
		round(cos_inv_third-sqrt3_sin, 0.001), round(cos+cos_inv_third, 0.001), round(cos_inv_third+sqrt3_sin, 0.001), 0,
		round(cos_inv_third+sqrt3_sin, 0.001), round(cos_inv_third-sqrt3_sin, 0.001), round(cos+cos_inv_third, 0.001), 0,
		0,0,0,1,
		0,0,0,0)




atom/movable
	proc/PixelMove(vector/motion)
		step_size = glide_size = max(abs(motion.x), abs(motion.y))
		return Move(motion)

	proc/PixelMoves(vector/motion,speed=src.step_size)
		var/remaining=motion.size
		var/ostep_size=src.step_size
		var/oglide_size=src.glide_size

		while(remaining>0)
			motion.size=min(speed,remaining)
			step_size = glide_size = motion.size//max(abs(motion.x), abs(motion.y))
			remaining-=motion.size

			if(!Move(motion))
				src.step_size=ostep_size
				src.glide_size=oglide_size
				return 0
			sleep(world.tick_lag)
		src.step_size=ostep_size
		src.glide_size=oglide_size
		return 1

mob/proc/RotateMob(vector/V,weight=100)
	var/angle=round(arctan(V),1)
	if(src.bdir==WEST && angle==90)angle=90.1
	var/flip=1
	if(bdir==EAST)
		if(angle>90)
			angle-=180
			bdir=WEST
			flip=-1
		if(angle<-90)
			angle+=180
			bdir=WEST
			flip=-1
	else

		if(angle<90 && angle>-90)
			bdir=EAST
		else
			if(angle>=90)
				angle-=180
				flip=-1
			if(angle<=-90)
				angle+=180
				flip=-1

	if(flip==1)bdir=EAST

	var/matrix/M=new/matrix()
	src.rotation=(clamp(src.rotation,-30,30)*(100-weight)+angle*weight)/100
	M.Scale(flip,1)
	M.Turn(-src.rotation)
	src.transform=M


mob/proc/AngleRotateMob(angle)
	if(src.bdir==WEST && angle==90)angle=90.1
	var/flip=1
	if(bdir==EAST)
		if(angle>90)
			angle-=180
			bdir=WEST
			flip=-1
		if(angle<-90)
			angle+=180
			bdir=WEST
			flip=-1
	else

		if(angle<90 && angle>-90)
			bdir=EAST
		else
			if(angle>=90)
				angle-=180
				flip=-1
			if(angle<=-90)
				angle+=180
				flip=-1

	if(flip==1)bdir=EAST

	var/matrix/M=new/matrix()
	src.rotation=angle
	M.Scale(flip,1)
	M.Turn(src.rotation)
	src.transform=M
	sleep(2)

mob/proc/Target()
	var/list/targets=new/list
	var/mob/target

	for(var/mob/M in obounds(src,500))
		if(!M.dead)targets+=M
	if(src.target && !src.target.dead && src.target in targets)
		target=src.target
	if(src.lastattacked in targets)
		target=src.lastattacked

	else if(src.lastattackedby in targets)
		target=src.lastattackedby
	else
		if(targets.len)
		//	vector2angle(vector/v)
		//	angle2vector(angle,dist)
			var/fitscore
			for(var/mob/m in targets)
				if(m.team!=src.team && m!=src)
					var/vector/diff=m.pixloc-src.pixloc
					var/dist=diff.size
					var/angle=vector2angle(diff)
					if(angle<0)angle+=360
					var/uaim=Dir2Angle(src.dir)
					var/distscore=(500-dist)/5
					var/aimscore=(360-abs(angle-uaim))/3.6
					var/score=(aimscore)*0.70+(distscore)*0.30
					if(score>fitscore)
						target=m
						fitscore=score

	if(target && target!=src)
		src.target=target
		return (target)

mob/proc/AutoAim(vector/aim)
	var/mob/target
	target=src.Target()


	if(target && target!=src)
		return (target.pixloc-src.pixloc)

	aim=Dir2Vector(src.dir)

	return aim