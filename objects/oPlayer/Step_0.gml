/// @desc oPlayer - Keyboard Input
// You can write your code in this editor

#region Keyboard Bindings
keyRight = keyboard_check(vk_right);
keyLeft = keyboard_check(vk_left);
keyJump = keyboard_check_pressed(vk_space);
keyActivate = keyboard_check_pressed(ord("E")); // Generic 'Activate' key...
#endregion

#region Drag and Drop Logic
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var shift_pressed = keyboard_check(vk_shift);

if (mouse_check_button_pressed(mb_left)) {
    if (dragging_item == noone) {
        // Start dragging
        for (var i = 0; i < array_length(inventory); i++) {
            var slot_x = 32 + (i mod hotbar_size) * (slot_w + padding);
            var slot_y = display_get_gui_height() - slot_h - 16;
            if (point_in_rectangle(mx, my, slot_x, slot_y, slot_x + slot_w, slot_y + slot_h)) {
                if (inventory[i] != noone) {
                    dragging_item = inventory[i];
                    drag_origin_index = i;
                    drag_offset_x = mx - slot_x;
                    drag_offset_y = my - slot_y;
                    inventory[i] = noone;
                    break;
                }
            }
        }
    } else {
        // Drop item
        for (var i = 0; i < array_length(inventory); i++) {
            var slot_x = 32 + (i mod hotbar_size) * (slot_w + padding);
            var slot_y = display_get_gui_height() - slot_h - 16;
            if (point_in_rectangle(mx, my, slot_x, slot_y, slot_x + slot_w, slot_y + slot_h)) {
                if (inventory[i] == noone) {
                    inventory[i] = dragging_item;
                } else {
                    // Swap items
                    var temp = inventory[i];
                    inventory[i] = dragging_item;
                    inventory[drag_origin_index] = temp;
                }
                dragging_item = noone;
                break;
            }
        }
        if (dragging_item != noone) {
            // If not dropped in a valid slot, return to origin
            inventory[drag_origin_index] = dragging_item;
            dragging_item = noone;
        }
    }
}
#endregion

// Player's Coordinates 
playerX = floor(x);
playerY = floor(y);

// Sets which state the player should be in
script_execute(state);