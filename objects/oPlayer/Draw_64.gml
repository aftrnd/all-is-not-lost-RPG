/// @desc oPlayer - GUI
// You can write your code in this editor

#region Variables
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// UI dimensions
var slot_size = 48;
var padding = 6;
var border = 2;
var corner_radius = 8;
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
#endregion

#region Debug Menu
if(drawDebugMenu = true)
{
	// Calculate debug menu height based on content
	var debug_height = 120;  // Base height for initial content
	var ui_height = 16 * 3;  // UI flags (inventory, chest, sign)
	var activity_height = 16 * 3;  // Activity section (header + 2 items)
	var log_height = 0;
	
	if (ds_list_size(debug_logs) > 0) {
		log_height = min(ds_list_size(debug_logs), debug_log_max) * 16 + 16; // 16px per line + padding
	}
	
	debug_height = debug_height + ui_height + activity_height + log_height;
	
	draw_set_colour(c_black);
	draw_set_alpha(0.45);
	draw_roundrect_ext(10, 10, 435, 10 + debug_height, 25, 25, 0);
	draw_set_alpha(1);
	
	// GET WINDOW RESOLUTION
	var _strX = string(global.window_width);
	var _strY = string(global.window_height);
    
    var _strPlayerX = string(playerX);
    var _strPlayerY = string(playerY);
	
	// PLAYER POSITION
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_red);
	draw_text(20, 16, "DEVELOPER DEBUG");
	draw_set_colour(c_white);  
	draw_text_transformed(20, 48, "Coordinates X:" + _strPlayerX + "px" + " Y:" + _strPlayerY + "px", 1, 1, 0);

	// WINDOW SIZE
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white); 
	draw_text_transformed(20, 64, "Window Size: Width - " + _strX + "px, " +  "Height - " +_strY + "px", 1, 1, 0);
	
	// PLAYER STATE
	var _playerState = global.stateName;

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white); 
	draw_text_transformed(20, 82, "Player State: " +  _playerState, 1, 1, 0);
	
	// UI STATES
	draw_set_colour(c_yellow);
	draw_text(20, 100, "UI State Flags:");
	draw_set_colour(c_white);
	
	var ui_y = 118;
	// Player inventory state
	var inv_color = inventory_open ? c_lime : c_gray;
	draw_set_colour(inv_color);
	draw_text(30, ui_y, "Inventory Open: " + string(inventory_open));
	ui_y += 16;
	
	// Check if any chest UI is open
	var chest_ui_open = false;
	var chest_count = instance_number(oChest);
	for (var i = 0; i < chest_count; i++) {
		var chest_obj = instance_find(oChest, i);
		if (chest_obj != noone && chest_obj.ui_open) {
			chest_ui_open = true;
			break;
		}
	}
	var chest_color = chest_ui_open ? c_lime : c_gray;
	draw_set_colour(chest_color);
	draw_text(30, ui_y, "Chest Open: " + string(chest_ui_open));
	ui_y += 16;
	
	// Check if any sign textbox is open
	var sign_ui_open = false;
	var sign_id = "";
	var sign_count = instance_number(oSign);
	for (var i = 0; i < sign_count; i++) {
		var sign_obj = instance_find(oSign, i);
		if (sign_obj != noone && variable_instance_exists(sign_obj, "show_textbox") && sign_obj.show_textbox) {
			sign_ui_open = true;
			sign_id = sign_obj.text_id;
			break;
		}
	}
	var sign_color = sign_ui_open ? c_lime : c_gray;
	draw_set_colour(sign_color);
	draw_text(30, ui_y, "Reading Sign: " + string(sign_ui_open) + (sign_ui_open ? " (ID: " + sign_id + ")" : ""));
	ui_y += 16;
	
	// RECENT ACTIVITIES
	ui_y += 8; // Extra spacing
	draw_set_colour(c_yellow);
	draw_text(20, ui_y, "Recent Activities:");
	ui_y += 16;
	
	// Last item pickup
	draw_set_colour(c_fuchsia);
	var pickup_ago = "";
	if (pickup_time > 0) {
		pickup_ago = " (" + string((current_time - pickup_time) div 1000) + "s ago)";
	}
	draw_text(30, ui_y, "Last Item: " + last_pickup + pickup_ago);
	ui_y += 16;
	
	// Last sign interaction
	draw_set_colour(c_orange);
	var sign_ago = "";
	if (sign_time > 0) {
		sign_ago = " (" + string((current_time - sign_time) div 1000) + "s ago)";
	}
	draw_text(30, ui_y, "Last Sign: " + last_sign + sign_ago);
	ui_y += 16;
	
	// CONSOLE LOGS
	if (ds_list_size(debug_logs) > 0) {
		var log_top = 10 + debug_height - log_height;
		draw_set_colour(c_yellow);
		draw_text(20, log_top, "Console Log:");
		
		for (var i = 0; i < min(ds_list_size(debug_logs), debug_log_max); i++) {
			draw_set_colour(ds_list_find_value(debug_log_colors, i));
			draw_text(30, log_top + 16 + (i * 16), ds_list_find_value(debug_logs, i));
		}
	}
}
#endregion

