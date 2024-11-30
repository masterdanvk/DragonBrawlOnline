
//credit to F0lak
proc/Particle(atom/source, effect/effect, vector/offset = vector(0, 0), duration)
	var/effect/new_effect = new effect
	new_effect.layer = source.layer
	new_effect.plane = source.plane
	new_effect.pixloc = source.pixloc + offset

	if(duration)
		spawn(duration)
			if(new_effect)
				del new_effect

	else if(new_effect.lifespan)
		spawn(new_effect.lifespan)
			if(new_effect)
				del new_effect

	return new_effect

effect
	icon = null
	parent_type = /atom/movable
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	var/tmp/list/emitter/emitters // list of emitters, each with their own particle
	var/tmp/lifespan

	New()
		..()
		vis_contents |= emitters

	proc/End()
		set waitfor = FALSE
		var/longest_time = 1
		for(var/emitter/emitter in emitters)
			emitter.particles.spawning = FALSE
			if(emitter.particles.lifespan > longest_time)
				longest_time = emitter.particles.lifespan
		sleep(longest_time)
		del src

emitter
	icon = null
	parent_type = /atom/movable
	appearance_flags = PIXEL_SCALE
	vis_flags = VIS_INHERIT_LAYER

	Write()
		var/save_particle = particles
		particles = null
		.=..()
		particles = save_particle

effect/fire
	emitters = newlist(/emitter/fire_flame, /emitter/fire_smoke, /emitter/fire_sparks)

emitter/fire_flame
	particles = /particles/fire_flame

emitter/fire_smoke
	particles = /particles/fire_smoke

emitter/fire_sparks
	particles = /particles/fire_sparks

mob/verb/LightFire()
	usr << "You light a fire"
	Particle(loc, /effect/fire)