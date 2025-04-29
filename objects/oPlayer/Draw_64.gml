/// @description Debug & Version UI
// You can write your code in this editor

if(drawDebugMenu = true)
{
	draw_set_colour(c_black);
	draw_set_alpha(0.45);
	draw_roundrect_ext(10, 10, 435, 120, 25, 25, 0);
	draw_set_alpha(1);
	
	// GET WINDOW RESOLUTION
	var _strX = string(global.window_width);
	var _strY = string(global.window_height);
	
	// DEBUG WINDOW POSITION
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_red);
	draw_text(20, 16, "DEVELOPER DEBUG");
	draw_set_colour(c_white);  
	draw_text_transformed(20, 48, "Coordinates X:" + _strX + "px" + " Y:" + _strY + "px", 1, 1, 0);

	// DEBUG WINDOW ALIGNMENT
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

// HOT BAR
var slot_w = 64;
var slot_h = 32;
var padding = 4;

for (var i = 0; i < hotbar_size; i++) {
    var x_pos = 32 + i * (slot_w + padding);
    var y_pos = display_get_gui_height() - slot_h - 16;

    draw_set_color(c_black);
    draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, false);

    if (inventory[i] != noone) {
    var item = inventory[i];
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var center_x = x_pos + slot_w / 2;
    var center_y = y_pos + slot_h / 2;

    draw_text(center_x, center_y, item.name + " x" + string(item.count));

    draw_set_halign(fa_left);   // Reset after use
    draw_set_valign(fa_top);
    }
}