/// @desc oPlayer - GUI
// You can write your code in this editor

#region Variables
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
#endregion

#region Debug Menu
if(drawDebugMenu = true)
{
	draw_set_colour(c_black);
	draw_set_alpha(0.45);
	draw_roundrect_ext(10, 10, 435, 120, 25, 25, 0);
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
	
}
#endregion

#region Hotbar
draw_set_font(fnt_body);

var slot_size = 48; // Smaller slots to match chest UI
var padding = 6;
var border = 2;
var corner_radius = 8; // Consistent corner radius
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

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
    
    // Inner border when hovered or selected
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