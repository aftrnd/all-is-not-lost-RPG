/// @description Handle Button Interaction
// You can write your code in this editor

// Get mouse position based on coordinate system
var mx, my, bx, by;
if (use_gui_coords) {
    mx = device_mouse_x_to_gui(0);
    my = device_mouse_y_to_gui(0);
    bx = gui_x;
    by = gui_y;
} else {
    mx = mouse_x;
    my = mouse_y;
    bx = x;
    by = y;
}

// Button hit detection
var button_left = bx - width/2;
var button_right = bx + width/2;
var button_top = by - height/2;
var button_bottom = by + height/2;

// Check if mouse is over the button
hover = (mx >= button_left && mx <= button_right && my >= button_top && my <= button_bottom);

// Handle click
if (hover && mouse_check_button_pressed(mb_left)) {
    clicked = true;
}

// Execute action when button is released
if (clicked && mouse_check_button_released(mb_left)) {
    // Execute the button action
    switch (button_action) {
        case "start":
            // Start the game - transition to first level
            room_goto_next();
            break;
            
        case "quit":
            // Quit the game
            game_end();
            break;
    }
    
    clicked = false;
}

// Reset clicked state if mouse moves away
if (!hover && !mouse_check_button(mb_left)) {
    clicked = false;
} 