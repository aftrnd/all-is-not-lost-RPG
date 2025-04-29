/// @description Checking Window Resolution

global.window_width = window_get_width();
global.window_height = window_get_height();

// Checks size of WINDOW every frame...
surface_resize(application_surface, global.window_width, global.window_height);

// Adjust scaling if display is larger than 1080p
if(global.window_width >= 1920)
{
	camera_scale = 0.25;
} else {
	camera_scale = 0.50;
}

// Fullscreen Shortcut
if(keyboard_check_pressed(ord("Z")))
{
	window_set_fullscreen(true);
}

if(keyboard_check_pressed(ord("X")))
{
	window_set_fullscreen(false);
}