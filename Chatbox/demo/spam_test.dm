
chatbox
	maxlines = 1000

mob
	verb
		spam_test(txt as text)
			var/chatlog
			for(var/client/client)
				chatlog = client.chatlog
				break
			for(var/client/client)
				client.chatlog = null
			for(var/i in 1 to 1000)
				_message(world,"spam: [txt] \c(255,125,0)([i])")
			for(var/client/client)
				client.chatlog = chatlog
