/// @desc oPlayer - GUI
// You can write your code in this editor

#region Variables
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var mx_room = mouse_x;
var my_room = mouse_y;

// UI dimensions
var slot_size = 48;
var padding = 8;    // Increased padding for more space between elements
var border = 1;     // Border thickness reduced to 1px
var corner_radius = 16;
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
#endregion

#region Trigger Toggle Message
// Display the trigger toggle message if timer is active
if (trigger_toggle_timer > 0) {
    // Store original drawing properties
    var orig_font = draw_get_font();
    var orig_halign = draw_get_halign();
    var orig_valign = draw_get_valign();
    var orig_color = draw_get_color();
    var orig_alpha = draw_get_alpha();
    
    // Setup text drawing
    draw_set_font(fnt_body);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Calculate alpha based on timer (fade out effect)
    var alpha = min(1, trigger_toggle_timer / 30);
    draw_set_alpha(alpha);
    
    // Draw text shadow for better visibility
    draw_set_color(c_black);
    draw_text(gui_width/2 + 2, gui_height/3 + 2, trigger_toggle_message);
    
    // Draw the actual text
    draw_set_color(trigger_toggle_color);
    draw_text(gui_width/2, gui_height/3, trigger_toggle_message);
    
    // Decrease timer
    trigger_toggle_timer--;
    
    // Restore original drawing properties
    draw_set_font(orig_font);
    draw_set_halign(orig_halign);
    draw_set_valign(orig_valign);
    draw_set_color(orig_color);
    draw_set_alpha(orig_alpha);
}
#endregion