#region Player Inventory
if (inventory_open) {
    draw_set_font(fnt_body);
    
    // Calculate inventory dimensions
    var inv_cols = 5;
    var inv_rows = ceil(inventory_size / inv_cols);
    var inv_width = (slot_size + padding) * inv_cols - padding;
    var inv_height = (slot_size + padding) * inv_rows - padding;
    
    // Center the inventory on screen
    var inv_x = (gui_width - inv_width) / 2;
    var inv_y = (gui_height - inv_height) / 2 - 30; // Slightly above center
    
    // Draw inventory background
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_roundrect_ext(
        inv_x - padding * 2,
        inv_y - padding * 2 - 30, // Extra space for title
        inv_x + inv_width + padding * 2,
        inv_y + inv_height + padding * 2,
        corner_radius,
        corner_radius,
        false
    );
    
    // Add a subtle border
    draw_set_alpha(0.8);
    draw_set_color(c_dkgray);
    draw_roundrect_ext(
        inv_x - padding * 2,
        inv_y - padding * 2 - 30,
        inv_x + inv_width + padding * 2,
        inv_y + inv_height + padding * 2,
        corner_radius,
        corner_radius,
        true
    );
    draw_set_alpha(1);
    
    // Draw title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(inv_x + inv_width / 2, inv_y - 15, "Player Inventory");
    
    // Draw inventory slots
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    for (var i = 0; i < inventory_size; i++) {
        var row = i div inv_cols;
        var col = i mod inv_cols;
        
        var x_pos = inv_x + col * (slot_size + padding);
        var y_pos = inv_y + row * (slot_size + padding);
        
        var is_hovered = point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size);
        var slot_index = hotbar_size + i; // Actual inventory index (after hotbar)
        
        // Semi-transparent slot background
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, false);
        
        // Slot border
        draw_set_alpha(0.9);
        draw_set_color(is_hovered ? c_white : c_dkgray);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, true);
        
        // Inner border when hovered
        if (is_hovered) {
            draw_set_alpha(0.7);
            draw_set_color(c_white);
            draw_roundrect_ext(x_pos + border, y_pos + border, x_pos + slot_size - border, y_pos + slot_size - border, corner_radius/2, corner_radius/2, true);
        }
        
        draw_set_alpha(1);
        
        // Draw item
        if (inventory[slot_index] != noone) {
            var item = inventory[slot_index];
            var icon = item.data.icon;
            // Calculate scaling to fit slot
            var spr_w = sprite_get_width(icon);
            var spr_h = sprite_get_height(icon);
            var scale = min((slot_size - padding) / max(spr_w, spr_h), (slot_size - padding) / max(spr_w, spr_h));
            var icon_x = x_pos + (slot_size - spr_w * scale) / 2;
            var icon_y = y_pos + (slot_size - spr_h * scale) / 2;
            draw_sprite_ext(icon, 0, icon_x, icon_y, scale, scale, 0, c_white, 1);
            
            // Draw count with shadow for better readability
            draw_set_color(c_black);
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            draw_text(x_pos + slot_size - padding/2 + 1, y_pos + slot_size - padding/2 + 1, string(item.count));
            
            draw_set_color(c_white);
            draw_text(x_pos + slot_size - padding/2, y_pos + slot_size - padding/2, string(item.count));
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
}
#endregion

