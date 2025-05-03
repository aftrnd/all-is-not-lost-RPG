/// @desc oPlayer - Keyboard Input
// You can write your code in this editor

#region Variables
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var shift_pressed = keyboard_check(vk_shift);

// UI dimensions
var slot_size = 48;
var padding = 6;
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var hotbar_width = (slot_size + padding) * hotbar_size - padding;
var hotbar_x = (gui_width - hotbar_width) / 2;
var hotbar_y = gui_height - slot_size - 20;

// Calculate inventory dimensions for drag and drop
var inv_cols = 5;
var inv_rows = ceil(inventory_size / inv_cols);
var inv_width = (slot_size + padding) * inv_cols - padding;
var inv_height = (slot_size + padding) * inv_rows - padding;
var inv_x = (gui_width - inv_width) / 2;
var inv_y = (gui_height - inv_height) / 2 - 30;

// Player's Coordinates 
playerX = floor(x);
playerY = floor(y);
#endregion

#region Keyboard Bindings
keyRight = keyboard_check(vk_right);
keyLeft = keyboard_check(vk_left);
keyJump = keyboard_check_pressed(vk_space);
keyActivate = keyboard_check_pressed(ord("E")); // Generic 'Activate' key...

// Toggle inventory with Tab
if (keyboard_check_pressed(vk_tab)) {
    inventory_open = !inventory_open;
    // Log inventory state change
    debug_log("Inventory " + (inventory_open ? "opened" : "closed"), c_lime);
}
#endregion

#region Hotbar Selection
// Number key hotbar selection (1-5)
for (var i = 0; i < hotbar_size; i++) {
    // Check for keys 1-5 (use vk_1 through vk_5 for number keys at the top of keyboard)
    if (keyboard_check_pressed(ord("1") + i)) {
        selected_slot = i;
    }
}

// Mouse click selection for hotbar
if (mouse_check_button_pressed(mb_right)) {
    for (var i = 0; i < hotbar_size; i++) {
        var slot_x = hotbar_x + i * (slot_size + padding);
        var slot_y = hotbar_y;
        if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 
                               slot_x, slot_y, slot_x + slot_size, slot_y + slot_size)) {
            selected_slot = i;
            break;
        }
    }
}
#endregion