#region Debug Menu
if(drawDebugMenu = true)
{
	// Store original drawing properties to restore later
	var orig_font = draw_get_font();
	var orig_halign = draw_get_halign();
	var orig_valign = draw_get_valign();
	var orig_color = draw_get_color();
	var orig_alpha = draw_get_alpha();
	
	// Calculate debug menu height based on content
	var debug_height = 120;  // Base height for initial content
	var ui_height = 16 * 3;  // UI flags (inventory, chest, sign)
	var activity_height = 16 * 3;  // Activity section (header + 2 items)
	var bottom_padding = 20;  // Extra padding at the bottom
	var log_height = 0;
	
	if (ds_list_size(debug_logs) > 0) {
		var visible_logs = min(ds_list_size(debug_logs), debug_log_max);
		log_height = visible_logs * 16 + 16 + 30; // 16px per line + header + title bar + extra space
	}
	
	debug_height = debug_height + ui_height + activity_height + log_height + bottom_padding;
	
	// Position at bottom left of screen with consistent padding
	var gui_width = display_get_gui_width();
	var gui_height = display_get_gui_height();
	var padding = 10; // Common padding value
	var debug_x = padding;
	var debug_y = gui_height - debug_height - padding; // padding from bottom
	var debug_width = 425;
	
	// Main debug background
	draw_set_colour(c_black);
	draw_set_alpha(0.70);
	draw_roundrect_ext(debug_x, debug_y, debug_x + debug_width, debug_y + debug_height, 25, 25, 0);
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
	draw_text(debug_x + padding, debug_y + 16, "DEVELOPER DEBUG");
	draw_set_colour(c_white);  
	draw_text_transformed(debug_x + padding, debug_y + 48, "Coordinates X:" + _strPlayerX + "px" + " Y:" + _strPlayerY + "px", 1, 1, 0);

	// WINDOW SIZE
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white); 
	draw_text_transformed(debug_x + padding, debug_y + 64, "Window Size: Width - " + _strX + "px, " +  "Height - " +_strY + "px", 1, 1, 0);
	
	// PLAYER STATE
	var _playerState = global.stateName;

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white); 
	draw_text_transformed(debug_x + padding, debug_y + 82, "Player State: " +  _playerState, 1, 1, 0);
	
	// DEBUG SETTINGS
	draw_set_colour(c_yellow);
	draw_text(debug_x + padding, debug_y + 100, "Debug Settings:");

	// Show triggers toggle
	var toggle_color = debug_setting_get("show_triggers") ? c_lime : c_red;
	var toggle_status = debug_setting_get("show_triggers") ? "[ON]" : "[OFF]";
	draw_set_colour(toggle_color);
	draw_text(debug_x + padding + 10, debug_y + 118, "Show Triggers: " + toggle_status);
	
	// Draw a toggle button beside the text
	var button_x = debug_x + padding + 180;
	var button_y = debug_y + 118;
	var button_width = 30;
	var button_height = 16;
	
	// Draw button background
	draw_set_alpha(0.8);
	draw_rectangle_color(
	    button_x, button_y,
	    button_x + button_width, button_y + button_height,
	    toggle_color, toggle_color, toggle_color, toggle_color,
	    false
	);
	
	// Draw button outline
	draw_set_alpha(1.0);
	draw_rectangle_color(
	    button_x, button_y,
	    button_x + button_width, button_y + button_height,
	    c_white, c_white, c_white, c_white,
	    true
	);
	
	// Draw button text
	draw_set_color(c_black);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(button_x + button_width / 2, button_y + button_height / 2, toggle_status);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);

	// Mouse interactions for toggles
	if (mouse_check_button_pressed(mb_left)) {
		// Check if clicked on show_triggers toggle or button
		if (point_in_rectangle(mx, my, debug_x + padding + 10, debug_y + 118, debug_x + padding + 200, debug_y + 134) ||
		    point_in_rectangle(mx, my, button_x, button_y, button_x + button_width, button_y + button_height)) {
			// Get current value
			var current = debug_setting_get("show_triggers");
			
			// Toggle directly using struct variable
			var new_value = !current;
			variable_struct_set(global.debug_settings, "show_triggers", new_value);
			
			// Show toggle message
			var status = new_value ? "ON" : "OFF";
            var color = new_value ? c_lime : c_red;
            trigger_toggle_message = "Room Triggers: " + status;
            trigger_toggle_color = color;
            trigger_toggle_timer = 90;
            
            // Force update all room trigger objects
            with (oUtilityRoomTrigger) {
                visible = global.debug_mode && global.debug_settings.show_triggers;
            }
		}
	}
	
	// UI STATES
	draw_set_colour(c_yellow);
	draw_text(debug_x + padding, debug_y + 136, "UI State Flags:");
	draw_set_colour(c_white);
	
	var ui_y = debug_y + 154;
	// Player inventory state
	var inv_color = inventory_open ? c_lime : c_gray;
	draw_set_colour(inv_color);
	draw_text(debug_x + padding + 10, ui_y, "Inventory Open: " + string(inventory_open));
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
	draw_text(debug_x + padding + 10, ui_y, "Chest Open: " + string(chest_ui_open));
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
	draw_text(debug_x + padding + 10, ui_y, "Reading Sign: " + string(sign_ui_open) + (sign_ui_open ? " (ID: " + sign_id + ")" : ""));
	ui_y += 16;
	
	// RECENT ACTIVITIES
	ui_y += 8; // Extra spacing
	draw_set_colour(c_yellow);
	draw_text(debug_x + padding, ui_y, "Recent Activities:");
	ui_y += 16;
	
	// Last item pickup
	draw_set_colour(c_fuchsia);
	var pickup_ago = "";
	if (pickup_time > 0) {
		pickup_ago = " (" + string((current_time - pickup_time) div 1000) + "s ago)";
	}
	draw_text(debug_x + padding + 10, ui_y, "Last Item: " + last_pickup + pickup_ago);
	ui_y += 16;
	
	// Last sign interaction
	draw_set_colour(c_orange);
	var sign_ago = "";
	if (sign_time > 0) {
		sign_ago = " (" + string((current_time - sign_time) div 1000) + "s ago)";
	}
	draw_text(debug_x + padding + 10, ui_y, "Last Sign: " + last_sign + sign_ago);
	ui_y += 16;
	
	// CONSOLE LOGS
	if (ds_list_size(debug_logs) > 0) {
		var log_top = ui_y + 8; // Additional spacing
		
		// Console header
		draw_set_colour(c_yellow);
		draw_text(debug_x + padding, log_top, "Console Log:");
		log_top += 16;
		
		// Calculate console dimensions to ensure it fits within the debug window
		var console_width = debug_width - (padding * 2);
		var visible_logs = min(ds_list_size(debug_logs), debug_log_max);
		var console_height = (visible_logs * 16) + 24; // Log entries + title bar + small padding
		
		// Draw console background (terminal-like)
		draw_set_alpha(0.8);
		draw_set_colour(c_black);
		draw_roundrect_ext(
			debug_x + padding, 
			log_top, 
			debug_x + padding + console_width, 
			log_top + console_height, 
			10, 10, false
		);
		draw_set_alpha(0.7);
		draw_set_colour(c_dkgray);
		draw_roundrect_ext(
			debug_x + padding, 
			log_top, 
			debug_x + padding + console_width, 
			log_top + console_height,
			10, 10, true
		);
		draw_set_alpha(1);
		
		// Draw console title bar
		draw_set_alpha(0.9);
		draw_set_colour(make_color_rgb(50, 50, 60));
		draw_rectangle(
			debug_x + padding, 
			log_top, 
			debug_x + padding + console_width, 
			log_top + 18, 
			false
		);
		draw_set_alpha(1);
		draw_set_colour(c_white);
		draw_set_halign(fa_center);
		draw_text(debug_x + padding + (console_width / 2), log_top + 5, "GAME CONSOLE");
		draw_set_halign(fa_left);
		
		// Adjust log start position after title bar
		log_top += 20;
		
		// Draw console logs with prompt and timestamp (oldest to newest, top to bottom)
		for (var i = 0; i < visible_logs; i++) {
			// i=0 is oldest log, get proper index from our lists
			var log_index = i;
			var log_message = ds_list_find_value(debug_logs, log_index);
			var log_color = ds_list_find_value(debug_log_colors, log_index);
			
			// Get the actual timestamp from our list
			var _timeMS = ds_list_find_value(debug_log_times, log_index);
			var _mins = string(_timeMS div 60000);
			var _secs = string((_timeMS div 1000) mod 60);
			
			// Pad with zeros
			if (string_length(_mins) < 2) _mins = "0" + _mins;
			if (string_length(_secs) < 2) _secs = "0" + _secs;
			
			var _timestamp = _mins + ":" + _secs;
			
			// Draw timestamp and prompt
			draw_set_colour(c_gray);
			draw_text(debug_x + padding + 5, log_top + (i * 16), "[" + _timestamp + "] >");
			
			// Draw the actual message
			draw_set_colour(log_color);
			draw_text(debug_x + padding + 70, log_top + (i * 16), log_message);
		}
	}
	
	// Draw cursor debug info - only shown when debug menu is open
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_yellow);
	draw_line(mx-15, my, mx+15, my);  // Horizontal line
	draw_line(mx, my-15, mx, my+15);  // Vertical line
	draw_text(mx+20, my, "GUI: " + string(mx) + "," + string(my));
	draw_text(mx+20, my+20, "Room: " + string(mx_room) + "," + string(my_room));
	draw_text(mx+20, my+40, "Click: " + string(mouse_check_button(mb_left)));
	
	// Restore original drawing properties
	draw_set_font(orig_font);
	draw_set_halign(orig_halign);
	draw_set_valign(orig_valign);
	draw_set_color(orig_color);
	draw_set_alpha(orig_alpha);
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
    
    // Define title area height - consistent with chest inventory
    var title_area_height = 30;
    
    // Draw inventory background (filled)
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_roundrect_ext(
        inv_x - padding,
        inv_y - padding - title_area_height, // Extra space for title
        inv_x + inv_width + padding,
        inv_y + inv_height + padding,
        corner_radius,
        corner_radius,
        false
    );
    
    // Draw inventory border (outline only - maintains 1px when scaled)
    draw_set_alpha(0.8);
    draw_set_color(c_dkgray);
    draw_roundrect_ext(
        inv_x - padding,
        inv_y - padding - title_area_height, // Extra space for title
        inv_x + inv_width + padding,
        inv_y + inv_height + padding,
        corner_radius,
        corner_radius,
        true
    );
    
    draw_set_alpha(1);
    
    // Draw title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    // Position text exactly in the middle of the title area
    var title_y = inv_y - title_area_height/2;
    draw_text(inv_x + inv_width / 2, title_y, "Player Inventory");
    
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
        
        // Draw slot background
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, 
                          corner_radius/2, corner_radius/2, false);
        
        // Draw slot border (outline only - maintains 1px when scaled)
        draw_set_alpha(0.9);
        if (is_hovered) {
            draw_set_color(c_white); // White border when hovered
        } else {
            draw_set_color(c_dkgray); // Dark gray border normally
        }
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, 
                          corner_radius/2, corner_radius/2, true);
        
        draw_set_alpha(1);
        
        // Draw item
        if (inventory[slot_index] != noone) {
            var item = inventory[slot_index];
            var icon = item.data.icon;
            
            // Get sprite dimensions
            var spr_w = sprite_get_width(icon);
            var spr_h = sprite_get_height(icon);
            
            // Calculate integer scaling factor for pixel-perfect rendering
            var scale = floor((slot_size - padding) / max(spr_w, spr_h));
            
            // Center the sprite in the slot
            var icon_x = x_pos + floor((slot_size - spr_w * scale) / 2);
            var icon_y = y_pos + floor((slot_size - spr_h * scale) / 2);
            
            // Draw with pixel-perfect alignment
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
// Save the drawing properties before drawing the hotbar
var h_font = draw_get_font();
var h_halign = draw_get_halign();
var h_valign = draw_get_valign();
var h_color = draw_get_color();
var h_alpha = draw_get_alpha();

// Reset to default values
draw_set_font(fnt_body);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1.0);

