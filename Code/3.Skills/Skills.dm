/*
The Skill datum exists to capture what skills a mob has, and to contain the behavior of that skill (Skill/proc/Use())
When a player presses the skill key (S) it will typically call ChargeSkill() which then calls the equipped skill's Charge() proc - if it is used.
When the skill key is released the UseSkill proc is used where, if the player has adequately charged the skill's cast time and has sufficient ki, it will
call the Skill's Use() proc, and also pass the time it has charged - allowing for an overcharge effect.
The Skill datum has an icon_state even though it has no physical representation in the game or on the players screen.
Instead this determines what icon_state is put on the players screen from this skill using the skills.dmi gui file.


*/



mob/proc/Refundskillcost()
	set waitfor = 0
	src.Get_Ki(src.equippedskill?.kicost)


obj/var
	mob/owner
mob/proc/UseSkill(time)
	if(!src.equippedskill)return
	if(src.Take_Ki(src.equippedskill.kicost))
	//check ki sufficient
		src.equippedskill.Use(src,time)
	else
		var/red = list(100,40,40,40,40,40,40,40,40,40,40,40)
		animate(src.gui_kibar,color=red,time=3)
		sleep(3)
		animate(src.gui_kibar, color = null, time = 1)
		src.usingskill=0
		src.canmove=1
		src.icon_state=""
		return

mob/proc/UseKiBlast()
	if(src.holdskill)
		src.holdskill:loc=null
		src.holdskill=null
	if(src.Take_Ki(5))
	//check ki sufficient
		src.icon_state="blast2"
		var/obj/Kiblast/K=new src.kiblast
		src.Energy_Blast(0,K)
		src.icon_state=""
	else
		var/red = list(100,40,40,40,40,40,40,40,40,40,40,40)
		animate(src.gui_kibar,color=red,time=3)
		sleep(3)
		animate(src.gui_kibar, color = null, time = 1)
		src.usingskill=0
		src.canmove=1
		src.icon_state=""
		return


mob/proc/ChargeSkill()
	set waitfor = 0
	if(!src.equippedskill)return
	src.equippedskill.Charge(src)

mob/var/tmp/holdskill

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

