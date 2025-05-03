/// @description Title Screen Setup
// You can write your code in this editor

// Load settings
settings_load();

// Title text
game_title = "All Is Not Lost";
title_color = c_white;
title_font = fnt_body; // Use the body font

// Button dimensions and states
button_width = 200;
button_height = 30;
button_spacing = 25;

// Button colors
color_normal = c_gray;
color_hover = c_ltgray;
color_clicked = c_white;
text_color = c_black;

// Button state tracking
start_hover = false;
start_clicked = false;
quit_hover = false;
quit_clicked = false;
settings_hover = false;
settings_clicked = false;

// Settings menu state
show_settings = false;
gui_scale = global.gui_scale;  // Get the GUI scale from global

// Define discrete scale values (only 1x, 2x, 3x to avoid aliasing)
scale_values = [1.0, 2.0, 3.0];

// Ensure gui_scale is one of our discrete values
var valid_scale = false;
for (var i = 0; i < array_length(scale_values); i++) {
    if (gui_scale == scale_values[i]) {
        valid_scale = true;
        break;
    }
}

// If not valid, set to 1x (default)
if (!valid_scale) {
    gui_scale = 1.0; // Default to 1x for pixel perfect display
    settings_apply_gui_scale(gui_scale);
}

// Get initial GUI dimensions
gui_width = display_get_gui_width();
gui_height = display_get_gui_height();
var buttons_y = gui_height * 0.6;

// Start Button - Create in room coordinates but store GUI position
start_button = instance_create_layer(room_width/2, room_height/2, "Instances", oButton);
start_button.button_text = "Start Game";
start_button.button_action = "start";
start_button.use_gui_coords = true;
// Store the GUI coordinates for drawing
start_button.gui_x = gui_width/2;
start_button.gui_y = buttons_y;

// Quit Button - Create in room coordinates but store GUI position
quit_button = instance_create_layer(room_width/2, room_height/2 + 100, "Instances", oButton);
quit_button.button_text = "Quit Game";
quit_button.button_action = "quit";
quit_button.use_gui_coords = true;
// Store the GUI coordinates for drawing
quit_button.gui_x = gui_width/2;
quit_button.gui_y = buttons_y + button_height + button_spacing;

// Settings Button - Create in room coordinates but store GUI position
settings_button = instance_create_layer(room_width/2, room_height/2 + 200, "Instances", oButton);
settings_button.button_text = "Settings";
settings_button.button_action = "settings";
settings_button.use_gui_coords = true;
// Store the GUI coordinates for drawing
settings_button.gui_x = gui_width/2;
settings_button.gui_y = buttons_y + (button_height + button_spacing) * 2;