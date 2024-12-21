/*

====================
GLOBAL PROCS
====================

proc
	_message(recipient,msg,color,face)
		recipient: a mob, a client, a list, or world
		msg: a string
		color: font-color
		face: font-face

		- This will send <msg> to <recipient> with <color> as font-color and <face> as font-face.
			Note: If <color>/<face> is not supplied, the chatbox's <font_color>/<font_family> will take over.

	_ftext(text="",color,face)
		text: a string
		color: font-color
		face: font-face

		- Returns a formated <text> with <color> as font-color and <face> as font-face.


====================
CLIENT
====================

client
	var
		chatlog = null
		- A string pointing to an output/browser control where your chatbox messages will be logged.
			Note: If <chatlog> is null or there is no chatbox, messages won't be logged.


	- The following are procs for handling chatbox:

	proc
		chatbox_build()

			- Builds your chatbox and displays it in your screen

		chatbox_remove()

			- Destroys your chatbox

		chatbox_clear()

			- Clears your chatbox

		chatbox_show(setting=TRUE)
			setting: TRUE or FALSE

			- If setting is TRUE, show chatbox. If FALSE, hide chatbox.
				Note: This won't have any effect if there is no chatbox.


	- The following are procs for handling chatlog:

	proc
		chatlog_record(str)
			str: a string

			- Records <str> into your <chatlog>.
				Note: See client/var/chatlog for additional info.

		chatlog_clear()

			- Clears your <chatlog>
				Note: This won't have any effect if <chatlog> is null.


====================
CHATBOX
====================

chatbox
	- This is your chatbox. It inherits from /atom/movable and uses maptext for displaying text. Modify its variables to suit your needs.
		Note: It is automatically created and destroyed via client/proc/chatbox_build and client/proc/chatbox_remove.

	- The following are important variables inherited from /atom/movable and their default values.

	var
		screen_loc = "1:16,1:16"
		maptext_height = 128
		maptext_width = 256
		layer = FLY_LAYER+1
		mouse_opacity = 0

	- Additional variables are the following:

	var
		maxlines = 8
		- This is the maximum lines (messages) logged in your chatbox.

		chatlines = 8
		- This is the maximum lines (messages) displayed in your chatbox.
			Note: The actual display is limited by the chatbox's <maptext_width> and <maptext_height>

		font_family
		- Font-family of your chatbox's text

		font_color
		- Font-color of your chatbox's text

		font_size
		- Font-size of your chatbox's text

		text_shadow
		- Color of the messages' shadow

====================
CHATBOX GUI
====================

chatbox_gui
	- The following are the gui of your chatbox. They inherit from /atom/movable. Modify their variables to suit your needs.
		Note: They are automatically created and destroyed via client/proc/chatbox_build and client/proc/chatbox_remove.

	background
	- The background of your chatbox.

	start
	- Start button. On click, it scrolls your chatbox's messages to the first message recorded.

	up
	- Up button. On click, it scrolls you chatbox's messages up.

	down
	- Down button. On click, it scrolls you chatbox's messages down.

	end
	- End button. On click, it scrolls your chatbox's messages to the last message recorded.



	- The following are important variables inherited from /atom/movable and their default values.

	var
		icon
		icon_state
		screen_loc
		mouse_opacity = 1
		layer = FLY_LAYER


====================
IMPLEMENTATION
====================

See demo.dm under the demo folder.

*/