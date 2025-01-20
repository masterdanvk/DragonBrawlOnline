/*
Controls are based on the interface having one major verb called for ANY key pressed (keydownverb) and for ANY key released (keyupverb).
If a key is detected to be a gamepad key, its run through GamePad2Key and will swap that key with the corresponding keyboard equivalent.

*/


mob/proc/Next_Skill()

	var/cur=1
	for(var/i=1 to src.skills.len)
		if(src.skills[i]==src.equippedskill)
			cur=i
	cur++
	if(cur>src.skills.len)cur=1
	src.equippedskill=src.skills[cur]
	src.client?.updateskillbar()

mob/proc/Prev_Skill()
	var/cur=1
	for(var/i=1 to src.skills.len)
		if(src.skills[i]==src.equippedskill)
			cur=i
	cur--
	if(cur<=0)cur=src.skills.len
	src.equippedskill=src.skills[cur]
	src.client?.updateskillbar()

client/proc/GamePad2Key(button, keydown)
	var/b
	switch(button)
		if("GamepadFace1","Gamepad2Face1")b="D"
		if("GamepadFace2","Gamepad2Face2")b="A"
		if("GamepadFace3","Gamepad2Face3")b="F"
		if("GamepadFace4","Gamepad2Face4")b="S"

		if("GamepadL1","Gamepad2L1")b="Q"
		if("GamepadR1","Gamepad2R1")b="W"
		if("GamepadL2","Gamepad2L1")b="-"
		if("GamepadR2","Gamepad2R1")b="="
		if("GamepadLeft","Gamepad2Left")b="West"
		if("GamepadRight","Gamepad2Right")b="East"
		if("GamepadUp","Gamepad2Up")b="North"
		if("GamepadDown","Gamepad2Down")b="South"
		if("GamepadSelect","Gamepad2Select")b="Escape"
		if("GamepadUpLeft","Gamepad2UpLeft")b="Northwest"
		if("GamepadDownLeft","Gamepad2DownLeft")b="Southwest"
		if("GamepadUpRight","Gamepad2UpRight")b="Northeast"
		if("GamepadDownRight","Gamepad2DownRight")b="Southeast"

	if(b)
		if(!src.keydown)src.keydown=new/alist()
		spawn()
			if(keydown)//&&!src.keydown[b])
				src.keydownverb(b)
			else if(b&&src.keydown[b])
				src.keyupverb(b)
client/var/dashkey
client/var/lasttapped[2]
client/verb/keydownverb(button as text)
	set instant=1
	set hidden = 1


	//if the user has a focus target, call onKeyDown() on the focus target.
	//if the object returns null or 0 (or doesn't return anything), stop this input from propagating further.
	//the focus target can return a true value with some or no keys to allow this input to propagate.
	if(src.indialogue)
		if(button=="South"||button=="East"||button=="GamepadRight"||button=="GamepadDown")
			src.NextChoice()
		else if(button=="North"||button=="West"||button=="GamepadLeft"||button=="GamepadUp")
			src.PrevChoice()
		return
	if(src.pickinglevel)
		switch(button)
			if("North","GamepadUp")src.Navigate(NORTH)
			if("South","GamepadDown")src.Navigate(SOUTH)
			if("East","GamepadRight")src.Navigate(EAST)
			if("West","GamepadLeft")src.Navigate(WEST)
			if("NorthEast","GamepadUpRight")src.Navigate(NORTHEAST)
			if("SouthEast","GamepadDownRight")src.Navigate(SOUTHEAST)
			if("NorthWest","GamepadRight")src.Navigate(NORTHWEST)
			if("SouthWest","GamepadLeft")src.Navigate(SOUTHWEST)
		return

	if(focus_target && !focus_target.onKeyDown(button))
	//	world.log<<button
		return
