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

	// BUILD VERSION
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_set_colour(c_white); 
	draw_text(global.window_width -20, global.window_height - 10, "0.3.1 Pre-Alpha");
