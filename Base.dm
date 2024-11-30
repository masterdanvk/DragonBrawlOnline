/*


 */
world
	hub = "Masterdan.DragonBrawlOnline"
	visibility = 1
	hub_password="JN1Vh8KBRoJVFvWu"
	name = "Dragon Brawl Online Test Server - 516"

var/regex/comma_expression = new("(\\d)(?=(\\d{3})+$)","g") // hidden init proc, I know I know.

#define commafy(x) comma_expression.Replace(num2text(x,12),"$&,")

//100ms
//200ms for pressing releasing and pressing again
mob/verb/Check_Vars()
	world<<"usingskill [usingskill] aiming [aiming] canmove [canmove] chargin [charging] bouncing [bouncing] tossed [tossed] attacking [attacking] block[block]"
	world<<"mybeam [mybeam] mybeam.clash [mybeam?.clash] mybeam.head [mybeam?.head]"
 #define DEBUG
var/activemobs[0]
world

	tick_lag= 0.25 // 25 frames per second
	icon_size = 32	// 32x32 icon size by default
//	map_format=TOPDOWN_MAP
	view = "20x15"		// show up to 6 tiles outward from center (13x13 view)
	movement_mode=PIXEL_MOVEMENT_MODE

client/verb/changeview(var/i as text)
	src.view=i
client/verb/Togglechat()
	if(chatactive)
		chatactive=0
		winset(src,"output1","is-visible=0")
		winset(src,"input1","is-visible=0")
	else
		chatactive=1
		winset(src,"output1","is-visible=1")
		winset(src,"input1","is-visible=1")


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

	appearance_flags = LONG_GLIDE

	proc
		Step(Dir = src.dir, Dist = move_speed, Delay)
			glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
			return step(src,Dir,Dist)

mob
	var
		step_delay = 0.25
		tmp/next_move = 0

	Step(Dir = src.dir, Dist = move_speed, Delay = step_delay)
		if(next_move>world.time) return 0
		glide_size = Delay ? step_size / (Delay / world.tick_lag) : step_size
		next_move = world.time + Delay
		return step(src,Dir,Dist)


// Make objects move 8 pixels per tick when walking
mob
	Login()
		..()
		src.name=src.client.name
mob/picking
	icon=null
	selecting=1
	Login()
		..()
		src.loc=null
		if(!src.client.name)
			var/n=input(src.client,"What is your name?","Name") as text
			//if(!n)n=src.client.key
			src.client.name=n

		src.client.Character_Select()


var/alist/playerselection=new/alist(
	Goku=/mob/goku,
	Vegeta=/mob/vegeta,
	Piccolo=/mob/piccolo,
	Gohan=/mob/gohan,
	Tien=/mob/tien,
	Krillin=/mob/krillin)

mob/verb/ChangePlayer()
	src.Die()


var/list/unusedmobs[0]
mob/var/tmp/selecting=0
mob/var/tmp/vector/displayvector
client/var/tmp/mob/select
client/var/tmp/mobselect[]
client/proc/Character_Select()

	if(src.mob&&!src.mob.selecting)
		var/mob/M=src.mob
		src.mob=new/mob/picking
		src.screen=null
		spawn(1)del(M)
	mobselect=new/list()
	for(var/types in playerselection)
		var/mob/N
		for(var/mob/R in unusedmobs[playerselection[types]])
			N=R
			break
		if(!N)
			var/T=playerselection[types]
			N=new T
		if(!src.select)src.select=N
		mobselect+=N

	src.RingDisplay()

var/ovalness=1
client/proc/RingDisplay()
	for(var/mob/m in src.screen)
		src.screen-=m
	var/picknum=mobselect.len
	if(!picknum)return
	ovalness=picknum/6
	for(var/i=1 to picknum)
		if(!mobselect[i])break
		mobselect[i].displayvector=vector(0,-96)
		mobselect[i].displayvector.Turn((i-1)*360/picknum)
		var/xoffset=0+round(mobselect[i].displayvector.x,1)
		if(xoffset>0)xoffset="+[xoffset*ovalness]"
		else xoffset="-[abs(xoffset*ovalness)]"
		mobselect[i].screen_loc="CENTER:[xoffset],CENTER:+[round(96+mobselect[i].displayvector.y,1)]"
		src.screen|=mobselect[i]