//	world.log<<button
	if(button=="GamepadR3")
		src.SayGamepad()
		return
	if(button=="GamepadSelect"||button=="Gamepad2Select"||button=="GamepadFace1"||button=="GamepadFace2"||button=="GamepadFace3"||button=="GamepadFace4"||button=="GamepadL1"||button=="GamepadR1"||button=="GamepadL2"||button=="GamepadR2"||button=="GamepadLeft"||button=="GamepadRight"||button=="GamepadUp"||button=="GamepadDown"||button=="GamepadUpLeft"||button=="GamepadDownLeft"||button=="GamepadUpRight"||button=="GamepadDownRight"||button=="Gamepad2Face1"||button=="Gamepad2Face2"||button=="Gamepad2Face3"||button=="Gamepad2Face4"||button=="Gamepad2L1"||button=="Gamepad2R1"||button=="Gamepad2L2"||button=="Gamepad2R2"||button=="Gamepad2Left"||button=="Gamepad2Right"||button=="Gamepad2Up"||button=="Gamepad2Down"||button=="Gamepad2UpLeft"||button=="Gamepad2DownLeft"||button=="Gamepad2UpRight"||button=="Gamepad2DownRight")
	//	world<<"[button] passed to GamePad2Key"
		src.GamePad2Key(button,1)
		return
	var/mob/M=src.mob

	if(M.selecting)
		src.SelectingInput(button)
		return
	if(M.dead||M.icon_state=="transform")return
	if(!src.keydown)src.keydown=new/alist()

	if((src.keydown["D"]&&button=="S")||button=="="&&!src.overworld&&!src.mob.usingskill)
		M.Transform()
		return
	var/tapbetween
	if(src.lasttapped[1]==button)
		tapbetween=world.time-src.lasttapped[2]


	if(M.stunned&&M.stunned>world.time)
		return
	else
		if(M.stunned)M.stunned=0
	src.keydown[button]=world.time

	var/starttime=world.time

	src.lasttapped[1]=button
	src.lasttapped[2]=world.time
	if((src.keydown["D"]&&src.keydown["South"]&&M.form&&!src.movekeydown)||button=="-"&&!src.overworld&&!src.mob.usingskill)
		M.Revert()
	if((src.keydown["F"]||(src.keydown["D"]&&src.keydown["North"]))&&world.time>M.chargecd&&!src.overworld&&!src.mob.usingskill) //charge
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
		if(button=="D"&&!M.dead&&!src.overworld&&!src.mob.usingskill)
			M.icon_state="block"
			M.block=1
			M.canmove=0
			M.blocktime=world.time

	if(button=="S"&&M.canmove&&!M.block&&!M.usingskill&&!M.charging&&!src.overworld)
		var/chargestate=M.equippedskill?.state1
		if((chargestate in icon_states(M.icon)))
			M.icon_state=chargestate
		else M.icon_state="blast1"
		M.canmove=0
		M.movevector=vector(0,0)

		M.gui_charge.setValue(0)
		var/atom/Veye=src.virtual_eye
		var/mob/Eye=src.eye
		if(M.counterbeam&&M.counterbeam==M)
			M.counterbeam=null

		if(M.counterbeam&&M.equippedskill && M.equippedskill.counters)
			M.aim=M.counterbeam.pixloc-M.pixloc
			M.ChargeSkill()
			M.UseSkill(0)
			M.aiming=0

		//	src.HideAim()
			return
		else
			M.aiming=1
			if(M.facing&&M.facing.size)M.aim=vector(M.facing)
			else
				M.aim=vector(0,0)
			if(Eye!=Veye)
				var/offx=(Eye.x-Veye.x)*32+round(Eye.step_x,1)-4
				var/offy=(Eye.y-Veye.y)*32+round(Eye.step_y,1)-32
				if(offx>0)offx="+[offx]"
				else offx="[offx]"
				if(offy>0)offy="+[offy]"
				else offy="[offy]"
				M.gui_charge.screen_loc="CENTER:[offx] ,CENTER:[offy]"

			else
				M.gui_charge.screen_loc="CENTER ,CENTER:-16"

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
		if(tapbetween&&tapbetween<=2&&M.counters>=1&&!M.aiming) //doubletap!
			src.dashkey=button
			M.counters--
			M.Update_Counters()
			spawn(world.tick_lag)M.Charge()


	if(M)activemobs|=M

