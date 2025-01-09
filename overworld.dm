mob/var
	oicon='rpg/rpg.dmi'
	oicon_state
	oicon_w
	oicon_z
	obound_width
	obound_height
client/verb/VisitOverworld()
	if(src.overworld)return
	src.overworld=1
	src.mob.omaxspeed=src.mob.maxspeed
	src.mob.maxspeed=4
	src.mob.oicon_w=src.mob.icon_w
	src.mob.oicon_z=src.mob.icon_z
	src.mob.obound_width=src.mob.bound_width
	src.mob.obound_height=src.mob.bound_height
	src.mob.icon_w=-4
	src.mob.icon_z=0
	src.mob.bound_width=24
	src.mob.bound_height=24
	src.mob.resetactions()
	src.edge_limit = null
	src.mob.bicon=src.mob.icon

	src.mob.icon=src.mob.oicon
	src.mob.icon_state=src.mob.oicon_state
	src.mob.movevector=vector(0,0)
	src.mob.transform=null
	if(!src.oworldpixloc)src.mob.loc=locate(/obj/overworldstart)
	else
		src.mob.loc=src.oworldpixloc

	for(var/obj/nameplate/N in src.mob.vis_contents)
		N.pixel_w=-32

mob/proc/resetactions()
	if(src.charging)
		src.charging=0
		src.aura.icon_state="none"
		src.auraover.icon_state="none"
		src.vis_contents-=src.aura
		src.vis_contents-=src.auraover
	if(src.block)
		src.block=0
		src.storedblock=0
	src.CheckCanMove()

client/proc/LeaveOverworld()
	if(!src.overworld)return
	src.overworld=0
	src.mob.icon_w=src.mob.oicon_w
	src.mob.icon_z=src.mob.oicon_z
	src.mob.bound_width=src.mob.obound_width
	src.mob.bound_height=src.mob.obound_height
	src.oworldpixloc=src.mob.pixloc
	src.mob.icon=src.mob.bicon
	src.mob.maxspeed=src.mob.omaxspeed
	src.mob.icon_state=""
	for(var/obj/nameplate/N in src.mob.vis_contents)
		N.pixel_w=-36

obj/overworldstart
client/var/overworld=0
client/var/pixloc/oworldpixloc
mob/var
	flying=0
	ostate=""
	bicon
	omaxspeed