client/proc/SelectingInput(button)
	if(button=="North"||button=="East"||button=="Northeast"||button=="Northwest")src.Pick_Next()
	else if(button=="West"||button=="South"||button=="Southwest"||button=="Southeast")src.Pick_Previous()
	else
		src.Pick_Mob()

client/proc/Pick_Mob()
	if(!src.select)return
	src.mob=src.select
	src.mob.selecting=0
	src.mob.loc=locate(rand(10,90),rand(10,90),1)
	unusedmobs-=src.mob
	src.mob.screen_loc=null
	src.screen-=src.mobselect
	for(var/mob/M in src.mobselect)
		src.screen-=M
		unusedmobs|=M
		src.mobselect-=M
	src.mobselect=null
	if(!src.chatactive)Togglechat()

client/var/busy=0
client/proc/Pick_Next()
	if(busy)return
	busy=1
	var/picknum=src.mobselect.len
	for(var/i=1 to 5)
		for(var/mob/M in src.mobselect)
			M.displayvector.Turn((-360/picknum)/5)
			var/xoffset=0+round(M.displayvector.x,1)
			if(xoffset>0)xoffset="+[xoffset*ovalness]"
			else xoffset="-[abs(xoffset*ovalness)]"
			var/newscreenloc ="CENTER:[xoffset],CENTER:+[round(96+M.displayvector.y,1)]"
			M.screen_loc=newscreenloc
		sleep(1)

	src.mob.selecting++
	if(src.mob.selecting>picknum)src.mob.selecting=1
	src.select=src.mobselect[src.mob.selecting]
	busy=0


client/proc/Pick_Previous()
	if(busy)return
	busy=1
	var/picknum=src.mobselect.len
	for(var/i=1 to 5)
		for(var/mob/M in src.mobselect)
			M.displayvector.Turn((360/picknum)/5)
			var/xoffset=0+round(M.displayvector.x,1)
			if(xoffset>0)xoffset="+[xoffset*ovalness]"
			else xoffset="-[abs(xoffset*ovalness)]"
			var/newscreenloc ="CENTER:[xoffset],CENTER:+[round(96+M.displayvector.y,1)]"
			M.screen_loc=newscreenloc
		sleep(1)

	src.mob.selecting--
	if(src.mob.selecting<=0)src.mob.selecting=picknum
	src.select=src.mobselect[src.mob.selecting]
	busy=0



mob/verb/say(i as text)
	world<<"[usr.client.name]: [i]"
client/New()
	src.mob=new/mob/picking
	winset(src,"output1","is-visible=0")
	winset(src,"input1","is-visible=0")
	..()


client/Del()
	var/mob/M=src.mob
	M.loc=null
	M.client=null
	..()

mob/verb/spawnmob()
	var/list/M=typesof(/mob)
	M-=/mob
	M-=/mob/picking
	var/pick=input(usr,"Select a mob to spawn","Spawn") in M
	new pick (usr.pixloc)

mob/verb/firebeams()
	sleep(10)
	world<<"ready"
	sleep(10)
	world<<"set"
	sleep(10)

	world<<"fire!"

	for(var/mob/M in world)
		if(!M.client)
			M.aim=Dir2Vector(M.dir)
			for(var/mob/m in oview(14,M))
				if(m.client)
					M.aim=m.pixloc-M.pixloc

			spawn()M.FireBeam(50,500,new M.special)

mob/verb/startpunchin()
	if(!punchin)
		punchin=1
		while(punchin)
			for(var/mob/M in world)
				if(!M.client)
					spawn()M.Punch()
			sleep(5)
	else
		punchin=0
var/punchin=0

mob/verb/change_powerlevel(var/p=src.pl as num)
	set hidden = 1
	src.Set_PL(p)


mob/proc/Set_PL(p)
	src.pl=p
	src.Refresh_Scouter()

