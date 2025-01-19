#ifndef TILE_WIDTH
#define TILE_WIDTH 32
#endif

#ifndef TILE_HEIGHT
#define TILE_HEIGHT 32
#endif

client
	var tmp
		clean_map_scaling/clean_map_scaling

	proc
		CleanMapScaling_OnResize()
			clean_map_scaling && clean_map_scaling.OnResize()

clean_map_scaling
	var tmp
		client/client // the client that this is currently working with

		map_id = ":map" // defaults to default map but can be changed

		_zoom // the current zoom that this tried to set the map

		_raw_view_size // compared for changes

		// sizes in pixels
		_view_size[]
		_map_size[]

	New(Client)
		client = Client
		client.clean_map_scaling = src
		_view_size = new (2)
		_map_size = new (2)
		OnResize()

	proc
		OnResize()

			// sync map element size (change assumed) and client view size (if changed)
			_ParseSizeText(winget(client, map_id, "size"), _map_size)

			var/xratio=round(_map_size[1]/_map_size[2]*15,1)
		//	world<<"resized [_map_size[1]] [_map_size[2]] xratio [xratio]"
			client.view = "[xratio]x15" //bit of custom code - I did bastardize this library Kaio, sorry,
			if(_raw_view_size != client.view)
				_raw_view_size = client.view
				if(istext(client.view)) _ParseSizeText(client.view, _view_size)
				else if(isnum(client.view)) _ParseSizeNumber(client.view, _view_size)
				else throw EXCEPTION("Invalid view size: [client.view]")

			// calculate best-fit map zoom and apply it
			if(_map_size[1] <= _map_size[2])
				_zoom = round(_map_size[1] / (TILE_WIDTH * _view_size[1]),0.01) //I allowed this to be non integer, aka not rounded. removing the ,0.01 would change it back.
			else _zoom = round(_map_size[2] / (TILE_HEIGHT * _view_size[2]),0.01)

			winset(client, map_id, "zoom=[_zoom]")


		_ParseSizeText(Text, Out[]) // [X]x[Y]
			if(Out) Out.len = 2
			else Out = new (2)
			Out[1] = text2num(Text)
			Out[2] = text2num(copytext(Text, 2 + length("[Out[1]]")))
			return Out

		_ParseSizeNumber(Number, Out[]) // 5 => 11x11
			if(Out) Out.len = 2
			else Out = new (2)
			Out[1] = 1 + 2 * Number
			Out[2] = Out[1]
			return Out


client
	New()
		. = ..()

		// attach a new clean_map_scaling component to this client
		new /clean_map_scaling (src)

	verb
		map_resized()
			set hidden = TRUE

			// in your skin editor, the map element should have a "Resize command"
			// that calls this function:
			CleanMapScaling_OnResize()