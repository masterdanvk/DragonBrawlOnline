world
	fps = 40
	icon_size = 32
	view = "31x17"
	maxx = 100
	maxy = 100
	maxz = 1

mob
	icon = 'test.dmi'
	var
		health = 1
		obj/maskbar/bartest
		obj/maskbar/bartest2
		obj/maskbar/bartest3
		obj/maskbar/bartest4

	Login()
		loc = locate(50,50,1)
		bartest = new/obj/maskbar/test()
		bartest2 = new/obj/maskbar/test2()
		bartest3 = new/obj/maskbar/test3()
		bartest4 = new/obj/maskbar/test4()
		client.screen.Add(bartest,bartest2,bartest3,bartest4)
		..()

	Move()
		return 0

client
	Click()
		mob.health = !mob.health
		mob.bartest.setValue(mob.health,10)
		mob.bartest2.setValue(mob.health,10)
		mob.bartest3.setValue(mob.health,10)
		mob.bartest4.setValue(mob.health,10)

turf
	icon = 'test.dmi'
	icon_state = "turf"

obj/maskbar/test
	icon = 'bartest.dmi'
	screen_loc = "CENTER:-81,CENTER"
	width = 162
	height = 5
	orientation = EAST

obj/maskbar/test3
	icon = 'bartest.dmi'
	screen_loc = "CENTER:-81,CENTER:-14"
	width = 162
	height = 5
	orientation = WEST

obj/maskbar/test2
	icon = 'bartest2.dmi'
	screen_loc = "CENTER:-50,CENTER:14"
	width = 40
	height = 38
	orientation = NORTH

obj/maskbar/test4
	icon = 'bartest2.dmi'
	screen_loc = "CENTER:0,CENTER:14"
	width = 40
	height = 38
	orientation = SOUTH