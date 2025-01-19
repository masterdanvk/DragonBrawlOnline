
proc
	_ftext(text="",color,face)
		if(color||face)
			text="<font[color ? " color='[color]'" : ][face ? " face='[face]'" : ]>[text]</font>"
		return text

	_message(recipient,msg,color,face)
		if(!recipient)
			return // early escape
		if(istype(recipient,/mob))
			if(!recipient:client) // no client
				return // early escape
			_message(recipient:client,msg,color,face)
			return
		if(istype(recipient,/client))
			var/client/client = recipient
			if(!client._chatbox) // no chatbox
				return // early escape
			var/chatbox_msg/chatbox_msg = msg
			if(!istype(msg,/chatbox_msg))
				chatbox_msg = new/chatbox_msg(msg,color,face)
			client._chatbox._enter(chatbox_msg)
			client.chatlog_record(chatbox_msg.text)
			return
		if(istype(recipient,/list))
			if(!length(recipient)) // empty list
				return // early escape
			if(!istype(msg,/chatbox_msg))
				msg = new/chatbox_msg(msg,color,face)
			for(var/mob/mob in recipient)
				if(mob.client)
					_message(mob.client,msg)
			for(var/client/client in recipient)
				_message(client,msg)
			return
		if(istype(recipient,world))
			if(!istype(msg,/chatbox_msg))
				msg = new/chatbox_msg(msg,color,face)
			for(var/client/client)
				_message(client,msg)
			return
