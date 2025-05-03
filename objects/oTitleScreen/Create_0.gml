/// @description Title Screen Setup
// You can write your code in this editor

// Title text
game_title = "All Is Not Lost";
title_color = c_white;
title_font = fnt_body; // Use the body font

// Button dimensions and states
button_width = 200;
button_height = 60;
button_spacing = 20;

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