client/verb/keyupverb(button as text)
	set hidden = 1
	set instant=1

	//if the user has a focus target, call onKeyUp() on the focus target.
	//if the object returns null or 0 (or doesn't return anything), stop this input from propagating further.
	//the focus target can return a true value with some or no keys to allow this input to propagate.
	if(src.indialogue)

		if(button=="A"||button=="GamepadFace2"||button=="Enter"||button=="Space")
			src.MakeChoice()
		return
	if(src.pickinglevel)
		if(button=="A"||button=="GamepadFace2"||button=="Enter"||button=="Space")
			src.Select()
		return

	if(focus_target && !focus_target.onKeyUp(button))
		return
	if(button=="GamepadSelect"||button=="Gamepad2Select"||button=="GamepadFace1"||button=="GamepadFace2"||button=="GamepadFace3"||button=="GamepadFace4"||button=="GamepadL1"||button=="GamepadR1"||button=="GamepadLeft"||button=="GamepadRight"||button=="GamepadUp"||button=="GamepadDown"||button=="GamepadUpLeft"||button=="GamepadDownLeft"||button=="GamepadUpRight"||button=="GamepadDownRight"||button=="Gamepad2Face1"||button=="Gamepad2Face2"||button=="Gamepad2Face3"||button=="Gamepad2Face4"||button=="Gamepad2L1"||button=="Gamepad2R1"||button=="Gamepad2Left"||button=="Gamepad2Right"||button=="Gamepad2Up"||button=="Gamepad2Down"||button=="Gamepad2UpLeft"||button=="Gamepad2DownLeft"||button=="Gamepad2UpRight"||button=="Gamepad2DownRight")
		src.GamePad2Key(button,0)
		return
	var/mob/M=src.mob
	if(M.stunned&&M.stunned>world.time)
		if(src.keydown[button])
			sleep(M.stunned-world.time)
		else
			return
	else
		if(M.stunned)M.stunned=0

	if(button==src.dashkey)
		M.Chargestop()
		src.dashkey=null
	if(M.selecting)
		return
	if(button=="Escape")
		if(src.oworldpixloc)src.VisitOverworld()
		else M.ChangePlayer()
		return
	if(M.dead)
		return
	var/i=0
	while(M.icon_state=="transform"&&i<20)
		i++
		sleep(1)


	if(button=="W"&&!src.keydown["S"])M.Next_Skill()
	else if(button=="Q"&&!src.keydown["S"])M.Prev_Skill()
	if(!src.overworld &&!src.mob.usingskill)
		if(button=="A")

			var/duration=world.time-src.keydown[button]
			if(!M.usingskill)M.Melee(duration)

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
			if(M.storedblock>=3)M.Repulse(min(160,M.storedblock*16))
			M.storedblock=0

		if(button=="S" && !M.usingskill &&src.keydown["S"])
			M.aiming=0
			src.HideAim()
			var/skilltime=world.time-src.keydown[button]
			src.screen-=M.gui_charge
			if(!M.equippedskill)M.equippedskill=M.skills[1]
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
			if(!M.dead)M.icon_state=""
	else
		if(button=="A")
			var/turf/T=get_step(src.mob,src.mob.dir)
			for(var/obj/overworld/O in T)
				O.Activate(M)
				return
			for(var/obj/overworld/O in view(1,T))
				O.Activate(M)
				return
			for(var/obj/overworld/O in view(2,T))
				O.Activate(M)
				return
			for(var/mob/O in view(2,T))
				if(O!=src.mob && O.client)
					src.Talkto(O.client)

					return
	src.keydown?.Remove(button)


	if(button=="North"||button=="South"||button=="East"||button=="West"||button=="Northeast"||button=="Southeast"||button=="Northwest"||button=="Southwest")
		src.UpdateMoveVector()
		if(!(src.keydown["North"]||src.keydown["South"]||src.keydown["East"]||src.keydown["West"]||src.keydown["Northeast"]||src.keydown["Southeast"]||src.keydown["Northwest"]||src.keydown["Southwest"]))
			src.movekeydown=0
			if(M.dashing)
				M.Chargestop()
				src.dashkey=null
	if(length(src.keydown)==0 && (!M.movevector || M.movevector.size<=1)) activemobs-=M