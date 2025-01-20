/*
Instances are missions or prefilled battles where mobs and levels are associated to the Instance datum. inflexibleteam2 is set to 1 when you dont want
it to be possible to change the enemy team's composition.
Instances are called into the battlegui.dm process to load a scenario to the battlegui, and then when that has been set up with playesr and customizations,
once the start button on the gui is pressed the players, mobs and instances are passed to Battle.dm where an instanced fight takes place.

It is possible for an Instance, in its New() routine, to spawn() behavior that listens for the death status of specific mobs, or uses timers to have additional
events take place. Just be wary that Instances will be called to New() when the battlegui is pulled on screen, NOT when the fight begins. It would be better then to set up
a new proc for Instances when the fight starts, and call that in Battle.dm instead for weird custom behaviors on fights.
*/

Instance
	var/list/bench1[]
	var/list/bench2[]
	var/stage
	var/list/players[8]
	var/charslots[8][7]
	var/inflexibleteam2=0
	Custom
	Budokai23
		inflexibleteam2=1
		New()
			..()
			stage=stagezs["Budokai"]
			charslots[1][1]=new/mob/goku(,alist(pl=325,hp=200,unlocked=alist("none"=1),skills=list(new/Skill/Kamehameha,new/Skill/Spiritshot,new/Skill/Kiblast)))
			charslots[5][1]=new/mob/chaotzu(,alist(pl=130,hp=100))
			charslots[5][2]=new/mob/yamcha(,alist(pl=180,hp=100))
			charslots[5][3]=new/mob/krillin(,alist(pl=190,hp=100))
			charslots[5][4]=new/mob/tien(,alist(pl=225,hp=150))
			charslots[5][5]=new/mob/piccolo(,alist(pl=325,hp=200,unlocked=alist("none"=1)))

	Raditz
		inflexibleteam2=1
		New()
			..()
			stage=stagezs["Raditz"]
			charslots[1][1]=new/mob/goku(,alist(pl=416,hp=300,unlocked=alist("none"=1),skills=list(new/Skill/Kamehameha,new/Skill/Spiritshot,new/Skill/Kiblast)))
			charslots[2][1]=new/mob/piccolo(,alist(pl=408,hp=300,unlocked=alist("none"=1)))
			charslots[5][1]=new/mob/raditz(,alist(pl=1500,hp=400))

	Nappa
		inflexibleteam2=1
		New()
			..()
			stage=stagezs["Plains"]
			bench1=list(
				new/mob/yamcha(,alist(pl=1480,hp=200,unlocked=alist("none"=1))),
				new/mob/krillin(,alist(pl=1770,hp=200,unlocked=alist("none"=1))),
				new/mob/tien(,alist(pl=1830,hp=200,unlocked=alist("none"=1))),
				new/mob/gohan(,alist(pl=981,hp=200,unlocked=alist("none"=1))),
				new/mob/chaotzu(,alist(pl=610,hp=200,unlocked=alist("none"=1))),
				new/mob/piccolo(,alist(pl=3500,hp=200,unlocked=alist("none"=1))),
				new/mob/goku(,alist(pl=9001,hp=200,unlocked=alist("kaiokenx2"=1))))
			charslots[5][1]=new/mob/saibamen(,alist(pl=1100,hp=100))
			charslots[5][2]=new/mob/saibamen(,alist(pl=1100,hp=100))
			charslots[5][3]=new/mob/saibamen(,alist(pl=1100,hp=100))
			charslots[6][3]=new/mob/saibamen(,alist(pl=1100,hp=100))
			charslots[7][3]=new/mob/saibamen(,alist(pl=1100,hp=100))
			charslots[8][3]=new/mob/saibamen(,alist(pl=1100,hp=100))
			charslots[5][4]=new/mob/nappa(,alist(pl=4000,hp=500))
	Vegeta
		inflexibleteam2=1
		New()
			..()
			stage=stagezs["Plateaus"]
			bench1=list(
,				new/mob/krillin(,alist(pl=1770,hp=200,unlocked=alist("none"=1))),
				new/mob/gohan(,alist(pl=2800,hp=200,unlocked=alist("none"=1))))
			charslots[1][1]=new/mob/goku(,alist(pl=9001,hp=400,unlocked=alist("kaiokenx2"=1)))
			charslots[5][1]=new/mob/vegeta(,alist(pl=18000,hp=400))