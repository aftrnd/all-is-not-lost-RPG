/// @description Camera, Window & Scale logic
// You can write your code in this editor

#macro view view_camera[0]
camera_set_view_size(view, global.window_width * camera_scale, global.window_height * camera_scale);


if(instance_exists(oPlayer))
{
	var _x = oPlayer.x - (global.window_width * camera_scale) / 2;
	var _y = clamp(oPlayer.y - (global.window_height * camera_scale) / 2, 0, room_height - (global.window_height* camera_scale));
	//var _y = oPlayer.y - global.window_height / 2;
	
	var _current_x = camera_get_view_x(view);
	var _current_y = camera_get_view_y(view);
	
	var _camera_speed = 0.1;
	
	// camera_set_view_pos(view, _current_x, _current_y)
	camera_set_view_pos(view, lerp(_current_x, _x, _camera_speed), lerp(_current_y, _y, _camera_speed));
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
