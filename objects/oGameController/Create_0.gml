// INITIALIZE ITEMS
item_db_init()

// SIGN TEXT
global.sign_texts = ds_map_create();
ds_map_add(global.sign_texts, "greeting", "Hey, Instagram...");
ds_map_add(global.sign_texts, "greeting_02", "What's good");
ds_map_add(global.sign_texts, "warning", "Beware of the deep forest ahead...");
ds_map_add(global.sign_texts, "hint", "Press [SPACE] to jump higher!");

// IN-GAME MENU
menu_open = false;  // Start with menu closed
menu_alpha = 0;     // Start with no alpha
menu_fade_speed = 0.1;
game_paused = false; // Track if game is paused

// Menu buttons
menu_buttons = ds_list_create();
resume_button = noone;
quit_button = noone;

// Button layout settings
button_vertical_spacing = 80; // Fixed vertical spacing between buttons in pixels

// Window size tracking for responsive UI
last_window_width = display_get_gui_width();
last_window_height = display_get_gui_height();

// Create helper function for toggling menu
toggle_menu = function() {
    menu_open = !menu_open;
    
    // Force a minimum alpha if opening to ensure visibility starts
    if (menu_open && menu_alpha < 0.1) {
        menu_alpha = 0.1;
    }
    
    // Handle game pausing
    if (menu_open) {
        // Pause the game
        game_paused = true;
        // Deactivate all instances except for this controller and UI elements
        instance_deactivate_all(true);
        // Reactivate the controller and menu buttons
        instance_activate_object(oGameController);
        instance_activate_object(oButton);
    } else {
        // Unpause the game
        game_paused = false;
        // Reactivate all instances
        instance_activate_all();
    }
    
    return menu_open;
}

// Function to create menu buttons
create_menu_buttons = function() {
    // Clear existing buttons
    if (ds_list_size(menu_buttons) > 0) {
        for (var i = 0; i < ds_list_size(menu_buttons); i++) {
            instance_destroy(menu_buttons[|i]);
        }
        ds_list_clear(menu_buttons);
    }
    
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    
    // Calculate vertical positions using fixed spacing
    var menu_title_y = gui_height * 0.25; // Menu title position
    var first_button_y = menu_title_y + 80; // First button below title
    
    // Create Resume button
    resume_button = instance_create_layer(gui_width/2, first_button_y, "Instances", oButton);
    with (resume_button) {
        button_text = "Resume Game";
        button_action = "resume";
        use_gui_coords = true;
        gui_x = gui_width/2;
        gui_y = first_button_y;
        parent_controller = other.id;
        visible = false; // Start invisible
        text_color = c_white; // Set text color to white
        
        // Force update text color
        color_normal = c_dkgray;
        color_hover = c_gray;
        color_clicked = c_ltgray;
        
        // Flag that text will be drawn by the controller
        is_menu_button = true;
        
        // Debug output to verify
        show_debug_message("Resume button text color: " + string(text_color == c_white ? "WHITE" : "NOT WHITE"));
    }
    ds_list_add(menu_buttons, resume_button);
    
    // Create Quit button (fixed distance below resume button)
    var quit_button_y = first_button_y + button_vertical_spacing;
    quit_button = instance_create_layer(gui_width/2, quit_button_y, "Instances", oButton);
    with (quit_button) {
        button_text = "Quit to Title";
        button_action = "quit";
        use_gui_coords = true;
        gui_x = gui_width/2; 
        gui_y = quit_button_y;
        parent_controller = other.id;
        visible = false; // Start invisible
        text_color = c_white; // Set text color to white
        
        // Force update text color
        color_normal = c_dkgray;
        color_hover = c_gray;
        color_clicked = c_ltgray;
        
        // Flag that text will be drawn by the controller
        is_menu_button = true;
        
        // Debug output to verify
        show_debug_message("Quit button text color: " + string(text_color == c_white ? "WHITE" : "NOT WHITE"));
    }
    ds_list_add(menu_buttons, quit_button);
}

// Function to update button positions when window resizes
update_button_positions = function() {
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    
    // Update last window size variables
    last_window_width = gui_width;
    last_window_height = gui_height;
    
    // Calculate vertical positions using fixed spacing
    var menu_title_y = gui_height * 0.25; // Menu title position
    var first_button_y = menu_title_y + 80; // First button below title
    var second_button_y = first_button_y + button_vertical_spacing; // Fixed distance for second button
    
    // Update Resume button position
    if (instance_exists(resume_button)) {
        resume_button.gui_x = gui_width/2;
        resume_button.gui_y = first_button_y;
    }
    
    // Update Quit button position
    if (instance_exists(quit_button)) {
        quit_button.gui_x = gui_width/2;
        quit_button.gui_y = second_button_y;
    }
}

// Cleanup function (will be called on instance destroy)
cleanup_menu = function() {
    // Destroy all button instances
    var i;
    for (i = 0; i < ds_list_size(menu_buttons); i++) {
        if (instance_exists(menu_buttons[|i])) {
            instance_destroy(menu_buttons[|i]);
        }
    }
    
    // Free the list
    ds_list_destroy(menu_buttons);
}

// Create the menu buttons
create_menu_buttons();

// Add a startup debug message
show_debug_message("oGameController initialized with oButton approach");