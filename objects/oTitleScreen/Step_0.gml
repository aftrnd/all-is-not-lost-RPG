/// @description Title Screen Input
// You can write your code in this editor

// Update GUI dimensions (in case window resizes)
gui_width = display_get_gui_width();
gui_height = display_get_gui_height();

// Get mouse position in GUI
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Button positions
var start_y = gui_height * 0.6;
var quit_y = start_y + button_height + button_spacing;
var settings_y = quit_y + button_height + button_spacing;

// Start button hit detection
var start_left = gui_width/2 - button_width/2;
var start_right = gui_width/2 + button_width/2;
var start_top = start_y - button_height/2;
var start_bottom = start_y + button_height/2;
start_hover = (mx >= start_left && mx <= start_right && my >= start_top && my <= start_bottom);

// Quit button hit detection
var quit_left = gui_width/2 - button_width/2;
var quit_right = gui_width/2 + button_width/2;
var quit_top = quit_y - button_height/2;
var quit_bottom = quit_y + button_height/2;
quit_hover = (mx >= quit_left && mx <= quit_right && my >= quit_top && my <= quit_bottom);

// Settings button hit detection
var settings_left = gui_width/2 - button_width/2;
var settings_right = gui_width/2 + button_width/2;
var settings_top = settings_y - button_height/2;
var settings_bottom = settings_y + button_height/2;
settings_hover = (mx >= settings_left && mx <= settings_right && my >= settings_top && my <= settings_bottom);

// Handle button clicks
if (start_hover && mouse_check_button_pressed(mb_left)) {
    start_clicked = true;
}

if (quit_hover && mouse_check_button_pressed(mb_left)) {
    quit_clicked = true;
}

if (settings_hover && mouse_check_button_pressed(mb_left)) {
    settings_clicked = true;
}

// Execute actions on button release
if (start_clicked) {
    if (mouse_check_button_released(mb_left)) {
        // Only start the game if settings menu is not open
        if (!show_settings) {
            room_goto_next();
        }
        start_clicked = false;
    }
} else if (!mouse_check_button(mb_left)) {
    start_clicked = false;
}

if (quit_clicked) {
    if (mouse_check_button_released(mb_left)) {
        // Only quit if settings menu is not open
        if (!show_settings) {
            game_end();
        }
        quit_clicked = false;
    }
} else if (!mouse_check_button(mb_left)) {
    quit_clicked = false;
}

if (settings_clicked) {
    if (mouse_check_button_released(mb_left)) {
        // Toggle settings menu
        show_settings = !show_settings;
        settings_clicked = false;
    }
} else if (!mouse_check_button(mb_left)) {
    settings_clicked = false;
}

// Settings menu functionality
if (show_settings) {
    // Settings panel dimensions
    var panel_width = 300;
    var panel_height = 200;
    var panel_x = gui_width/2;
    var panel_y = gui_height/2;
    
    // Slider dimensions
    var slider_width = 200;
    var slider_height = 20;
    var slider_x = panel_x;
    var slider_y = panel_y;
    
    // Slider hit detection
    var slider_left = slider_x - slider_width/2;
    var slider_right = slider_x + slider_width/2;
    var slider_top = slider_y - slider_height/2;
    var slider_bottom = slider_y + slider_height/2;
    
    // Check if mouse is over slider
    var slider_hover = (mx >= slider_left && mx <= slider_right && my >= slider_top && my <= slider_bottom);
    
    // Define the discrete scale values (1x, 2x, 3x)
    var scale_values = [1.0, 2.0, 3.0];
    var num_values = array_length(scale_values);
    
    // Adjust GUI scale when dragging the slider
    if (slider_hover && mouse_check_button(mb_left)) {
        // Calculate percentage of slider position
        var scale_percent = (mx - slider_left) / slider_width;
        
        // Convert to index in scale_values array
        var value_index = floor(scale_percent * num_values);
        
        // Make sure we handle the edge case when at the far right of the slider
        if (value_index >= num_values) {
            value_index = num_values - 1;
        }
        
        // Get the discrete scale value
        gui_scale = scale_values[value_index];
        
        // Apply scale using the settings function
        settings_apply_gui_scale(gui_scale);
    }
    
    // Close button dimensions
    var close_size = 20;
    var close_x = panel_x + panel_width/2 - close_size/2;
    var close_y = panel_y - panel_height/2 + close_size/2;
    
    // Close button hit detection
    var close_hover = (mx >= close_x - close_size/2 && mx <= close_x + close_size/2 && 
                       my >= close_y - close_size/2 && my <= close_y + close_size/2);
                       
    // Close settings when close button is clicked
    if (close_hover && mouse_check_button_pressed(mb_left)) {
        show_settings = false;
    }
}