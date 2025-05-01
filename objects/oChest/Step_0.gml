/// @desc oChest - Step Event
// You can write your code in this editor

#region Chest Open/Close Logic
// Chest proximity and UI open/close
var player_near = (point_distance(x, y, oPlayer.x, oPlayer.y) <= open_distance);

if (player_near) {
    if (keyboard_check_pressed(vk_enter)) {
        if (!is_open) {
            opening = true;
            closing = false;
            ui_open = true;
        } else {
            closing = true;
            opening = false;
            ui_open = false;
        }
    }
} else {
    if (is_open || opening) {
        closing = true;
        opening = false;
        ui_open = false;
    }
}
#endregion

#region Chest Animation Handling
// Animate chest frames
if (opening) {
    frame_pos += frame_speed;
    if (frame_pos >= 4) {
        frame_pos = 4;
        opening = false;
        is_open = true;
    }
}

if (closing) {
    frame_pos -= frame_speed;
    if (frame_pos <= 0) {
        frame_pos = 0;
        closing = false;
        is_open = false;
    }
}
#endregion

#region Sprite Frame Update
// Update sprite frame
image_index = frame_pos;
#endregion

var shift_pressed = keyboard_check(vk_shift);

var slot_w = 64;
var slot_h = 32;
var padding = 4;

var chest_x = 64;
var chest_y = 64;

#region Mouse Click Transfer - Chest to Player
// Mouse click transfer CHEST (left click)
if (ui_open && (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right))) {
    for (var i = 0; i < array_length(inventory); i++) {
        var row = i div 5;
        var col = i mod 5;

        var x_pos = chest_x + col * (slot_w + padding);
        var y_pos = chest_y + row * (slot_h + padding);

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h)) {
            if (shift_pressed && mouse_check_button_pressed(mb_left)) {
                // Shift + Left Click: Move full stack
                if (transfer_item_from(self, oPlayer, i)) {
                    show_debug_message("Clicked chest slot " + string(i));
                }
            } else if (shift_pressed && mouse_check_button_pressed(mb_right)) {
                // Shift + Right Click: Move single item
                var item = inventory[i];
                if (item != noone) {
                    var single_item = item_create(item.name, 1);
                    var added = oPlayer.inventory_add_item(single_item);
                    if (added) {
                        item.count -= 1;
                        if (item.count <= 0) {
                            inventory[i] = noone;
                        } else {
                            inventory[i] = item;
                        }
                        show_debug_message("Moved 1 " + item.name + " to player");
                    } else {
                        show_debug_message("Player inventory full for single item");
                    }
                }
            }
        }
    }
}
#endregion

#region Mouse Click Transfer - Player Hotbar to Chest
if (ui_open) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    var slot_w = 64;
    var slot_h = 32;
    var padding = 4;
    var hotbar_y = display_get_gui_height() - slot_h - 16;

    for (var i = 0; i < 5; i++) {
        var x_pos = 32 + i * (slot_w + padding);
        var y_pos = hotbar_y;

        if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h)) {
            var item = oPlayer.inventory[i];

            if (item != noone) {
                if (shift_pressed && mouse_check_button_pressed(mb_left)) {
                    // Shift + Left Click, move full stack
                    if (transfer_item_from(oPlayer, self, i)) {
                        show_debug_message("Moved full stack from hotbar slot " + string(i));
                    } else {
                        show_debug_message("Chest full or stacking failed.");
                    }
                } else if (shift_pressed && mouse_check_button_pressed(mb_right)) {
                    // Shift + Right Click, move 1 item
                    var single_item = item_create(item.name, 1); // include .data!
                    
                    var added = inventory_add_item(single_item); // ✅ FIXED
                    
                    if (added) {
                        item.count -= 1;
                        
                        if (item.count <= 0) {
                            oPlayer.inventory[i] = noone;
                        } else {
                            oPlayer.inventory[i] = item;
                        }
                        
                        show_debug_message("Moved 1 " + item.name);
                    } else {
                        show_debug_message("Chest full for single item");
                    }
                }
            }
        }
    }
}
#endregion

#region Mouse Right Click Transfer - Chest to Player
if (ui_open && mouse_check_button_pressed(mb_right)) {
    var slot_w = 64;
    var slot_h = 32;
    var padding = 4;
    var chest_x = 64;
    var chest_y = 64;

    for (var i = 0; i < array_length(inventory); i++) {
        var row = i div 5;
        var col = i mod 5;

        var x_pos = chest_x + col * (slot_w + padding);
        var y_pos = chest_y + row * (slot_h + padding);

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h)) {
            var item = inventory[i];

            if (item != noone) {
                // Right click, move 1 item
                var single_item = item_create(item.name, 1); // include .data!
                
                var added = oPlayer.inventory_add_item(single_item); // Assuming a similar function exists for player
                
                if (added) {
                    item.count -= 1;
                    
                    if (item.count <= 0) {
                        inventory[i] = noone;
                    } else {
                        inventory[i] = item;
                    }
                    
                    show_debug_message("Moved 1 " + item.name + " to player");
                } else {
                    show_debug_message("Player inventory full for single item");
                }
            }
        }
    }
}
#endregion

#region Drag and Drop Logic
// Handle dragging items within the chest inventory
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
if (ui_open && mouse_check_button_pressed(mb_left)) {
    if (dragging_item == noone) {
        // Start dragging from chest
        for (var i = 0; i < array_length(inventory); i++) {
            var row = i div 5;
            var col = i mod 5;
            var x_pos = chest_x + col * (slot_w + padding);
            var y_pos = chest_y + row * (slot_h + padding);
            if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h)) {
                if (inventory[i] != noone) {
                    dragging_item = inventory[i];
                    drag_origin_index = i;
                    drag_offset_x = mx - x_pos;
                    drag_offset_y = my - y_pos;
                    inventory[i] = noone;
                    break;
                }
            }
        }
    } else {
        // Drop or swap within chest
        for (var i = 0; i < array_length(inventory); i++) {
            var row = i div 5;
            var col = i mod 5;
            var x_pos = chest_x + col * (slot_w + padding);
            var y_pos = chest_y + row * (slot_h + padding);
            if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h)) {
                if (inventory[i] == noone) {
                    inventory[i] = dragging_item;
                } else {
                    var temp = inventory[i];
                    inventory[i] = dragging_item;
                    inventory[drag_origin_index] = temp;
                }
                dragging_item = noone;
                break;
            }
        }
        // If dropped outside valid slot, return to origin
        if (dragging_item != noone) {
            inventory[drag_origin_index] = dragging_item;
            dragging_item = noone;
        }
    }
}
#endregion