mob/proc/Refresh_Scouter()
	var/text_pl
	if(src.pl>=10000000)
		text_pl="[round(src.pl/1000000,0.1)] M"
	else if(src.pl>=1000)
		text_pl=commafy(src.pl)
	else
		text_pl="[src.pl]"
	src.gui_pl.maptext="<span style='font-family:Calibri;font-size:12pt;'><font color=white>[text_pl]</span></font>"

atom/movable
	var/tmp
		vector/movevector
		usingskill=0
		canmove=1
		bouncing=0

mob/proc/Next_Skill()

	var/cur=1
	for(var/i=1 to src.skills.len)
		if(src.skills[i]==src.equippedskill)
			cur=i
	cur++
	if(cur>src.skills.len)cur=1
	src.equippedskill=src.skills[cur]

mob/proc/Prev_Skill()
	var/cur=1
	for(var/i=1 to src.skills.len)
		if(src.skills[i]==src.equippedskill)
			cur=i
	cur--
	if(cur<=0)cur=src.skills.len
	src.equippedskill=src.skills[cur]



mob/proc/Create_Aura(color)
	var/obj/O=new/obj
	var/obj/U=new/obj
	U.layer=MOB_LAYER-0.2
	O.layer=MOB_LAYER+0.1
	if(src.aura)del(src.aura)
	if(src.auraover)del(src.auraover)
	src.aura=U
	src.auraover=O
	U.icon='aura.dmi'
	O.icon='aura.dmi'
	U.icon_state="none"
	O.icon_state="none"
	O.alpha=80
	U.alpha=200
	O.pixel_x=6
	U.pixel_x=6
	var/col
	switch(color)
		if("Blue")
			col=rgb(50,80,180)
		if("White")
			O.alpha=50
			col=rgb(160,160,160)
		if("Yellow")
			O.alpha=50
			col=rgb(255,240,40)
		if("Purple")
			O.alpha=50
			col=rgb(222,132,255)
	U.icon+=col
	O.icon+=col


mob/var/skills[]


mob
	proc/Reset_Portrait()
		if(src.bdir==WEST)
			src.transform=null
			src.gui_portrait.appearance=src.appearance
			src.transform=new/matrix().Scale(-1,1)
		else
			src.gui_portrait.appearance=src.appearance


	proc/Transform()
		src.Reset_Portrait()
	dir=EAST
	goku
		icon='goku.dmi'
		bound_x=20
		bound_y=2
		bound_width=24
		bound_height=38
		pl=9001
		special=/Beam/Kamehameha
		Transform()
			if(!form)
				src.icon_state="transform"
				sleep(6)
				src.icon='goku_ssj.dmi'
				src.form="SSJ"
				src.icon_state=""
				src.Set_PL(round(src.pl*4.2,1))
				src.Create_Aura("Yellow")


			else
				src.icon_state="transform"
				sleep(5)
				src.icon_state=""
				src.Set_PL(round(src.pl/4.2,1))
				src.icon='goku.dmi'
				src.form=null
				src.Create_Aura("White")
			..()


		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Spiritbomb)
			src.equippedskill=src.skills[1]

	vegeta
		icon='vegeta.dmi'
		portrait_offset=5
		bound_x=20
		bound_y=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Galekgun
		New()
			..()
			src.Create_Aura("Blue")
			src.skills=list(new/Skill/Galekgun)
			src.equippedskill=src.skills[1]
		Transform()
			if(!form)
				src.icon_state="transform"
				sleep(6)
				src.icon='vegeta_ssj.dmi'
				src.form="SSJ"
				src.icon_state=""
				src.Set_PL(round(src.pl*4.2,1))
				src.Create_Aura("Yellow")


			else
				src.icon_state="transform"
				sleep(5)
				src.icon_state=""
				src.Set_PL(round(src.pl/4.2,1))
				src.icon='vegeta.dmi'
				src.form=null
				src.Create_Aura("Blue")
			..()
	piccolo
		icon='piccolo.dmi'
		bound_x=20
		bound_y=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Specialbeamcannon
		New()
			..()
			src.Create_Aura("Purple")
			src.skills=list(new/Skill/Specialbeamcannon)
			src.equippedskill=src.skills[1]

	gohan
		icon='gohan.dmi'
		bound_x=20
		bound_y=2
		bound_width=24
		bound_height=28
		pl=9000
		special=/Beam/Masenko
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Masenko,new/Skill/Kamehameha)
			src.equippedskill=src.skills[1]
	tien
		icon='tien.dmi'
		bound_x=20
		bound_y=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Tribeam
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Tribeam)
			src.equippedskill=src.skills[1]

	krillin
		icon='krillin.dmi'
		bound_x=20
		bound_y=2
		bound_width=20
		bound_height=28
		pl=9000
		special=/Beam/Kamehameha
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Destructodisc,new/Skill/Kamehameha)
			src.equippedskill=src.skills[1]

	var
		maxhp=100
		maxki=100
		ki=100
	var/tmp
		mob/lastattacked
		mob/lastattackedby
		lasthostile
		dead=0
		special
		ap
		maxspeed=16
		minspeed=4
		rotation=0
		bdir=EAST
		autoblocks=0
		block=0
		attacking=0
		tossed=0
		hp=100
		pl=9000
		invulnerable=0
		vector/facing=vector(1,0)
		aiming=0
		vector/aim
		obj/aura
		obj/auraover
		charging=0
		obj/fade
		obj/fade2
		blocktime
		Beam/mybeam
		beamtime
		form
		counters=5
		maxcounters=5
		blocks=21
		maxblocks=21
		hpregen=5

	step_size = 8

	icon='goku.dmi'