obj
	overworld
		proc/Activate(mob/M)
		roshi_training
			icon='rpg/rpg.dmi'
			icon_state="roshi"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Master Roshi","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/roshi,stagezs["Kamehouse"],1)
		krillin_training
			icon='rpg/rpg.dmi'
			icon_state="krillin"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Krillin","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/krillin,stagezs["Kamehouse"],1)

		chaiotzu_training
			icon='rpg/rpg.dmi'
			icon_state="chaiotzu"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Chaiotzu","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/chaotzu,stagezs["Mountain"],1)
		cell_training
			icon='rpg/rpg.dmi'
			icon_state="cell"
			density=1
			Activate(mob/M)
				M.client?.LeaveOverworld()
				Fight(M,new/mob/cell,stagezs["Cellgames"],1)

		tien_training
			icon='rpg/rpg.dmi'
			icon_state="tien"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Tien","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/tien,stagezs["Mountain"],1)
		yamcha_training
			icon='rpg/rpg.dmi'
			icon_state="yamcha"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Yamcha","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/yamcha,stagezs["Rockydesert"],1)
		satan_training
			icon='rpg/rpg.dmi'
			icon_state="mrsatan"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Mr. Satan","What? Do you want an autograph or are you looking to challenge the champ?!.",list("Challenge","Autograph","Leave"))
					switch(choice)
						if("Challenge")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/mrsatan,stagezs["Budokai"],1)
		goku_training
			icon='rpg/rpg.dmi'
			icon_state="goku"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Goku","Hello, are you looking for a training partner?.",list("Train with me","Train with me somewhere else","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/goku,stagezs["Plains"],1)
						if("Train with me somewhere else")

							M.client?.PVP(new/mob/goku)

		gohan_training
			icon='rpg/rpg.dmi'
			icon_state="gohan"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Gohan","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/gohan,stagezs["Plains"],1)


		piccolo_training
			icon='rpg/rpg.dmi'
			icon_state="piccolo"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Piccolo","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/piccolo,stagezs["Plains"],1)

		vegeta_training
			icon='rpg/rpg.dmi'
			icon_state="vegeta"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Vegeta","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/vegeta,stagezs["Plateaus"],1)
		nappa_training
			icon='rpg/rpg.dmi'
			icon_state="nappa"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Nappa","Hello, are you looking for a training partner?.",list("Historic Battle","Train with me","Leave"))
					switch(choice)
						if("Historic Battle")
							M.client?.Battlegui()

						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/nappa,stagezs["Rockydesert"],1)
		raditz_training
			icon='rpg/rpg.dmi'
			icon_state="raditz"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Raditz","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/raditz,stagezs["Raditz"],1)
		trunks_training
			icon='rpg/rpg.dmi'
			icon_state="trunks"
			density=1
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Trunks","Hello, are you looking for a training partner?.",list("Train with me","Leave"))
					switch(choice)
						if("Train with me")
							M.client?.LeaveOverworld()
							Fight(M,new/mob/trunks,stagezs["Roadside"],1)


		kamehouse
			icon='rpg/overworldlocs.dmi'
			icon_state="kamehouse"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Kamehouse"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Kamehouse"])
				M.client?.edge_limit = stage.dimensions
		pod
			icon='rpg/overworldlocs.dmi'
			icon_state="pod"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Raditz"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Raditz"])
				M.client?.edge_limit = stage.dimensions
		cellgames
			icon='rpg/overworldlocs.dmi'
			icon_state="cellgames"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Cellgames"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Cellgames"])
				M.client?.edge_limit = stage.dimensions
		budokai
			icon='rpg/overworldlocs.dmi'
			icon_state="budokai"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Budokai"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Budokai"])
				M.client?.edge_limit = stage.dimensions
		city
			icon='rpg/overworldlocs.dmi'
			icon_state="city"
			density=1
			bound_width=41
			bound_height=62
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["City"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["City"])
				M.client?.edge_limit = stage.dimensions

		ccpod
			icon='rpg/overworldlocs.dmi'
			icon_state="ccpod"
			density=1
			bound_width=41
			bound_height=32

			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Namek"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Namek"])
				M.client?.edge_limit = stage.dimensions
		yamchahideout
			icon='rpg/overworldlocs.dmi'
			icon_state="yamcha"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
		baba
			icon='rpg/overworldlocs.dmi'
			icon_state="baba"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
		lookout
			icon='rpg/overworldlocs.dmi'
			icon_state="lookout"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				var/obj/stagetag/stage=stageobjs[stagezs["Lookout"]]
				M.loc=locate(stage.Start.x,stage.Start.y,stagezs["Lookout"])
				M.client?.edge_limit = stage.dimensions
		capsulecorp
			icon='rpg/overworldlocs.dmi'
			icon_state="capsulecorp"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				usr.client?.Customfight()
		gokushouse
			icon='rpg/overworldlocs.dmi'
			icon_state="gokushouse"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
		pilafscastle
			icon='rpg/overworldlocs.dmi'
			icon_state="pilafscastle"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				M.client?.LeaveOverworld()
				M.loc=locate(rand(10,90),rand(10,90),1)
				M.client?.edge_limit = null
		redribbonbase
			icon='rpg/overworldlocs.dmi'
			icon_state="rr1"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
		grandpagohans
			icon='rpg/overworldlocs.dmi'
			icon_state="grandpagohans"
			density=1
			bound_width=41
			bound_height=32
			bound_x=0
			Activate(mob/M)
				if(M.client)
					var/choice=M.client.ShowDialogue("Grandpa Gohan's House","You visit Grandpa Gohan's house. It hasnt been lived in for some time.",list("Rest","Leave"))
					switch(choice)
						if("Rest")
							M.Heal(100)
							M.Get_Ki(100)