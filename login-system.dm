// UI Window base type
/obj/screen/window
    var/target_x = 0
    var/target_y = 0
    var/slide_speed = 2
    var/is_sliding = FALSE
    var/fade_amount = 0
    mouse_opacity = 2
    
    proc/slide_to(nx, ny, speed = 2)
        target_x = nx
        target_y = ny
        slide_speed = speed
        is_sliding = TRUE
        
    proc/process_animation()
        if(is_sliding)
            var/dx = target_x - screen_loc_x()
            var/dy = target_y - screen_loc_y()
            
            if(abs(dx) < slide_speed && abs(dy) < slide_speed)
                screen_loc = "[target_x],[target_y]"
                is_sliding = FALSE
                return
                
            var/new_x = screen_loc_x() + (dx * slide_speed)
            var/new_y = screen_loc_y() + (dy * slide_speed)
            screen_loc = "[new_x],[new_y]"

// Login manager that handles all UI windows
/datum/login_manager
    var/list/active_windows = list()
    var/mob/current_user
    var/savefile/save_data
    
    New()
        spawn()
            while(1)
                for(var/obj/screen/window/W in active_windows)
                    W.process_animation()
                sleep(1)

    proc/initialize_login(mob/user)
        current_user = user
        create_main_menu()
        load_settings()

    proc/create_main_menu()
        var/obj/screen/window/main_menu = new()
        main_menu.screen_loc = "CENTER-3,CENTER-2"
        main_menu.icon = 'login_ui.dmi'  // You'll need to create this icon file
        main_menu.icon_state = "main_menu"
        
        // Add login buttons
        var/obj/screen/button/login = new()
        login.screen_loc = "CENTER-2,CENTER"
        login.icon_state = "login_btn"
        login.Click()
            login_clicked()
            
        var/obj/screen/button/new_char = new()
        new_char.screen_loc = "CENTER,CENTER"
        new_char.icon_state = "newchar_btn"
        new_char.Click()
            create_character()
            
        var/obj/screen/button/options = new()
        options.screen_loc = "CENTER+2,CENTER"
        options.icon_state = "options_btn"
        options.Click()
            show_options()
            
        active_windows += main_menu

    proc/login_clicked()
        if(!fexists("saves/[current_user.ckey].sav"))
            alert("No save file found! Please create a character first.")
            return
            
        save_data = new("saves/[current_user.ckey].sav")
        var/list/characters = list()
        save_data["characters"] >> characters
        
        var/obj/screen/window/char_select = new()
        char_select.screen_loc = "CENTER+5,CENTER"  // Start off-screen
        char_select.icon_state = "char_select"
        
        // Populate character list
        for(var/char in characters)
            var/obj/screen/button/char_btn = new()
            char_btn.name = char["name"]
            char_btn.Click()
                load_character(char)
        
        active_windows += char_select
        char_select.slide_to("CENTER,CENTER", 3)  // Slide in animation

    proc/create_character()
        var/obj/screen/window/creator = new()
        creator.screen_loc = "CENTER,CENTER-5"  // Start below screen
        creator.icon_state = "char_creator"
        
        // Character customization fields
        var/obj/screen/textbox/name_input = new()
        var/obj/screen/color_picker/hair_color = new()
        var/obj/screen/dropdown/race_select = new()
        
        var/obj/screen/button/save_btn = new()
        save_btn.Click()
            save_character()
        
        active_windows += creator
        creator.slide_to("CENTER,CENTER", 2)

    proc/save_character()
        if(!save_data)
            save_data = new("saves/[current_user.ckey].sav")
            
        var/list/characters
        save_data["characters"] >> characters
        if(!characters) characters = list()
        
        // Gather character data
        var/list/new_char = list(
            "name" = name_input.value,
            "hair_color" = hair_color.selected_color,
            "race" = race_select.selected_value,
            // Add more character attributes
        )
        
        characters += new_char
        save_data["characters"] << characters
        
        // Animate window closing
        var/obj/screen/window/creator = locate() in active_windows
        creator.slide_to("CENTER,CENTER+5", 2)
        spawn(20)
            active_windows -= creator
            qdel(creator)

    proc/show_options()
        var/obj/screen/window/options = new()
        options.screen_loc = "CENTER-5,CENTER"
        options.icon_state = "options"
        
        // Create options controls
        var/obj/screen/checkbox/fullscreen = new()
        fullscreen.checked = winget(current_user.client, "mainwindow", "is-fullscreen")
        fullscreen.Click()
            toggle_fullscreen()
            
        var/obj/screen/slider/volume = new()
        // Add more options as needed
        
        active_windows += options
        options.slide_to("CENTER,CENTER", 2)

    proc/toggle_fullscreen()
        var/is_full = winget(current_user.client, "mainwindow", "is-fullscreen")
        if(is_full == "false")
            winset(current_user.client, "mainwindow", "is-fullscreen=true")
        else
            winset(current_user.client, "mainwindow", "is-fullscreen=false")
            
        // Save setting
        save_data["options/fullscreen"] << !is_full

    proc/load_settings()
        if(!fexists("saves/[current_user.ckey].sav")) return
        
        save_data = new("saves/[current_user.ckey].sav")
        var/fullscreen
        save_data["options/fullscreen"] >> fullscreen
        if(fullscreen)
            winset(current_user.client, "mainwindow", "is-fullscreen=true")

// Hook into client connection
/client/New()
    ..()
    var/datum/login_manager/LM = new()
    LM.initialize_login(mob)