client
	var
		image/aimimage


mob/verb/give_mobs_blocks()
	for(var/mob/M in world)
		if(!M.client)
			M.autoblocks+=5

turf
	icon='turf.dmi'
	bouncy=2
	grass
		icon_state="grass"
		tile_id = "grass"

	bump
		density=1
		bouncy=10
		icon_state="bump"

mob/proc/Damage(damage,impact,critchance,mob/damager)

	var/vector/v=src.pixloc-damager.pixloc
	var/crit=prob(critchance)
	damager.lastattacked=src
	damager.Show_target(src)
	src.lastattackedby=damager
	src.lasthostile=world.time
	damager.lasthostile=world.time
	src.Show_target(damager)
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
		src.invulnerable=1
		src.dead=1
		src.icon_state="hurt1"
		src.canmove=0
		var/matrix/M=src.transform
		M.Turn(-60)
		if(damager)
			world<<"[src] has been killed by [damager]"
		else
			world<<"[src] has died!"
		if(damager)damager.Clear_target()
		src.Clear_target()
		src.density=0
		animate(src,transform=M,time=10)
		sleep(20)
		animate(src,alpha=0,time=30)
		sleep(100)
		if(!src.client)
			src.loc=null
		else
			src.client.Character_Select()




mob/var/tmp/obj/hitbox
mob/proc/Punch()
	set waitfor = 0
	if(!src.attacking)
		src.attacking=1
		var/dist=999
		var/vector/gap
		var/mob/t
		var/backstab
		var/counter=0
		var/vector/aim= Dir2Vector(src.dir)

		aim.size=15
		src.Move(src.pixloc+aim,src.dir)
		sleep(1)
		aim.size=30
		for(var/mob/M in bounds(bound_pixloc(src,src.dir)+aim,30))

			if(M.invulnerable||M==src)continue
			gap=M.pixloc-src.pixloc
			if(gap.size<dist && gap.size<=src.bound_width+30)
				dist=gap.size
				t=M
		src.canmove=0
		var/blocked=0
		if(t)

			var/duration
			src.Face(t)
			duration=world.time-t.blocktime
			if(duration<=2 && t.counters>0)
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
			src.Move(src.pixloc+gap)
			gap.size=8
			animate(src,pixel_x=pixel_x+gap.x,pixel_y=pixel_y+gap.y,time=2,flags=ANIMATION_PARALLEL)
			animate(src,pixel_x=0,pixel_y=0,delay=3,time=2,flags=ANIMATION_PARALLEL)



		animate(src,icon_state="punch1",time=2,flags=ANIMATION_PARALLEL)
		animate(src,icon_state="punch2",time=2,delay=2,flags=ANIMATION_PARALLEL)
		sleep(2)
		spawn()
			if(!blocked&&!counter)
				var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
				mid.size=mid.size/2
				Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid))
			else if(blocked)
				var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
				mid.size=mid.size/2
				Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.5,0.5)
		if(t&&!counter)spawn()t.Damage(3*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*20*(1- blocked+backstab),src)
		sleep(2)
		src.attacking=0
		src.CheckCanMove()
		if(src.client?.movekeydown) src.icon_state="dash2"
		else src.icon_state=""