#region Hotbar-Inventory Transfer with Shift-Click
if (inventory_open && shift_pressed && (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right))) {
    // First check if clicking on hotbar
    var clicked_hotbar_slot = -1;
    for (var i = 0; i < hotbar_size; i++) {
        var slot_x = hotbar_x + i * (slot_size + padding);
        var slot_y = hotbar_y;
        if (point_in_rectangle(mx, my, slot_x, slot_y, slot_x + slot_size, slot_y + slot_size)) {
            clicked_hotbar_slot = i;
            break;
        }
    }
    
    // If clicked on hotbar, try to move to inventory
    if (clicked_hotbar_slot != -1 && inventory[clicked_hotbar_slot] != noone) {
        var hotbar_item = inventory[clicked_hotbar_slot];
        
        if (mouse_check_button_pressed(mb_left)) {
            // ===== SHIFT + LEFT CLICK: MOVE FULL STACK FROM HOTBAR TO INVENTORY =====
            var moved = false;
            
            // Try to find a slot with the same item type (for stacking)
            for (var i = 0; i < inventory_size; i++) {
                var inv_slot = hotbar_size + i;
                var inv_item = inventory[inv_slot];
                
                if (inv_item != noone && inv_item.name == hotbar_item.name) {
                    // Found matching item, stack them
                    inventory[inv_slot].count += hotbar_item.count;
                    inventory[clicked_hotbar_slot] = noone;
                    moved = true;
                    show_debug_message("Moved full stack from hotbar to inventory (stacked)");
                    break;
                }
            }
            
            // If no matching slot found, find an empty slot
            if (!moved) {
                for (var i = 0; i < inventory_size; i++) {
                    var inv_slot = hotbar_size + i;
                    if (inventory[inv_slot] == noone) {
                        // Found empty slot, move item there
                        inventory[inv_slot] = hotbar_item;
                        inventory[clicked_hotbar_slot] = noone;
                        moved = true;
                        show_debug_message("Moved full stack from hotbar to empty inventory slot");
                        break;
                    }
                }
                
                if (!moved) {
                    show_debug_message("Inventory full - could not move hotbar item");
                }
            }
        } else if (mouse_check_button_pressed(mb_right)) {
            // ===== SHIFT + RIGHT CLICK: MOVE SINGLE ITEM FROM HOTBAR TO INVENTORY =====
            var moved = false;
            
            // Try to find a slot with the same item type (for stacking)
            for (var i = 0; i < inventory_size; i++) {
                var inv_slot = hotbar_size + i;
                var inv_item = inventory[inv_slot];
                
                if (inv_item != noone && inv_item.name == hotbar_item.name) {
                    // Need to check max stack size
                    var max_stack = inv_item.data.max_stack;
                    if (inv_item.count < max_stack) {
                        // Found matching item with space, add one to it
                        inventory[inv_slot].count += 1;
                        hotbar_item.count -= 1;
                        
                        // If count reaches 0, remove item from hotbar
                        if (hotbar_item.count <= 0) {
                            inventory[clicked_hotbar_slot] = noone;
                        }
                        
                        moved = true;
                        show_debug_message("Added single item from hotbar to inventory stack");
                        break;
                    }
                }
            }
            
            // If no matching slot found or all are full, find an empty slot
            if (!moved) {
                for (var i = 0; i < inventory_size; i++) {
                    var inv_slot = hotbar_size + i;
                    if (inventory[inv_slot] == noone) {
                        // Found empty slot, create new single-item stack
                        inventory[inv_slot] = item_create(hotbar_item.name, 1);
                        hotbar_item.count -= 1;
                        
                        // If count reaches 0, remove item from hotbar
                        if (hotbar_item.count <= 0) {
                            inventory[clicked_hotbar_slot] = noone;
                        }
                        
                        moved = true;
                        show_debug_message("Moved single item from hotbar to empty inventory slot");
                        break;
                    }
                }
                
                if (!moved) {
                    show_debug_message("Inventory full - could not move single item from hotbar");
                }
            }
        }
    }
    
    // Now check if clicking on inventory
    var clicked_inv_index = -1;
    for (var i = 0; i < inventory_size; i++) {
        var row = i div inv_cols;
        var col = i mod inv_cols;
        var x_pos = inv_x + col * (slot_size + padding);
        var y_pos = inv_y + row * (slot_size + padding);
        
        if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
            clicked_inv_index = hotbar_size + i;
            break;
        }
    }
    
    // If clicked on inventory, try to move to hotbar
    if (clicked_inv_index != -1 && inventory[clicked_inv_index] != noone) {
        var inv_item = inventory[clicked_inv_index];
        
        if (mouse_check_button_pressed(mb_left)) {
            // ===== SHIFT + LEFT CLICK: MOVE FULL STACK FROM INVENTORY TO HOTBAR =====
            var moved = false;
            
            // Try to find a slot with the same item type (for stacking)
            for (var i = 0; i < hotbar_size; i++) {
                var hotbar_item = inventory[i];
                
                if (hotbar_item != noone && hotbar_item.name == inv_item.name) {
                    // Found matching item, stack them
                    inventory[i].count += inv_item.count;
                    inventory[clicked_inv_index] = noone;
                    moved = true;
                    show_debug_message("Moved full stack from inventory to hotbar (stacked)");
                    break;
                }
            }
            
            // If no matching slot found, find an empty slot
            if (!moved) {
                for (var i = 0; i < hotbar_size; i++) {
                    if (inventory[i] == noone) {
                        // Found empty slot, move item there
                        inventory[i] = inv_item;
                        inventory[clicked_inv_index] = noone;
                        moved = true;
                        show_debug_message("Moved full stack from inventory to empty hotbar slot");
                        break;
                    }
                }
                
                if (!moved) {
                    show_debug_message("Hotbar full - could not move inventory item");
                }
            }
        } else if (mouse_check_button_pressed(mb_right)) {
            // ===== SHIFT + RIGHT CLICK: MOVE SINGLE ITEM FROM INVENTORY TO HOTBAR =====
            var moved = false;
            
            // Try to find a slot with the same item type (for stacking)
            for (var i = 0; i < hotbar_size; i++) {
                var hotbar_item = inventory[i];
                
                if (hotbar_item != noone && hotbar_item.name == inv_item.name) {
                    // Need to check max stack size
                    var max_stack = hotbar_item.data.max_stack;
                    if (hotbar_item.count < max_stack) {
                        // Found matching item with space, add one to it
                        inventory[i].count += 1;
                        inv_item.count -= 1;
                        
                        // If count reaches 0, remove item from inventory
                        if (inv_item.count <= 0) {
                            inventory[clicked_inv_index] = noone;
                        }
                        
                        moved = true;
                        show_debug_message("Added single item from inventory to hotbar stack");
                        break;
                    }
                }
            }
            
            // If no matching slot found or all are full, find an empty slot
            if (!moved) {
                for (var i = 0; i < hotbar_size; i++) {
                    if (inventory[i] == noone) {
                        // Found empty slot, create new single-item stack
                        inventory[i] = item_create(inv_item.name, 1);
                        inv_item.count -= 1;
                        
                        // If count reaches 0, remove item from inventory
                        if (inv_item.count <= 0) {
                            inventory[clicked_inv_index] = noone;
                        }
                        
                        moved = true;
                        show_debug_message("Moved single item from inventory to empty hotbar slot");
                        break;
                    }
                }
                
                if (!moved) {
                    show_debug_message("Hotbar full - could not move single item from inventory");
                }
            }
        }
    }
}
#endregion

