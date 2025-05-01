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

// Updated dimensions for new UI
var slot_size = 64;
var padding = 8;
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var hotbar_width = (slot_size + padding) * hotbar_size - padding;
var hotbar_x = (gui_width - hotbar_width) / 2;
var hotbar_y = gui_height - slot_size - 20;

if (mouse_check_button_pressed(mb_left)) {
    if (dragging_item == noone) {
        // Start dragging
        for (var i = 0; i < hotbar_size; i++) {
            var slot_x = hotbar_x + i * (slot_size + padding);
            var slot_y = hotbar_y;
            if (point_in_rectangle(mx, my, slot_x, slot_y, slot_x + slot_size, slot_y + slot_size)) {
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
        var dropped = false;
        for (var i = 0; i < hotbar_size; i++) {
            var slot_x = hotbar_x + i * (slot_size + padding);
            var slot_y = hotbar_y;
            if (point_in_rectangle(mx, my, slot_x, slot_y, slot_x + slot_size, slot_y + slot_size)) {
                if (inventory[i] == noone) {
                    inventory[i] = dragging_item;
                } else {
                    // Swap items
                    var temp = inventory[i];
                    inventory[i] = dragging_item;
                    inventory[drag_origin_index] = temp;
                }
                dragging_item = noone;
                dropped = true;
                break;
            }
        }
        if (!dropped) {
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