mob/proc/Kick()
	set waitfor = 0
	if(!src.attacking)
		src.attacking=1
		var/dist=999
		var/vector/gap
		var/mob/t
		var/backstab
		var/counter=0
		var/vector/aim= Dir2Vector(src.dir)
		aim.size=30
		src.Move(src.pixloc+aim,src.dir)
		sleep(1)

		for(var/mob/M in bounds(bound_pixloc(src,src.dir)+aim,40))
			if(M.invulnerable||M==src)continue
			gap=M.pixloc-src.pixloc
			if(gap.size<dist && gap.size<=src.bound_width+40)
				dist=gap.size
				t=M

		src.canmove=0
		var/blocked=0
		if(t)
			src.Face(t)
			var/duration
			if(t.client)
				duration=world.time-t.client.keydown["D"]
				if(duration<=2 && t.counters>0)
					counter=1
					t.counters--
					t.Update_Counters()
					t.Counter(src)
			if(src.Backstab(t))
				backstab=1
			else
				if(t.autoblocks>0&&t.blocks>2)
					t.Block()
					t.autoblocks--
					t.blocks-=3
					t.Update_Blocks()
					blocked=1
				if(t.icon_state=="block"&&t.blocks>2)
					blocked=1
					t.blocks-=3
					t.Update_Blocks()
			src.Move(src.pixloc+gap)
			gap.size=8
			animate(src,pixel_x=pixel_x+gap.x,pixel_y=pixel_y+gap.y,time=2,flags=ANIMATION_PARALLEL)
			animate(src,pixel_x=0,pixel_y=0,delay=3,time=2,flags=ANIMATION_PARALLEL)



		animate(src,icon_state="kick1",time=2,flags=ANIMATION_PARALLEL)
		animate(src,icon_state="kick2",time=2,delay=2,flags=ANIMATION_PARALLEL)
		sleep(2)
		spawn()
			if(!blocked&&!counter)
				var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
				mid.size=mid.size/2
				Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid))
			else if(blocked)
				var/vector/mid=bound_pixloc(src,0)-bound_pixloc(t,0)
				mid.size=mid.size/2
				Explosion(/obj/FX/Smack,bound_pixloc(t,0)+mid,vector2angle(mid),0.5,0.5)
		if(t&&!counter)spawn()t.Damage(9*PLcompare(src,t)/(1+blocked),6/(1+blocked*2),PLcompare(src,t)*50*(1- blocked+backstab),src)
		sleep(2)
		src.attacking=0
		src.CheckCanMove()
		if(src.client?.movekeydown) src.icon_state="dash2"
		else src.icon_state=""


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
	if(src.client?.movekeydown) src.icon_state="dash2"
	else src.icon_state=""


obj
	step_size = 8
client
	var
		alist/keydown
		movekeydown=0

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
//	world<<"[src.rotation]"
	M.Turn(-src.rotation)
	src.transform=M

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

client
	New()
		. = ..()
		winset(src, "AnyMacro", list(
			name = "Any",
			parent = "macro",
			command = @"keydownverb [[*]]"))
		winset(src, "AnyMacroUp", list(
			name = "Any+Up",
			parent = "macro",
			command = @"keyupverb [[*]]"))

