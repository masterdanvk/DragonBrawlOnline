
mob/admin/verb/MakeShiny(mob/M in view(10))

	if(M.shiny)
		M.shiny=0
		M.color=null
	else M.shiny()

mob/admin/verb/ChangeHue(mob/M in view(10))
	var/hueshift=input(usr,"Set a hue shift from 0 to 360","Hue") as num
	M.hue=hueshift
	M.filters=null
	M.filters += filter(
		type = "color",
		space = FILTER_COLOR_HSV,
	 	color = list(1,0,0, 0,1,0, 0,0,1, M.hue/360,0,0)
	 	)

mob/admin/verb/SaibamenSeeding(var/n as num)
	set background = 1
	var/e=0
	for(var/i=1 to n)
		var/mob/M=new/mob/saibamen/NPC(locate(rand(10,90),rand(10,90),1))
		RefreshChunks|=M
		e++
		if(e>=50)
			sleep(1)
			e=0

mob/admin/verb/Check_Vars()
	world<<"usingskill [usingskill] aiming [aiming] canmove [canmove] chargin [charging] bouncing [bouncing] tossed [tossed] attacking [attacking] block[block]"
	world<<"mybeam [mybeam] mybeam.clash [mybeam?.clash] mybeam.head [mybeam?.head]"

mob/admin/verb/firebeams()

	sleep(10)

	world<<"fire!"

	for(var/mob/M in oview(20,usr))
		if(!M.client)
			M.aim=Dir2Vector(M.dir)
			for(var/mob/m in oview(14,M))
				if(m.client)
					M.aim=m.pixloc-M.pixloc

			spawn()M.FireBeam(50,500,new M.special)

mob/admin/verb/change_powerlevel(var/p=src.pl as num)
	src.Set_PL(p)

mob/admin/verb/Levelupflying()
	var/mob/M=usr
	M.flyinglevel++
	if(M.flyinglevel>3)M.flyinglevel=0
	world.log<<"flying level is now [M.flyinglevel]"