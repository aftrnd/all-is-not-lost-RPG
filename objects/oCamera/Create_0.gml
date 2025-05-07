/// @Resolution& Camera Management
// You can write your code in this editor

// Default windowed resolution (Window resolution = viewport resolution)
default_resolution_width = 960;
default_resolution_height = 540;

camera_scale = 1;

// Camera position and dimension variables (source of truth)
global.camera_view = view_camera[0];
global.camera_x = 0;
global.camera_y = 0;
global.camera_width = default_resolution_width * camera_scale;
global.camera_height = default_resolution_height * camera_scale;

// Set window size and center it on the monitor
window_set_size(default_resolution_width, default_resolution_height);
display_width = display_get_width();
display_height = display_get_height();
window_set_position(
    (display_width - default_resolution_width) div 2,
    (display_height - default_resolution_height) div 2
);

// Apply camera view settings
camera_set_view_size(global.camera_view, global.camera_width, global.camera_height);