client/proc/GamePad2Key(button, keydown)
	var/b
	switch(button)
		if("GamepadFace1")b="D"
		if("GamepadFace2")b="A"
		if("GamepadFace3")b="F"
		if("GamepadFace4")b="S"

		if("GamepadL1")b="Q"
		if("GamepadR1")b="W"
		if("GamepadLeft")b="West"
		if("GamepadRight")b="East"
		if("GamepadUp")b="North"
		if("GamepadDown")b="South"
		if("GamepadSelect")b="Escape"
		if("GamepadUpLeft")
			if(keydown)
				spawn()src.keydownverb("North")
				spawn()src.keydownverb("West")
			else
				spawn()src.keyupverb("North")
				spawn()src.keyupverb("West")
			return
		if("GamepadDownLeft")
			if(keydown)
				spawn()src.keydownverb("South")
				spawn()src.keydownverb("West")
			else
				spawn()src.keyupverb("South")
				spawn()src.keyupverb("West")
			return

		if("GamepadUpRight")
			if(keydown)
				spawn()src.keydownverb("North")
				spawn()src.keydownverb("East")
			else
				spawn()src.keyupverb("North")
				spawn()src.keyupverb("East")
			return
		if("GamepadDownRight")
			if(keydown)
				spawn()src.keydownverb("South")
				spawn()src.keydownverb("East")
			else
				spawn()src.keyupverb("South")
				spawn()src.keyupverb("East")
			return
	if(b)
		spawn()
			if(keydown)//&&!src.keydown[b])
				src.keydownverb(b)
			else if(src.keydown[b])
				src.keyupverb(b)

client/verb/keydownverb(button as text)
	set instant=1
	set hidden = 1
	if(button=="GamepadFace1"||button=="GamepadFace2"||button=="GamepadFace3"||button=="GamepadFace4"||button=="GamepadL1"||button=="GamepadR1"||button=="GamepadLeft"||button=="GamepadRight"||button=="GamepadUp"||button=="GamepadDown"||button=="GamepadUpLeft"||button=="GamepadDownLeft"||button=="GamepadUpRight"||button=="GamepadDownRight")
		src.GamePad2Key(button,1)
		return

	var/mob/M=src.mob
	if(M.selecting)
		src.SelectingInput(button)
		return
	if(M.dead||M.icon_state=="transform")return
	if(!src.keydown)src.keydown=new/alist()
	if(src.keydown["D"]&&button=="S")
		M.Transform()
		return
	src.keydown[button]=world.time
	var/starttime=world.time



	if((src.keydown["F"]||(src.keydown["D"]&&src.keydown["North"]))&&world.time>M.chargecd) //charge
		if(!M.charging&&!M.aiming)
			if(M.block)
				M.block=0
				if(M.icon_state=="block")
					M.icon_state=""

			M.charging=1
			M.canmove=0
			M.aura.icon_state="none"
			M.auraover.icon_state="none"
			M.vis_contents|=M.aura
			M.vis_contents|=M.auraover
			M.aura.icon_state="start"
			M.auraover.icon_state="start"
			if(M.bdir==EAST)
				M.transform=matrix()
				M.rotation=0
			else
				M.transform=matrix().Scale(-1,1)
				M.rotation=0
			spawn()
				while(M.charging&&src.keydown[button]==starttime)
					M.chargecd=world.time+15
					if(M.ki<M.maxki)
						M.Get_Ki(min((M.maxki-M.ki),10))
					sleep(5)


			spawn(3)
				M.aura.icon_state="aura"
				M.auraover.icon_state="aura"



	else
		if(button=="D")
			M.icon_state="block"
			M.block=1
			M.canmove=0
			M.blocktime=world.time

	if(button=="S"&&M.canmove&&!M.block&&!M.usingskill&&!M.charging)
		M.icon_state="blast1"
		M.canmove=0
		M.movevector=vector(0,0)
		M.aiming=1
		if(M.facing&&M.facing.size)M.aim=vector(M.facing)
		else
			M.aim=vector(0,0)
		M.gui_charge.setValue(0)
		if(M.equippedskill)
			src.screen|=M.gui_charge
			M.gui_charge.setValue(1,M.equippedskill.ctime)

		src.ShowAim()
		spawn(M.equippedskill.ctime)
			if(src.keydown["S"]&&src.keydown["S"]==starttime)
				M.ChargeSkill()
	else
		if(button=="S"&&M.usingskill&&M.mybeam.clash)
			M.beamtime=world.time
	if(M.usingskill)return

	if(button=="North"||button=="South"||button=="East"||button=="West"||button=="Northeast"||button=="Southeast"||button=="Northwest"||button=="Southwest")
		src.movekeydown=1
		if(!M.charging)
			src.UpdateMoveVector()

	if(M)activemobs|=M