#region Hotbar
draw_set_font(fnt_body);

// Calculate hotbar dimensions
var hotbar_width = (slot_size + padding) * hotbar_size - padding;
var hotbar_x = (gui_width - hotbar_width) / 2; // Center hotbar
var hotbar_y = gui_height - slot_size - 20;

// Draw hotbar background
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_roundrect_ext(
    hotbar_x - padding,
    hotbar_y - padding,
    hotbar_x + hotbar_width + padding,
    hotbar_y + slot_size + padding,
    corner_radius,
    corner_radius,
    false
);

// Draw hotbar border
draw_set_alpha(0.8);
draw_set_color(c_dkgray);
draw_roundrect_ext(
    hotbar_x - padding,
    hotbar_y - padding,
    hotbar_x + hotbar_width + padding,
    hotbar_y + slot_size + padding,
    corner_radius,
    corner_radius,
    true
);
draw_set_alpha(1);

for (var i = 0; i < hotbar_size; i++) {
    var x_pos = hotbar_x + i * (slot_size + padding);
    var y_pos = hotbar_y;

    var is_hovered = point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size);
    var is_selected = (variable_instance_exists(id, "selected_slot") && i == selected_slot) || (i == 0 && !variable_instance_exists(id, "selected_slot"));

    // Semi-transparent slot background
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, false);
    
    // Slot border - white if selected or hovered
    draw_set_alpha(0.9);
    if (is_selected) {
        draw_set_color(c_yellow);
    } else {
        draw_set_color(is_hovered ? c_white : c_dkgray);
    }
    draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, true);
    
    // Inner border when hovered and not selected
    if (is_hovered && !is_selected) {
        draw_set_alpha(0.7);
        draw_set_color(c_white);
        draw_roundrect_ext(x_pos + border, y_pos + border, x_pos + slot_size - border, y_pos + slot_size - border, corner_radius/2, corner_radius/2, true);
    }
    
    draw_set_alpha(1);

    // Draw item
    if (inventory[i] != noone) {
        var item = inventory[i];
        var icon = item.data.icon;
        // Calculate scaling to fit slot
        var spr_w = sprite_get_width(icon);
        var spr_h = sprite_get_height(icon);
        var scale = min((slot_size - padding) / max(spr_w, spr_h), (slot_size - padding) / max(spr_w, spr_h));
        var icon_x = x_pos + (slot_size - spr_w * scale) / 2;
        var icon_y = y_pos + (slot_size - spr_h * scale) / 2;
        draw_sprite_ext(icon, 0, icon_x, icon_y, scale, scale, 0, c_white, 1);

        // Draw count with shadow for better readability
        draw_set_color(c_black);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(x_pos + slot_size - padding/2 + 1, y_pos + slot_size - padding/2 + 1, string(item.count));
        
        draw_set_color(c_white);
        draw_text(x_pos + slot_size - padding/2, y_pos + slot_size - padding/2, string(item.count));

        draw_set_halign(fa_left);   // Reset after use
        draw_set_valign(fa_top);
    }
}
#endregion

#region Dragged Item
if (dragging_item != noone && is_struct(dragging_item)) {
    var item = dragging_item;
    var icon = item.data.icon;
    // Calculate scaling to fit slot under mouse
    var spr_w = sprite_get_width(icon);
    var spr_h = sprite_get_height(icon);
    var scale = min((slot_size - padding) / max(spr_w, spr_h), (slot_size - padding) / max(spr_w, spr_h));
    var draw_x = mx - (spr_w * scale / 2);
    var draw_y = my - (spr_h * scale / 2);
    draw_sprite_ext(icon, 0, draw_x, draw_y, scale, scale, 0, c_white, 0.8);

    // Draw count with shadow for better visibility
    draw_set_color(c_black);
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_text(draw_x + spr_w * scale + 1, draw_y + spr_h * scale + 1, string(item.count));
    
    draw_set_color(c_white);
    draw_text(draw_x + spr_w * scale, draw_y + spr_h * scale, string(item.count));

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
#endregion