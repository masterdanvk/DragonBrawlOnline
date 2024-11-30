obj
	var
		destructible=0
	Tree
		icon='tree.dmi'
		density=1
		destructible=1
		bound_x=37
		bound_y=9
		bound_width=15
		bound_height=22




		Tree1
			icon_state="stump1"
			Destroy_Landscape()
				if(destructible)
					altered_objects|=src
					Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
					src.density=0
					animate(src,alpha=0,time=5)
					spawn(5)
						if(src.loc)src.old_loc=src.loc
						src.loc=null
						src.alpha=255
						src.density=1
			New()
				..()
				if(FX&&FX["obj/Tree/Treetop1"]) src.vis_contents+=FX["obj/Tree/Treetop1"]
				else
					if(!FX)FX=new/alist
					FX["obj/Tree/Treetop1"]=new/obj/Tree/Treetop1
					src.vis_contents+=FX["obj/Tree/Treetop1"]
		Tree2
			icon_state="stump2"
			Destroy_Landscape()
				if(destructible)
					altered_objects|=src
					Explosion(/obj/FX/Explosion,bound_pixloc(src,0))
					src.density=0
					animate(src,alpha=0,time=5)
					spawn(5)
						src.old_loc=src.loc
						src.loc=null
						src.alpha=255
						src.density=1
			New()
				..()
				if(FX&&FX["obj/Tree/Treetop2"]) src.vis_contents+=FX["obj/Tree/Treetop2"]
				else
					if(!FX)FX=new/alist
					FX["obj/Tree/Treetop2"]=new/obj/Tree/Treetop2
					src.vis_contents+=FX["obj/Tree/Treetop2"]
		Treetop1
			layer=MOB_LAYER+0.1
			icon='tree1.dmi'
			icon_z=-26

		Treetop2
			layer=MOB_LAYER+0.1
			icon='tree2.dmi'
			icon_z=-14
			icon_w=3
