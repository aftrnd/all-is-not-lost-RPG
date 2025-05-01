/// @desc oChest - Step Event
// You can write your code in this editor

#region Variables
var shift_pressed = keyboard_check(vk_shift);

// Update to match the dimensions in Draw_64.gml
var slot_size = 48;
var padding = 6;
var border = 2;

var chest_x = 64;
var chest_y = 64;
#endregion

#region Chest Open/Close Logic
// Chest proximity and UI open/close
var player_near = (point_distance(x, y, oPlayer.x, oPlayer.y) <= open_distance);

if (player_near) {
    if (keyboard_check_pressed(vk_enter)) {
        if (!is_open) {
            opening = true;
            closing = false;
            ui_open = true;
            // Log chest opening for debug display
            if (instance_exists(oPlayer)) {
                oPlayer.debug_log("Chest opened at x:" + string(x) + " y:" + string(y), c_yellow);
            }
        } else {
            closing = true;
            opening = false;
            ui_open = false;
            // Log chest closing for debug display
            if (instance_exists(oPlayer)) {
                oPlayer.debug_log("Chest closed", c_yellow);
            }
        }
    }
} else {
    if (is_open || opening) {
        closing = true;
        opening = false;
        ui_open = false;
        // Log forced chest closing for debug display
        if (instance_exists(oPlayer)) {
            oPlayer.debug_log("Chest forced closed - player moved away", c_orange);
        }
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

#region Mouse Click Transfer - Chest to Player
// Mouse click transfer CHEST (left click)
if (ui_open && (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right))) {
    for (var i = 0; i < array_length(inventory); i++) {
        var row = i div 5;
        var col = i mod 5;

        var x_pos = chest_x + col * (slot_size + padding);
        var y_pos = chest_y + row * (slot_size + padding);

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
            var chest_item = inventory[i];
            
            if (chest_item != noone) {
                if (shift_pressed && mouse_check_button_pressed(mb_left)) {
                    // ===== SHIFT + LEFT CLICK: MOVE FULL STACK =====
                    var moved = false;
                    
                    // Try stacking in hotbar first
                    for (var j = 0; j < oPlayer.hotbar_size; j++) {
                        var hotbar_item = oPlayer.inventory[j];
                        if (hotbar_item != noone && hotbar_item.name == chest_item.name) {
                            // Found matching item in hotbar, stack them
                            hotbar_item.count += chest_item.count;
                            inventory[i] = noone;
                            moved = true;
                            show_debug_message("Stacked full stack in hotbar slot " + string(j));
                            break;
                        }
                    }
                    
                    // Try stacking in inventory if not moved and inventory is open
                    if (!moved && oPlayer.inventory_open) {
                        for (var j = 0; j < oPlayer.inventory_size; j++) {
                            var inv_slot = oPlayer.hotbar_size + j;
                            var inv_item = oPlayer.inventory[inv_slot];
                            if (inv_item != noone && inv_item.name == chest_item.name) {
                                // Found matching item in inventory, stack them
                                inv_item.count += chest_item.count;
                                inventory[i] = noone;
                                moved = true;
                                show_debug_message("Stacked full stack in inventory slot " + string(inv_slot));
                                break;
                            }
                        }
                    }
                    
                    // If not stacked, find empty slot
                    if (!moved) {
                        // Try hotbar first
                        for (var j = 0; j < oPlayer.hotbar_size; j++) {
                            if (oPlayer.inventory[j] == noone) {
                                // Found empty hotbar slot
                                oPlayer.inventory[j] = item_create(chest_item.name, chest_item.count);
                                inventory[i] = noone;
                                moved = true;
                                show_debug_message("Moved full stack to empty hotbar slot " + string(j));
                                break;
                            }
                        }
                        
                        // Try inventory if not moved and inventory is open
                        if (!moved && oPlayer.inventory_open) {
                            for (var j = 0; j < oPlayer.inventory_size; j++) {
                                var inv_slot = oPlayer.hotbar_size + j;
                                if (oPlayer.inventory[inv_slot] == noone) {
                                    // Found empty inventory slot
                                    oPlayer.inventory[inv_slot] = item_create(chest_item.name, chest_item.count);
                                    inventory[i] = noone;
                                    moved = true;
                                    show_debug_message("Moved full stack to empty inventory slot " + string(inv_slot));
                                    break;
                                }
                            }
                        }
                        
                        if (!moved) {
                            show_debug_message("No space in player inventory for full stack");
                        }
                    }
                    
                } else if (shift_pressed && mouse_check_button_pressed(mb_right)) {
                    // ===== SHIFT + RIGHT CLICK: MOVE SINGLE ITEM =====
                    var moved = false;
                    
                    // Try stacking in hotbar first
                    for (var j = 0; j < oPlayer.hotbar_size; j++) {
                        var hotbar_item = oPlayer.inventory[j];
                        if (hotbar_item != noone && hotbar_item.name == chest_item.name) {
                            // Need to check max stack size
                            var max_stack = hotbar_item.data.max_stack;
                            if (hotbar_item.count < max_stack) {
                                // There's room in the stack
                                hotbar_item.count += 1;
                                chest_item.count -= 1;
                                moved = true;
                                
                                // Remove chest item if emptied
                                if (chest_item.count <= 0) {
                                    inventory[i] = noone;
                                }
                                
                                show_debug_message("Added single item to existing hotbar stack");
                                break;
                            }
                        }
                    }
                    
                    // Try stacking in inventory if not moved and inventory is open
                    if (!moved && oPlayer.inventory_open) {
                        for (var j = 0; j < oPlayer.inventory_size; j++) {
                            var inv_slot = oPlayer.hotbar_size + j;
                            var inv_item = oPlayer.inventory[inv_slot];
                            if (inv_item != noone && inv_item.name == chest_item.name) {
                                // Need to check max stack size
                                var max_stack = inv_item.data.max_stack;
                                if (inv_item.count < max_stack) {
                                    // There's room in the stack
                                    inv_item.count += 1;
                                    chest_item.count -= 1;
                                    moved = true;
                                    
                                    // Remove chest item if emptied
                                    if (chest_item.count <= 0) {
                                        inventory[i] = noone;
                                    }
                                    
                                    show_debug_message("Added single item to existing inventory stack");
                                    break;
                                }
                            }
                        }
                    }
                    
                    // If not stacked, find empty slot
                    if (!moved) {
                        // Try hotbar first
                        for (var j = 0; j < oPlayer.hotbar_size; j++) {
                            if (oPlayer.inventory[j] == noone) {
                                // Found empty hotbar slot
                                oPlayer.inventory[j] = item_create(chest_item.name, 1);
                                chest_item.count -= 1;
                                
                                // Remove chest item if emptied
                                if (chest_item.count <= 0) {
                                    inventory[i] = noone;
                                }
                                
                                moved = true;
                                show_debug_message("Moved single item to empty hotbar slot " + string(j));
                                break;
                            }
                        }
                        
                        // Try inventory if not moved and inventory is open
                        if (!moved && oPlayer.inventory_open) {
                            for (var j = 0; j < oPlayer.inventory_size; j++) {
                                var inv_slot = oPlayer.hotbar_size + j;
                                if (oPlayer.inventory[inv_slot] == noone) {
                                    // Found empty inventory slot
                                    oPlayer.inventory[inv_slot] = item_create(chest_item.name, 1);
                                    chest_item.count -= 1;
                                    
                                    // Remove chest item if emptied
                                    if (chest_item.count <= 0) {
                                        inventory[i] = noone;
                                    }
                                    
                                    moved = true;
                                    show_debug_message("Moved single item to empty inventory slot " + string(inv_slot));
                                    break;
                                }
                            }
                        }
                        
                        if (!moved) {
                            show_debug_message("No space in player inventory for single item");
                        }
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
    
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    
    var hotbar_width = (slot_size + padding) * oPlayer.hotbar_size - padding;
    var hotbar_x = (gui_width - hotbar_width) / 2; // Center hotbar
    var hotbar_y = gui_height - slot_size - 20;

    for (var i = 0; i < oPlayer.hotbar_size; i++) {
        var x_pos = hotbar_x + i * (slot_size + padding);
        var y_pos = hotbar_y;

        if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
            var hotbar_item = oPlayer.inventory[i];

            if (hotbar_item != noone) {
                if (shift_pressed && mouse_check_button_pressed(mb_left)) {
                    // ===== SHIFT + LEFT CLICK: MOVE FULL STACK =====
                    var moved = false;
                    
                    // Try stacking in chest
                    for (var j = 0; j < array_length(inventory); j++) {
                        var chest_item = inventory[j];
                        if (chest_item != noone && chest_item.name == hotbar_item.name) {
                            // Found matching item in chest, stack them
                            chest_item.count += hotbar_item.count;
                            oPlayer.inventory[i] = noone;
                            moved = true;
                            show_debug_message("Moved full stack from hotbar to chest slot " + string(j));
                            break;
                        }
                    }
                    
                    // If not stacked, find empty slot
                    if (!moved) {
                        for (var j = 0; j < array_length(inventory); j++) {
                            if (inventory[j] == noone) {
                                // Found empty chest slot
                                inventory[j] = item_create(hotbar_item.name, hotbar_item.count);
                                oPlayer.inventory[i] = noone;
                                moved = true;
                                show_debug_message("Moved full stack to empty chest slot " + string(j));
                                break;
                            }
                        }
                        
                        if (!moved) {
                            show_debug_message("Chest full - could not move full stack");
                        }
                    }
                } else if (shift_pressed && mouse_check_button_pressed(mb_right)) {
                    // ===== SHIFT + RIGHT CLICK: MOVE SINGLE ITEM =====
                    var moved = false;
                    
                    // Try stacking in chest
                    for (var j = 0; j < array_length(inventory); j++) {
                        var chest_item = inventory[j];
                        if (chest_item != noone && chest_item.name == hotbar_item.name) {
                            // Need to check max stack size
                            var max_stack = chest_item.data.max_stack;
                            if (chest_item.count < max_stack) {
                                // There's room in the stack
                                chest_item.count += 1;
                                hotbar_item.count -= 1;
                                moved = true;
                                
                                // Remove hotbar item if emptied
                                if (hotbar_item.count <= 0) {
                                    oPlayer.inventory[i] = noone;
                                }
                                
                                show_debug_message("Added single item to existing chest stack");
                                break;
                            }
                        }
                    }
                    
                    // If not stacked, find empty slot
                    if (!moved) {
                        for (var j = 0; j < array_length(inventory); j++) {
                            if (inventory[j] == noone) {
                                // Found empty chest slot
                                inventory[j] = item_create(hotbar_item.name, 1);
                                hotbar_item.count -= 1;
                                
                                // Remove hotbar item if emptied
                                if (hotbar_item.count <= 0) {
                                    oPlayer.inventory[i] = noone;
                                }
                                
                                moved = true;
                                show_debug_message("Moved single item to empty chest slot " + string(j));
                                break;
                            }
                        }
                        
                        if (!moved) {
                            show_debug_message("Chest full - could not move single item");
                        }
                    }
                }
            }
        }
    }
}
#endregion

#region Mouse Click Transfer - Player Inventory to Chest
if (ui_open && oPlayer.inventory_open) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    // Calculate player inventory dimensions
    var gui_width = display_get_gui_width();
    var gui_height = display_get_gui_height();
    var inv_cols = 5;
    var inv_rows = ceil(oPlayer.inventory_size / inv_cols);
    var inv_width = (slot_size + padding) * inv_cols - padding;
    var inv_height = (slot_size + padding) * inv_rows - padding;
    var inv_x = (gui_width - inv_width) / 2;
    var inv_y = (gui_height - inv_height) / 2 - 30;
    
    // Loop through player inventory slots
    for (var i = 0; i < oPlayer.inventory_size; i++) {
        var row = i div inv_cols;
        var col = i mod inv_cols;
        var slot_x = inv_x + col * (slot_size + padding);
        var slot_y = inv_y + row * (slot_size + padding);
        var slot_index = oPlayer.hotbar_size + i;
        
        if (point_in_rectangle(mx, my, slot_x, slot_y, slot_x + slot_size, slot_y + slot_size)) {
            var inv_item = oPlayer.inventory[slot_index];
            
            if (inv_item != noone) {
                if (shift_pressed && mouse_check_button_pressed(mb_left)) {
                    // ===== SHIFT + LEFT CLICK: MOVE FULL STACK =====
                    var moved = false;
                    
                    // Try stacking in chest
                    for (var j = 0; j < array_length(inventory); j++) {
                        var chest_item = inventory[j];
                        if (chest_item != noone && chest_item.name == inv_item.name) {
                            // Found matching item in chest, stack them
                            chest_item.count += inv_item.count;
                            oPlayer.inventory[slot_index] = noone;
                            moved = true;
                            show_debug_message("Moved full stack from inventory to chest slot " + string(j));
                            break;
                        }
                    }
                    
                    // If not stacked, find empty slot
                    if (!moved) {
                        for (var j = 0; j < array_length(inventory); j++) {
                            if (inventory[j] == noone) {
                                // Found empty chest slot
                                inventory[j] = item_create(inv_item.name, inv_item.count);
                                oPlayer.inventory[slot_index] = noone;
                                moved = true;
                                show_debug_message("Moved full stack to empty chest slot " + string(j));
                                break;
                            }
                        }
                        
                        if (!moved) {
                            show_debug_message("Chest full - could not move full stack");
                        }
                    }
                } else if (shift_pressed && mouse_check_button_pressed(mb_right)) {
                    // ===== SHIFT + RIGHT CLICK: MOVE SINGLE ITEM =====
                    var moved = false;
                    
                    // Try stacking in chest
                    for (var j = 0; j < array_length(inventory); j++) {
                        var chest_item = inventory[j];
                        if (chest_item != noone && chest_item.name == inv_item.name) {
                            // Need to check max stack size
                            var max_stack = chest_item.data.max_stack;
                            if (chest_item.count < max_stack) {
                                // There's room in the stack
                                chest_item.count += 1;
                                inv_item.count -= 1;
                                moved = true;
                                
                                // Remove inventory item if emptied
                                if (inv_item.count <= 0) {
                                    oPlayer.inventory[slot_index] = noone;
                                }
                                
                                show_debug_message("Added single item to existing chest stack");
                                break;
                            }
                        }
                    }
                    
                    // If not stacked, find empty slot
                    if (!moved) {
                        for (var j = 0; j < array_length(inventory); j++) {
                            if (inventory[j] == noone) {
                                // Found empty chest slot
                                inventory[j] = item_create(inv_item.name, 1);
                                inv_item.count -= 1;
                                
                                // Remove inventory item if emptied
                                if (inv_item.count <= 0) {
                                    oPlayer.inventory[slot_index] = noone;
                                }
                                
                                moved = true;
                                show_debug_message("Moved single item to empty chest slot " + string(j));
                                break;
                            }
                        }
                        
                        if (!moved) {
                            show_debug_message("Chest full - could not move single item");
                        }
                    }
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
            var x_pos = chest_x + col * (slot_size + padding);
            var y_pos = chest_y + row * (slot_size + padding);
            if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
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
            var x_pos = chest_x + col * (slot_size + padding);
            var y_pos = chest_y + row * (slot_size + padding);
            if (point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size)) {
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