// Calculate hotbar dimensions
var hotbar_width = (slot_size + padding) * hotbar_size - padding;
var hotbar_x = (gui_width - hotbar_width) / 2; // Center hotbar
var hotbar_y = gui_height - slot_size - 20;

// Draw hotbar background (single filled rectangle)
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

// Draw hotbar border (outline only - maintains 1px when scaled)
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

    // Draw slot background
    if (is_selected) {
        // Selected slot - black background with yellow outline
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, false);
        
        // Yellow border (outline only - maintains 1px when scaled)
        draw_set_alpha(0.9);
        draw_set_color(c_yellow);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, true);
    } else if (is_hovered) {
        // Hovered slot - black background with white outline
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, false);
        
        // White border (outline only - maintains 1px when scaled)
        draw_set_alpha(0.9);
        draw_set_color(c_white);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, true);
    } else {
        // Normal slot - black background with dark gray outline
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, false);
        
        // Dark gray border (outline only - maintains 1px when scaled)
        draw_set_alpha(0.9);
        draw_set_color(c_dkgray);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, true);
    }
    
    draw_set_alpha(1);

    // Draw item
    if (inventory[i] != noone) {
        var item = inventory[i];
        var icon = item.data.icon;
        
        // Get sprite dimensions
        var spr_w = sprite_get_width(icon);
        var spr_h = sprite_get_height(icon);
        
        // Calculate integer scaling factor for pixel-perfect rendering
        var scale = floor((slot_size - padding) / max(spr_w, spr_h));
        
        // Center the sprite in the slot
        var icon_x = x_pos + floor((slot_size - spr_w * scale) / 2);
        var icon_y = y_pos + floor((slot_size - spr_h * scale) / 2);
        
        // Draw with pixel-perfect alignment
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

// Restore original drawing properties
draw_set_font(h_font);
draw_set_halign(h_halign);
draw_set_valign(h_valign);
draw_set_color(h_color);
draw_set_alpha(h_alpha);
#endregion

#region Dragged Item
if (dragging_item != noone && is_struct(dragging_item)) {
    var item = dragging_item;
    var icon = item.data.icon;
    
    // Get sprite dimensions
    var spr_w = sprite_get_width(icon);
    var spr_h = sprite_get_height(icon);
    
    // Calculate integer scaling factor for pixel-perfect rendering
    var scale = floor((slot_size - padding) / max(spr_w, spr_h));
    
    // Center the sprite under the mouse
    var draw_x = mx - floor((spr_w * scale) / 2);
    var draw_y = my - floor((spr_h * scale) / 2);
    
    // Draw with pixel-perfect alignment
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