/// @description Handle menu input
// You can write your code in this editor

// Get mouse position for tracking (used throughout this event)
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

// Check for window resizing and update button positions if needed
if (gui_width != last_window_width || gui_height != last_window_height) {
    update_button_positions();
}

// Toggle menu on ESC key
if (keyboard_check_pressed(vk_escape)) {
    toggle_menu();
}

// Check for button triggers from oButton instances
if (menu_open && menu_alpha >= 0.5) {
    // Check if resume button was triggered
    if (instance_exists(resume_button) && resume_button.action_triggered) {
        // Instead of just setting menu_open to false, call toggle_menu() to properly unpause
        toggle_menu();
        resume_button.action_triggered = false; // Reset the flag
    }
    
    // Check if quit button was triggered
    if (instance_exists(quit_button) && quit_button.action_triggered) {
        // Make sure to unpause before changing room
        game_paused = false;
        instance_activate_all();
        room_goto(rmTitleScreen);
        quit_button.action_triggered = false; // Reset the flag
    }
}

// Handle menu fade animation
if (menu_open && menu_alpha < 0.8) {
    menu_alpha = min(menu_alpha + menu_fade_speed, 0.8);
} else if (!menu_open && menu_alpha > 0) {
    menu_alpha = max(menu_alpha - menu_fade_speed, 0);
    
    // If menu is completely closed, handle button visibility
    if (menu_alpha <= 0) {
        var i;
        for (i = 0; i < ds_list_size(menu_buttons); i++) {
            var btn = menu_buttons[|i];
            if (instance_exists(btn)) {
                btn.visible = false;
            }
        }
    }
}

// Ensure any new instances created during pause are properly handled
if (game_paused) {
    // Deactivate everything except UI elements
    instance_deactivate_all(true);
    // Reactivate important objects
    instance_activate_object(oGameController);
    instance_activate_object(oButton);
} 