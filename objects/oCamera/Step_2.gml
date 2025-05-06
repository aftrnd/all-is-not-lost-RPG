/// @description Camera, Window & Scale logic
// You can write your code in this editor

#macro view view_camera[0]
global.camera_view = view;

// Update camera size based on window and scale
global.camera_width = global.window_width * camera_scale;
global.camera_height = global.window_height * camera_scale;
camera_set_view_size(global.camera_view, global.camera_width, global.camera_height);

if(instance_exists(oPlayer))
{
	// Calculate target camera position centered on player
	var target_x = oPlayer.x - (global.camera_width / 2);
	var target_y = clamp(oPlayer.y - (global.camera_height / 2), 0, room_height - global.camera_height);
	
	// Get current camera position
	var current_x = camera_get_view_x(global.camera_view);
	var current_y = camera_get_view_y(global.camera_view);
	
	// Smooth camera movement with lerp
	var camera_speed = 0.1;
	var new_x = lerp(current_x, target_x, camera_speed);
	var new_y = lerp(current_y, target_y, camera_speed);
	
	// Set the camera position
	camera_set_view_pos(global.camera_view, new_x, new_y);
	
	// Store camera position in globals (source of truth)
	global.camera_x = camera_get_view_x(global.camera_view);
	global.camera_y = camera_get_view_y(global.camera_view);
}

///// @description Camera, Window & Scale logic
//// You can write your code in this editor

//#macro view view_camera[0]
//camera_set_view_size(view, global.window_width * camera_scale, global.window_height * camera_scale);


//if(instance_exists(oPlayer))
//{
//	var _x = clamp(oPlayer.x - (global.window_width * camera_scale) / 2, 0, room_width - (global.window_width * camera_scale));
//	var _y = clamp(oPlayer.y - (global.window_height * camera_scale) / 2, 0, room_height - (global.window_height* camera_scale));
//	//var _y = oPlayer.y - global.window_height / 2;
	
//	var _current_x = camera_get_view_x(view);
//	var _current_y = camera_get_view_y(view);
	
//	var _camera_speed = 0.1;
	
//	// camera_set_view_pos(view, _current_x, _current_y)
//	camera_set_view_pos(view, lerp(_current_x, _x, _camera_speed), lerp(_current_y, _y, _camera_speed));
//}
