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

// Handle button clicks
if (start_hover && mouse_check_button_pressed(mb_left)) {
    start_clicked = true;
}

if (quit_hover && mouse_check_button_pressed(mb_left)) {
    quit_clicked = true;
}

// Execute actions on button release
if (start_clicked) {
    if (mouse_check_button_released(mb_left)) {
        // Start the game
        room_goto_next();
        start_clicked = false;
    }
} else if (!mouse_check_button(mb_left)) {
    start_clicked = false;
}

if (quit_clicked) {
    if (mouse_check_button_released(mb_left)) {
        // Quit the game
        game_end();
        quit_clicked = false;
    }
} else if (!mouse_check_button(mb_left)) {
    quit_clicked = false;
}