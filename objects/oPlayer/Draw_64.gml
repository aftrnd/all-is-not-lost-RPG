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

var slot_w = 64;
var slot_h = 32;
var padding = 4;

for (var i = 0; i < hotbar_size; i++) {
    var x_pos = 32 + i * (slot_w + padding);
    var y_pos = display_get_gui_height() - slot_h - 16;

    var is_hovered = point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h);

    // Default black outline only
    draw_set_color(c_black);
    draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, false);

    if (is_hovered) {
        // Step 1: Black fill
        draw_set_color(c_white);
        draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, true);

        // Step 2: Slightly inset white outline
        draw_set_color(c_black);
        draw_rectangle(x_pos + 1, y_pos + 1, x_pos + slot_w - 1, y_pos + slot_h - 1, false);
    }

    // Draw item name
    if (inventory[i] != noone) {
        var item = inventory[i];
        var icon = item.data.icon;
        // Calculate scaling to fit slot
        var spr_w = sprite_get_width(icon);
        var spr_h = sprite_get_height(icon);
        var scale = min((slot_h - padding * 2) / spr_h, (slot_w - padding * 2) / spr_w);
        var icon_x = x_pos + (slot_w - spr_w * scale) / 2;
        var icon_y = y_pos + (slot_h - spr_h * scale) / 2;
        draw_sprite_ext(icon, 0, icon_x, icon_y, scale, scale, 0, c_white, 1);

        // Draw count in bottom right
        draw_set_color(c_white);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(x_pos + slot_w - padding, y_pos + slot_h - padding, string(item.count));

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
    var scale = min((slot_h - padding * 2) / spr_h, (slot_w - padding * 2) / spr_w);
    var draw_x = mx - spr_w * scale / 2;
    var draw_y = my - spr_h * scale / 2;
    draw_sprite_ext(icon, 0, draw_x, draw_y, scale, scale, 0, c_white, 0.6);

    // Draw count at bottom right of icon
    draw_set_color(c_white);
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_text(draw_x + spr_w * scale, draw_y + spr_h * scale, string(item.count));

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
#endregion