client/verb/keyupverb(button as text)
	set hidden = 1
	set instant=1
	if(button=="GamepadFace1"||button=="GamepadFace2"||button=="GamepadFace3"||button=="GamepadFace4"||button=="GamepadL1"||button=="GamepadR1"||button=="GamepadLeft"||button=="GamepadRight"||button=="GamepadUp"||button=="GamepadDown"||button=="GamepadUpLeft"||button=="GamepadDownLeft"||button=="GamepadUpRight"||button=="GamepadDownRight")
		src.GamePad2Key(button,0)
		return

	var/mob/M=src.mob

	if(M.selecting)
		return
	if(button=="Escape")
		M.ChangePlayer()
		return
	if(M.dead)
		return
	var/i=0
	while(M.icon_state=="transform"&&i<20)
		i++
		sleep(1)


	if(button=="W")M.Next_Skill()
	else if(button=="Q")M.Prev_Skill()
	if(button=="A")
		var/duration=world.time-src.keydown[button]
		if(duration>5)M.Kick()
		else M.Punch()
	if((button=="D"&& M.charging)||(button=="North"&& M.charging)||(button=="F" && M.charging))
		M.charging=0
		M.aura.icon_state="end"
		M.auraover.icon_state="end"
		M.CheckCanMove()
		spawn(3)
			if(!M.charging)
				M.aura.icon_state="none"
				M.auraover.icon_state="none"

				M.vis_contents-=M.aura
				M.vis_contents-=M.auraover

	else if(button=="D")
		M.block=0
		if(M.icon_state=="block")
			if(src.movekeydown && !M.charging)
				M.icon_state="dash2"
			else
				M.icon_state=""
		M.CheckCanMove()
	if(button=="S" && !M.usingskill &&src.keydown["S"])
		M.aiming=0
		src.HideAim()
		var/skilltime=world.time-src.keydown[button]
		src.screen-=M.gui_charge
		if(skilltime>=M.equippedskill.ctime)
			M.UseSkill(world.time-src.keydown[button])
		else
			src.keydown[button]=null
			M.UseKiBlast()

	else if(button=="S" && !M.usingskill)
		M.aiming=0
		src.HideAim()
		src.screen-=M.gui_charge
		M.usingskill=0
		M.canmove=1
		M.icon_state=""

	src.keydown.Remove(button)


	if(button=="North"||button=="South"||button=="East"||button=="West"||button=="Northeast"||button=="Southeast"||button=="Northwest"||button=="Southwest")
		src.UpdateMoveVector()
		if(!(src.keydown["North"]||src.keydown["South"]||src.keydown["East"]||src.keydown["West"]||src.keydown["Northeast"]||src.keydown["Southeast"]||src.keydown["Northwest"]||src.keydown["Southwest"]))
			src.movekeydown=0
	if(length(src.keydown)==0 && (!M.movevector || M.movevector.size<=1)) activemobs-=M



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
	src.aimimage.pixel_x=24
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

client/proc/HideAim()
	if(src.aimimage in src.images)src.images-=src.aimimage