#region Drag and Drop Logic
if (mouse_check_button_pressed(mb_left)) {
    if (dragging_item == noone) {
        // Start dragging from hotbar
        var found_item = false;
        
        // Check hotbar slots first
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
                    found_item = true;
                    break;
                }
            }
        }
        
        // If inventory is open, check inventory slots
        if (!found_item && inventory_open) {
            for (var i = 0; i < inventory_size; i++) {
                var row = i div inv_cols;
                var col = i mod inv_cols;
                var x_pos = inv_x + col * (slot_size + padding);
                var y_pos = inv_y + row * (slot_size + padding);
                
                if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
                    var slot_index = hotbar_size + i;
                    if (inventory[slot_index] != noone) {
                        dragging_item = inventory[slot_index];
                        drag_origin_index = slot_index;
                        drag_offset_x = mx - x_pos;
                        drag_offset_y = my - y_pos;
                        inventory[slot_index] = noone;
                        break;
                    }
                }
            }
        }
    } else {
        // Drop item
        var dropped = false;
        
        // Try to drop in hotbar
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
        
        // Try to drop in inventory if open
        if (!dropped && inventory_open) {
            for (var i = 0; i < inventory_size; i++) {
                var row = i div inv_cols;
                var col = i mod inv_cols;
                var x_pos = inv_x + col * (slot_size + padding);
                var y_pos = inv_y + row * (slot_size + padding);
                
                if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
                    var slot_index = hotbar_size + i;
                    if (inventory[slot_index] == noone) {
                        inventory[slot_index] = dragging_item;
                    } else {
                        // Swap items
                        var temp = inventory[slot_index];
                        inventory[slot_index] = dragging_item;
                        inventory[drag_origin_index] = temp;
                    }
                    dragging_item = noone;
                    dropped = true;
                    break;
                }
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

// Sets which state the player should be in
script_execute(state);