Skill
	var/icon
	var/counters=0
	var/icon_state
	icon='skills.dmi'
	var/kicost=0
	var/channel=0
	var/ctime=0
	var/state1="blast1"
	var/state2="blast2"
	proc/Use()
	proc/Charge()

	Kamehameha
		icon_state="kamehameha"
		ctime=4
		kicost=60
		counters=1
		state1="kame1"
		state2="kame2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Kamehameha)
	Galekgun
		icon_state="galekgun"
		ctime=4
		kicost=60
		counters=1
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Galekgun)
	Doublesunday
		ctime=4
		kicost=60
		counters=1
		icon_state="doublesunday"
		state1="kame1"
		state2="kame2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Doublesunday)
	Mouthblast
		ctime=7
		kicost=80
		counters=1
		state1="mouth1"
		state2="mouth2"
		icon_state="mouthblast"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,600,new/Beam/Mouthblast)
	Masenko
		ctime=4
		kicost=50
		counters=1
		icon_state="masenko"
		state1="masenko1"
		state2="masenko2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Masenko)
	Dondonpa
		ctime=3
		kicost=40
		counters=1
		icon_state="dondonpa"
		state1="don1"
		state2="don2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Dondonpa)
	Tribeam
		ctime=3
		kicost=60
		counters=1
		icon_state="tribeam"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,500,new/Beam/Tribeam)
	Specialbeamcannon
		ctime=10
		kicost=60
		state1="sbc1"
		state2="sbc2"
		icon_state="specialbeamcannon"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			user.FireBeam(time,275,new/Beam/Specialbeamcannon)

	Destructodisc
		ctime=5
		kicost=40
		state1="ddisc1"
		state2="ddisc2"
		icon_state="destructodisc"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			var/obj/Kiblast/Destructodisc/D
			if(!user.holdskill)D=new/obj/Kiblast/Destructodisc
			else
				D=user.holdskill
			user.Energy_Blast(time,D,vector(0,30))
			user.icon_state=""

		Charge(mob/user)
			if(user.ki>=kicost)
				var/obj/Kiblast/Destructodisc/D=new/obj/Kiblast/Destructodisc(bound_pixloc(user,0)+vector(-32,30))
				user.holdskill=D
	Spiritbomb
		ctime=15
		kicost=40
		icon_state="spiritbomb"
		state1="spiritbomb"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Spiritbomb/S
			if(!user.holdskill)S=new/obj/Kiblast/Spiritbomb
			else
				S=user.holdskill
			S.power*=1+0.05*S.charge
			user.Energy_Blast(time,S,vector(0,80+S.charge))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""

		Charge(mob/user)
			if(user.ki>=kicost)
				user.icon_state="spiritbomb"
				var/obj/Kiblast/Spiritbomb/S=new/obj/Kiblast/Spiritbomb(bound_pixloc(user,0)+vector(0,100))
				user.holdskill=S
				src.channel=1
				S.transform=(new/matrix).Scale(0.5)
				S.bound_width*=0.5
				S.bound_height*=0.5
				S.bound_x*=0.5
				S.bound_y*=0.5
				S.pixel_x=-64
				S.pixel_y=-64
				while(src.channel)
					sleep(5+S.charge/2)
					S.charge++
					S.transform*=1.05
					S.bound_width*=1.05
					S.bound_height*=1.05
					S.bound_x*=1.05
					S.bound_y*=1.05
					S.pixloc=S.pixloc+vector(0,2)
	Spiritball
		ctime=3
		kicost=50
		icon_state="spiritball"
		Use(mob/user,time)

			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Spiritbomb/S
			if(!user.holdskill)S=new/obj/Kiblast/Spiritball
			else
				S=user.holdskill
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""

	HellzoneGrenade
		ctime=3
		kicost=50
		icon_state="hellzonegrenade"
		Use(mob/user,time)

			var/mob/target=user.Target()
			if(!target)return
			src.channel=0
			var/c=12
			var/list/L=new/list()
			user.usingskill=1
			while(c>0)

				sleep(0.5)
				user.icon_state="blast2"
				var/obj/Kiblast/HellzoneGrenade/S=new/obj/Kiblast/HellzoneGrenade
				spawn(10)
				//	S.color= "#ff0000" for testing only
					S.pierce=0
					S.push=1
				var/vector/spread=vector(96,0)
				if(c%2)
					spread.Turn(90+(c-12)*360/12)
				else
					spread.Turn(90-(c-12)*360/12)
				var/pixloc/dest=bound_pixloc(target,0)+spread
				S.pixloc=bound_pixloc(user,0)
				spawn()user.Shootto(S,dest)
				if(c%2)sleep(1)
				L+=S
				user.icon_state="blast1"


				c--

			sleep(15)
			user.usingskill=0
			user.CheckCanMove()
			for(var/obj/Kiblast/O in L)
				if(!O.loc)continue
				O.persist=0
				O.explode=1
				O.push=0
				O.pierce=1
				O.power*=3
				O.distance=96
				O.spread=0
				spawn()user.Shootto(O,bound_pixloc(target,0))



			if(user.icon_state=="blast2")user.icon_state=""


	Wolffangfist
		ctime=3
		kicost=40
		icon_state="wolffangfist"
		Use(mob/user,time)
			animate(user,icon_state="punch1",flags=ANIMATION_PARALLEL,time=2)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,delay=1,time=2)
			animate(user,icon_state="punch1",flags=ANIMATION_PARALLEL,delay=2,time=3)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,delay=3,time=4)
			animate(user,icon_state="punch1",flags=ANIMATION_PARALLEL,delay=4,time=5)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,delay=5,time=6)
			user.Energy_Blast(time,new/obj/Kiblast/WFF)


	Dragonfist
		ctime=3
		kicost=80
		icon_state="dragonfist"
		Use(mob/user,time)
			animate(user,icon_state="punch2",flags=ANIMATION_PARALLEL,time=2)
			user.Energy_Blast(time,new/obj/Kiblast/Dragonfist,vector(0,-96))

	ExplosiveDemonWave
		ctime=5
		kicost=33
		state1="dwave1"
		state2="dwave2"
		icon_state="explosivedemonwave"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="punch2"
			if(!user.aim)
				user.icon_state=""
				if(user.bdir==EAST)
					user.transform=matrix()
					user.rotation=0
				else
					user.transform=matrix().Scale(-1,1)
					user.rotation=0
				user.usingskill=0
				user.CheckCanMove()
			var/vector/aimvector=user.aim

			if(!aimvector||!aimvector.size)
				user.usingskill=0
				user.canmove=1
				return
			aimvector.size=18
			var/obj/W=new/obj/FX/ExplosiveDemonWave()
			var/matrix/m=matrix()
			var/ang=-vector2angle(aimvector)
			user.AngleRotateMob(-ang)
			m.TurnandScaleWithPivot(-ang,W.scale/4,W.scale,W.bound_width/2,0)
			W.transform=m
			var/matrix/m2=matrix().TurnandScaleWithPivot(-ang,W.scale*1.25,W.scale*1.25,W.bound_width/2,0)

			W.alpha=100
			animate(W,transform=m2,alpha=255,easing=CUBIC_EASING,time=1.5)

			W.pixloc=bound_pixloc(user,0)+aimvector
			for(var/mob/M in bounds(W.pixloc,120))
				if(M.invulnerable||M==user)continue
				spawn()M.Damage(15*PLcompare(user,M),45,PLcompare(user,M)*50,user)
			sleep(1.5)
			animate(W,transform=m2,alpha=0,time=1.5)
			sleep(3.5)
			user.usingskill=0
			user.CheckCanMove()
			W.loc=null

	Solarflare
		ctime=6
		kicost=30
		state1=""
		state2="tayo"
		icon_state="solarflare"
		Use(mob/user,time)
			spawn(2)
				user.usingskill=0
				user.CheckCanMove()
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="block"
			for(var/mob/M in oview(3,user))
				M.icon_state="hurt1"
				M.stunned=world.time+50
				spawn(50)
					M.icon_state=""
			user.canmove=0
			var/obj/FX/Solarflare/S=new/obj/FX/Solarflare(bound_pixloc(user,0))
			sleep(5)
			user.canmove=1
			del(S)
			user.icon_state=""

	Burningattack
		ctime=9
		kicost=35
		icon_state="burningattack"
		state1="burning1"
		state2="burning2"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Burningattack/S=new/obj/Kiblast/Burningattack
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""
	Bigbangattack
		ctime=10
		kicost=60
		icon_state="bigbangattack"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Bigbangattack/S=new/obj/Kiblast/Bigbangattack
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""

	Pushup
		ctime=5
		kicost=20
		icon_state="spiritshot"
		state1="block"
		state2="blast2"
		Use(mob/user,time)
			spawn(4)
				user.usingskill=0
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state=""
			for(var/mob/Hit in bounds(bound_pixloc(user,0),400))
				if(Hit==user)continue
				if(Hit.block)
					Hit.Damage(30*PLcompare(user,Hit)*(0.40),20,0,user)
				else
					Hit.Damage(30*PLcompare(user,Hit),80,0,user)

				spawn()
					Hit.sendflying(vector(0,300),(400),16)


			user.CheckCanMove()
	Spiritshot
		ctime=10
		kicost=30
		icon_state="spiritshot"
		state1="block"
		state2="explode"
		Use(mob/user,time)
			spawn(4)
				user.usingskill=0
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state=""
			for(var/mob/Hit in bounds(bound_pixloc(user,0),64))
				if(Hit==user)continue
				if(Hit.block)
					Hit.Damage(30*PLcompare(user,Hit)*(0.40),20,0,user)
				else
					Hit.Damage(30*PLcompare(user,Hit),80,0,user)
			user.Repulse(128)
			user.CheckCanMove()

	Explosivewave
		ctime=10
		kicost=30
		icon_state="explosivewave"
		state1="block"
		state2="ewave"
		Use(mob/user,time)
			spawn(4)
				user.usingskill=0
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			var/vector/aimvector=user.aim
			var/pixloc/P
			var/mob/M=user.Target()
			if(!M)
				var/vector/V=vector(aimvector)
				V.size=256
				P=bound_pixloc(user,0)+V

			else
				P=bound_pixloc(M,0)
			if(!P)return
			sleep(4)
			var/obj/FX/Explosivewave/E=new/obj/FX/Explosivewave(P+vector(0,32))
			sleep(4)
			for(var/mob/Hit in bounds(P,64))
				if(Hit==user)continue
				if(Hit.block)
					Hit.Damage(45*PLcompare(user,Hit)*(0.40),20,0,user)
				else
					Hit.Damage(45*PLcompare(user,Hit),80,0,user)
				Hit.stunned=max(Hit.stunned,world.time+10)
				Hit.icon_state="hurt1"
				spawn(5)Hit.icon_state=""

			user.CheckCanMove()

			sleep(2)

			E.loc=null

	Energyblast
		ctime=5
		kicost=60
		icon_state="energyblast"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Energyblast/S=new/obj/Kiblast/Energyblast
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""
	Saturdaycrush
		ctime=10
		kicost=60
		icon_state="saturdaycrush"
		Use(mob/user,time)
			if((state2 in icon_states(user.icon)))
				user.icon_state=state2
			else
				user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/Bigbangattack/S=new/obj/Kiblast/Saturdaycrush
			user.Energy_Blast(time,S,vector(0,0))
			sleep(5)
			if(user.icon_state=="blast2")user.icon_state=""
	Kiblast
		Slicing
			icon_state="sliceblast"
		Fingerlaser
			icon_state="fingerlaser"
		Gun
			icon_state="gun"
		kicost=5
		ctime=0
		icon_state="kiblast"
		Use(mob/user,time)
			user.icon_state="blast2"
			src.channel=0
			var/obj/Kiblast/K=new user.kiblast
			user.Energy_Blast(time,K)
			user.icon_state=""

		Charge(mob/user)
			src.channel=1
			while(user.ki>=kicost && src.channel && !user.dead && user.client?.keydown["S"])
				user.Take_Ki(src.kicost)
				user.icon_state="blast1"
				sleep(1.5)
				if(src.channel)
					user.icon_state="blast2"
					var/obj/Kiblast/K=new user.kiblast
					spawn()user.Energy_Blast(0,K)
				sleep(1)