client/proc/UpdateMoveVector()


	if(!movekeydown && (!src.mob.movevector || !src.mob.movevector.size))return
	if(src.mob.usingskill)return
	var/vx=0
	var/vy=0
	var/vector/oldmove=src.mob.movevector
	if(!(("North" in keydown)&&("South" in keydown)))
		if("North" in keydown)vy=1
		else
			if("South" in keydown)vy=-1
	if(!(("East" in keydown)&&("West" in keydown)))
		if("East" in keydown)vx=1
		else
			if("West" in keydown)vx=-1
	if("Northeast" in keydown)
		vx=1
		vy=1
	else if("Northwest" in keydown)
		vx=-1
		vy=1
	else if("Southwest" in keydown)
		vx=-1
		vy=-1
	else if("Southeast" in keydown)
		vx=1
		vy=-1
	var/vector/V=vector(vx,vy)
	src.mob.facing=V
	var/d=0
	if(vx==1)d|=EAST
	if(vx==-1)d|=WEST
	if(vy==1)d|=NORTH
	if(vy==-1)d|=SOUTH

	if(d)src.mob.dir=d
	if(src.mob.aiming&&V.size)

		var/anglediff=vector2angle(V)
		if(src.mob.aim&&src.mob.aim.size)
			anglediff-=vector2angle(src.mob.aim)
		else
			src.mob.aim=V
			src.mob.aim.size=16
		if(abs(anglediff)<=20)
			src.mob.aim=V
			src.mob.aim.size=16
		else
			var/vector/adjust=vector(V)
			adjust.size=16
			src.mob.aim+=adjust
			src.mob.aim.size=16
		src.ShowAim()
		return

	if(!(V.x==0&&V.y==0))
		V.size=max(src.mob.minspeed,src.mob.movevector?.size/2)
	else
		src.mob.movevector.size=src.mob.movevector.size-1
		if(src.mob.movevector.size<=3)
			src.mob.movevector=V
			if(src.mob.icon_state=="dash2")src.mob.icon_state=""
			if(src.mob.bdir==EAST)
				src.mob.transform=matrix()
				src.mob.rotation=0
			else
				src.mob.transform=matrix().Scale(-1,1)
				src.mob.rotation=0
		src.mob.step_size=max(src.mob.minspeed,src.mob.movevector.size)
//		world<<"UpdateMoveVector [V], [V.size]"
		return

	if(oldmove)V+=oldmove
	if(V.size>src.mob.step_size)
		src.mob.step_size=min(src.mob.maxspeed,src.mob.step_size+0.25)
	V.size=src.mob.step_size
	src.mob.movevector=V
	if(V.size>=8)
		if(src.mob.icon_state=="")
			src.mob.icon_state="dash2"
		src.mob.RotateMob(V,2)
	else
		src.mob.RotateMob(V,0)
	if(!oldmove||oldmove.size==0)
		if(src.mob.icon_state=="block")return
	//	src.mob.icon_state="dash2"
		src.mob.icon_state="dash1"
		spawn(5)
			if(src.mob.movevector.size>=3 && src.mob.canmove)
				src.mob.icon_state="dash2"
			else
				if(src.mob.icon_state=="dash1")src.mob.icon_state=""


//	world<<"UpdateMoveVector [V], [V.size]"

var/regentick=0

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




//bumping code
mob
	Bump(atom/o)
		..()
		if(istype(o,/mob))
			var/mob/M=o
			var/vector/kbvector=vector(src.movevector)
			kbvector+=(M.pixloc-src.pixloc)
			if(src.client?.keydown["A"])
				spawn()
					if(!src.attacking)
						var/duration=world.time-src.client?.keydown["A"]
						if(duration>5)src.Kick()
						else src.Punch()
						src.client?.keydown["A"]=world.time


			else
				if(M.canmove&&!M.tossed)M.Move(M.pixloc+kbvector.size=4)
			return
		if(src.bouncing && src.canmove)src.bouncing=0
		if(src.bouncing)return
		else
			src.bounce(o)


mob/proc/knockback(vector/V,distance,rate)
	if(tossed)return
	var/vector/v=vector(V)
	v.size=distance
	var/vector/S=vector(v)
	S.size=rate
	src.canmove=0
	var/oldglide=src.glide_size
	src.glide_size=rate

	while(distance>0)
		if(distance<rate)
			rate=distance
			S.size=rate
		src.step_size=rate
		src.Move(src.pixloc+S)
		distance-=rate

		sleep(world.tick_lag)
	src.glide_size=oldglide
	sleep(1)
	src.Move(0)
	src.CheckCanMove()


mob/proc/sendflying(vector/V,distance,rate)
	if(tossed)return
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
	src.autoblocks=5
	src.tossed=0
	src.CheckCanMove()
	src.icon_state=""

atom/var/bouncy=1
atom/movable/proc/bounce(atom/T)
	src.bouncing=1

	var/vector/normal=getnormal(src,T)
	if(normal.size==0)
		world<<"normal [normal], [src.pixloc] / [T.pixloc]"
		return

	var/vector/incident=vector(src.movevector)
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
