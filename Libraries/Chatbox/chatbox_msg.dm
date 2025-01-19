
chatbox_msg
	var
		text

	New(text="",color,face)
		src.text = _format(text,color,face)

	proc
		_format(text="",color,face)
			return "<font[color ? " color='[color]'" : ][face ? " face='[face]'" : ]>[_parse(text)]</font>"

		_parse(text)
			text = "[text]"||" "
			if(length(text)>1 && copytext(text,-2)=="\c")
				text = copytext(text,1,-2)
			return text

chatbox_msgs
	var
		len = 0
		start = 0
		list/list

	New(x)
		list = new( isnum(x) && x )

	proc
		Add(chatbox_msg/msg)
			if(list.len)
				var/pos = pos(start+len+1)
				list[pos] = msg
				if(len < list.len)
					len++
				else
					start = pos(start+1)

		Get(pos)
			return list[ pos(start+pos) ]

		Clear()
			for(var/i in 1 to list.len)
				list[i] = null
			len = 0

		pos(pos)
			return pos%list.len || list.len
