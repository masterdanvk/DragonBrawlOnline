
mob

	proc/Transform()
		src.Reset_Portrait()
	proc/Revert()
		src.Reset_Portrait()
	goku
		name="Goku"
		icon='goku.dmi'
		oicon_state="goku"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9001
		special=/Beam/Kamehameha
		unlocked=alist("ssj"=1)
		behaviors=list(10,10,40,10,30) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special

		Transform()
			if(src.unlocked["ssj"])
				if(!form)
					src.icon_state="transform"
					sleep(6)
					src.icon='goku_ssj.dmi'
					src.form="SSJ"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))
					src.Create_Aura("Yellow")
				else return
			else if(src.unlocked["kaiokenx2"])
				src.form="kaiokenx2"
				Kaioken(1.95)
			..()

		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='goku.dmi'
				src.form=null
				src.Create_Aura("White")
			..()



		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Spiritbomb,new/Skill/Spiritshot,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]

	vegeta
		name="Vegeta"
		icon='vegeta.dmi'
		oicon_state="vegeta2"
		portrait_yoffset=5
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38

		pl=9000
		special=/Beam/Galekgun
		unlocked=alist("ssj"=1)
		behaviors=list(5,5,25,40,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Blue")
			src.skills=list(new/Skill/Galekgun,new/Skill/Bigbangattack,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["ssj"])
				if(!form)
					src.icon_state="transform"
					sleep(6)
					src.icon='vegeta_ssj.dmi'
					src.form="SSJ"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))
					src.Create_Aura("Yellow")
				else return
			..()


		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='vegeta.dmi'
				src.form=null
				src.Create_Aura("Blue")
			..()

	piccolo
		name="Piccolo"
		icon='piccolo.dmi'
		oicon_state="piccolo"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Specialbeamcannon
		unlocked=alist("orange"=1)
		behaviors=list(5,25,25,20,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		raditzfight
			pl=408
			unlocked=null
		New()
			..()
			src.Create_Aura("Purple")
			src.skills=list(new/Skill/Specialbeamcannon,new/Skill/HellzoneGrenade,new/Skill/ExplosiveDemonWave,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["orange"] && !src.form)

				src.icon='piccolo_orange.dmi'
				src.bound_width=32
				src.bound_height=46
				src.icon_w=30
				src.icon_z=4
				src.form="Orange"
				src.icon_state="transform"
				sleep(9)

				src.icon_state=""
				src.Set_PL(round(src.basepl*4.2,1))
				src.Create_Aura("Orange")
			..()
		Revert()
			if(form)
				src.icon_state="revert"
				src.bound_width=24
				src.bound_height=38
				src.icon_w=20
				src.icon_z=0
				sleep(4)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='piccolo.dmi'
				src.form=null
				src.Create_Aura("Purple")

			..()

	gohan
		name="Gohan"
		icon='gohan.dmi'
		oicon_state="gohan"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=28
		pl=6500
		basepl=6500
		special=/Beam/Masenko
		unlocked=alist("ssj"=1,"ssj2"=1)
		behaviors=list(25,25,10,10,30) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Masenko,new/Skill/Kamehameha,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["ssj"] && !src.form)
				src.icon_state="transform"
				sleep(6)
				src.icon='gohan_ssj.dmi'
				src.form="SSJ"
				src.icon_state=""
				src.Set_PL(round(src.basepl*4.2,1))
				src.Create_Aura("Yellow")
			else if(src.unlocked["ssj2"]&&src.form=="SSJ")
				src.icon_state="transform"
				sleep(8)
				src.icon='gohan_ssj2.dmi'
				src.form="SSJ2"
				src.icon_state=""
				src.Set_PL(round(src.basepl*6.4,1))
				src.vis_contents+=new/obj/personalelectricity
				src.Create_Aura("SSJ2")
			..()
		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='gohan.dmi'
				if(form=="SSJ2")
					for(var/obj/personalelectricity/E in src.vis_contents)src.vis_contents-=E
				src.form=null
				src.Create_Aura("White")

			..()

	tien
		name="Tienshinhan"
		icon='tien.dmi'
		oicon_state="tien"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Tribeam
		unlocked=alist("kaioken"=1)
		behaviors=list(15,5,30,10,45) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		Transform()
			if(src.unlocked["kaioken"])
				if(!form)
					src.Kaioken()
			..()
		Revert()
			if(form)
				src.Kaioken_end()
			..()
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Tribeam,new/Skill/Dondonpa,new/Skill/Solarflare,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	chaotzu
		name="Chaiotzu"
		icon='chaotzu.dmi'
		oicon_state="chaiotzu"
		icon_w=25
		icon_z=10
		bound_width=18
		bound_height=20
		pl=9000
		special=/Beam/Dondonpa
		behaviors=list(10,10,3,27,50) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Lightgreen")
			src.skills=list(new/Skill/Dondonpa,new/Skill/Spiritball,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	krillin
		name="Krillin"
		icon='krillin.dmi'
		oicon_state="krillin"
		icon_w=20
		icon_z=2
		bound_width=20
		bound_height=28
		pl=9000
		special=/Beam/Kamehameha
		unlocked=alist("kaioken"=1)
		behaviors=list(15,25,30,5,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Destructodisc,new/Skill/Kamehameha,new/Skill/Solarflare,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["kaioken"])
				if(!form)
					src.Kaioken()
			..()
		Revert()
			if(form)
				src.Kaioken_end()
			..()
	yamcha
		name="Yamcha"
		icon='yamcha.dmi'
		oicon_state="yamcha"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Kamehameha
		unlocked=alist("kaioken"=1)
		behaviors=list(15,5,50,10,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Spiritball,new/Skill/Wolffangfist,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]

		Transform()
			if(src.unlocked["kaioken"])
				if(!form)
					src.Kaioken()
			..()
		Revert()
			if(form)
				src.Kaioken_end()
			..()

	roshi
		name="Roshi"
		icon='roshi.dmi'
		oicon_state="roshi"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		flyinglevel=2
		special=/Beam/Kamehameha
		behaviors=list(10,10,20,10,50) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Spiritshot,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	trunks
		name="Trunks"
		icon='trunks.dmi'
		oicon_state="trunks"
		icon_w=32
		icon_z=0
		bound_width=24
		bound_height=28
		portrait_xoffset=-10
		pl=9000
		special=/Beam/Masenko
		kiblast=/obj/Kiblast/Sliceblast
		unlocked=alist("ssj"=1)
		behaviors=list(20,10,20,25,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Masenko,new/Skill/Burningattack,new/Skill/Kiblast/Slicing)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["ssj"] && !src.form)
				src.icon_state="transform"
				sleep(6)
				src.icon='trunks_ssj.dmi'
				src.form="SSJ"
				src.icon_state=""
				src.Set_PL(round(src.basepl*4.2,1))
				src.Create_Aura("Yellow")
			..()
		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='trunks.dmi'
				src.form=null
				src.Create_Aura("White")

			..()

	mrsatan
		name="Mr. Satan"
		icon='mrsatan.dmi'
		oicon_state="mrsatan"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=28
		portrait_xoffset=-10
		pl=45
		maxhp=1000
		hp=1000
		flyinglevel=0
		special=/Beam/Dondonpa
		kiblast=/obj/Kiblast/Gun
		behaviors=list(0,10,50,40,0) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("White")
			src.skills=list(new/Skill/Kiblast/Gun)
			src.equippedskill=src.skills[1]
	raditz
		name="Raditz"
		icon='raditz.dmi'
		oicon_state="raditz"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=9000
		special=/Beam/Doublesunday
		behaviors=list(10,40,20,10,20) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		unlocked=alist("ssj"=1)
		Transform()
			if(src.unlocked["ssj"])
				if(!form)
					src.icon_state="transform"
					sleep(6)
					src.icon='raditz_ssj.dmi'
					src.form="SSJ"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))
					src.Create_Aura("Yellow")
				else return
			..()


		Revert()
			if(form)
				src.icon_state="revert"
				sleep(5)
				src.icon_state=""
				src.Set_PL(src.basepl)
				src.icon='raditz.dmi'
				src.form=null
				src.Create_Aura("Purple")
			..()

		New()
			..()
			src.Create_Aura("Purple")
			src.skills=list(new/Skill/Doublesunday,new/Skill/Saturdaycrush,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	nappa
		name="Nappa"
		icon='nappa.dmi'
		oicon_state="nappa"
		icon_w=22
		icon_z=0
		bound_width=30
		bound_height=40
		portrait_yoffset=-15
		pl=9000
		special=/Beam/Mouthblast
		unlocked=new/alist("lightningarmor"=1)
		behaviors=list(10,25,30,5,30) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Lightyellow")
			src.skills=list(new/Skill/Explosivewave,new/Skill/Mouthblast,new/Skill/Energyblast,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["lightningarmor"])
				if(!form)
					src.icon_state="transform"
					src.Create_Aura("Lightningarmor")
					src.vis_contents|=src.aura
					src.vis_contents|=src.auraover
					src.aura.icon_state="start"
					src.auraover.icon_state="start"

					sleep(2)
					src.aura.icon_state="aura"
					src.auraover.icon_state="aura"
					sleep(4)
					src.form="lightningarmor"
					src.icon_state=""
					src.Set_PL(round(src.basepl*4.2,1))

					src.vis_contents+=new/obj/lightningarmor

					src.filters+=filter(type="outline",size=1,color=rgb(230,230,100))
					src.icon='nappa_lightning.dmi'
					src.aura.icon_state=""
					src.auraover.icon_state=""
					spawn(10)
						src.vis_contents-=src.aura
						src.vis_contents-=src.auraover
				else return
			..()


		Revert()
			if(form)
				src.Set_PL(src.basepl)
				src.form=null
				src.Create_Aura("Lightyellow")
				for(var/obj/lightningarmor/E in src.vis_contents)src.vis_contents-=E
				src.icon='nappa.dmi'
				src.filters=null
				sleep(5)
			..()
	cell
		name="Perfect Cell"
		icon='cell.dmi'
		oicon_state="cell"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=38000
		special=/Beam/Kamehameha
		unlocked=alist("celljr"=1)
		kiblast=/obj/Kiblast/Fingerlaser
		behaviors=list(5,35,25,10,25) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Yellow")

			src.skills=list(new/Skill/Kamehameha,new/Skill/Specialbeamcannon,new/Skill/Kiblast/Fingerlaser)
			src.equippedskill=src.skills[1]
		Transform()
			if(src.unlocked["celljr"])
				if(src.spawncount<6)
					src.spawncount++
					var/spl=round(src.pl/5,1)
					src.Set_PL(round(src.pl*4/5,1))
					src.icon_state="transform"
					src.canmove=0
					sleep(8)
					src.canmove=1
					var/mob/cjr=new/mob/celljr(bound_pixloc(src,0))
					cjr.team=src.team
					cjr.wanderrange=4
					cjr.aggrorange=1
					cjr.Set_PL(spl)
					src.spawnings+=cjr
					sleep(3)
					RefreshChunks|=cjr
					src.icon_state=""



	celljr
		name="Cell Jr."
		icon='celljr.dmi'
		oicon_state="celljr"
		icon_w=20
		icon_z=2
		portrait_yoffset=10
		bound_width=24
		bound_height=28
		pl=9000
		special=/Beam/Kamehameha
		behaviors=list(5,25,30,20,20) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Yellow")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Specialbeamcannon,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	reid
		name="Reid"
		icon='reidy.dmi'
		oicon_state="trunks"
		icon_w=20
		icon_z=2
		bound_width=24
		bound_height=38
		pl=25000
		flyinglevel=3
		special=/Beam/Kamehameha
		behaviors=list(10,10,20,10,50) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("SSJ2")
			src.skills=list(new/Skill/Kamehameha,new/Skill/Specialbeamcannon,new/Skill/Dragonfist,new/Skill/HellzoneGrenade,new/Skill/ExplosiveDemonWave,new/Skill/Pushup,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]
	saibamen
		name="Saibamen"
		oicon_state="saibamen"
		portrait_yoffset=10
		NPC
			team="Enemy"
			wanderrange=3
			aggrorange=1


		Cyan
			name="Saibamen (Cyan)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=90
			pl=4000
		Blue
			name="Saibamen (Blue)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=120
			pl=7000
		DarkBlue
			name="Saibamen (Dark Blue)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=150
			pl=10000

		Purple
			name="Saibamen (Purple)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=210
			pl=20000

		Magenta
			name="Saibamen (Magenta)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=255
			pl=35000
		Red
			name="Saibamen (Red)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=300
			pl=50000
		Orange
			name="Saibamen (Orange)"
			team="Enemy"
			wanderrange=3
			aggrorange=1
			hue=330
			pl=300

		icon='saibamen.dmi'

		icon_w=25
		icon_z=10
		bound_width=18
		bound_height=20
		maxhp=50
		hp=50
		pl=1100
		special=/Beam/Masenko
		behaviors=list(5,40,30,10,15) //1 charge to, 2 defend, 3 melee, 4 ki blasting, 5 special
		New()
			..()
			src.Create_Aura("Lightgreen")
			src.skills=list(new/Skill/Masenko,new/Skill/Kiblast)
			src.equippedskill=src.skills[1]

	var
		maxhp=100
		maxki=100
		ki=100
		team
		basepl=9000
	var/tmp
		mob/lastattacked
		mob/lastattackedby
		lasthostile
		dead=0
		special
		ap
		maxspeed=16
		minspeed=6
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
		maxautoblocks=0
		npcrespawn=0

	step_size = 8

	icon='goku.dmi'