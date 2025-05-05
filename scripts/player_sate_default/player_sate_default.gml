function player_state_default(){
	// PLAYER'S DEFAULT MOVEMENT - TOP-DOWN RPG STYLE
	
	//Set a debug state name
	global.stateName = "Default";
	
	// Set default sprite for this state
	sprite_index = spriteDefault;
	
	// Get keyboard input
	var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));
	var _left = keyboard_check(vk_left) || keyboard_check(ord("A"));
	var _up = keyboard_check(vk_up) || keyboard_check(ord("W"));
	var _down = keyboard_check(vk_down) || keyboard_check(ord("S"));
	
	// Calculate movement direction and speed
	var _input_h = _right - _left;
	var _input_v = _down - _up; // Note: Y increases downward in GameMaker
	
	// Calculate movement direction if there's input
	if (_input_h != 0 || _input_v != 0) {
		move_direction = point_direction(0, 0, _input_h, _input_v);
		facing_direction = move_direction; // Update facing direction
	}
	
	// Calculate speed (normalize diagonal movement)
	var _input_magnitude = point_distance(0, 0, _input_h, _input_v);
	if (_input_magnitude > 0) {
		// Normalize to ensure diagonal movement isn't faster
		_input_magnitude = min(_input_magnitude, 1.0);
		
		// Calculate horizontal and vertical speeds
		hspd = lengthdir_x(_input_magnitude * move_speed, move_direction);
		vspd = lengthdir_y(_input_magnitude * move_speed, move_direction);
	} else {
		// No input, stop movement
		hspd = 0;
		vspd = 0;
	}
	
	// Horizontal Collision Check
	if (place_meeting(x + hspd, y, oUtilityWall)) {
		// Move as close as possible to the wall
		while (!place_meeting(x + sign(hspd), y, oUtilityWall)) {
			x += sign(hspd);
		}
		hspd = 0;
	}
	
	// Apply horizontal movement
	x += hspd;
	
	// Vertical Collision Check
	if (place_meeting(x, y + vspd, oUtilityWall)) {
		// Move as close as possible to the wall
		while (!place_meeting(x, y + sign(vspd), oUtilityWall)) {
			y += sign(vspd);
		}
		vspd = 0;
	}
	
	// Apply vertical movement
	y += vspd;
	
	// Update player coordinates for UI display
	playerX = floor(x);
	playerY = floor(y);
	
	// PLAYER ANIMATION BASED ON NEW SPRITE ORGANIZATION
	
	// Define direction variables to track last direction
	// 0 = right, 1 = up, 2 = left, 3 = down
	var dir = 0;
	
	// Determine direction based on input or last facing direction
	if (_input_h != 0 || _input_v != 0) {
		// Determine primary direction based on input
		// Priority: down > up > left > right (reverse drawing order)
		if (_right && abs(_input_h) > abs(_input_v)) dir = 0;
		else if (_up && abs(_input_v) >= abs(_input_h)) dir = 1;
		else if (_left && abs(_input_h) > abs(_input_v)) dir = 2;
		else if (_down && abs(_input_v) >= abs(_input_h)) dir = 3;
		
		// Use running animation with direction-specific frames
		sprite_index = sPlayerRunning;
		image_speed = 1;
		
		// Set frame range based on direction (each direction has 8 frames)
		// Right: 0-7, Up: 8-15, Left: 16-23, Down: 24-31
		image_index = dir * 8 + (current_time / 60) % 8;
	} else {
		// Idle animation - use single directional frame from sPlayer
		sprite_index = sPlayer;
		image_speed = 0;
		
		// Determine idle direction from last known facing direction
		if (facing_direction >= 45 && facing_direction < 135) dir = 3; // Down
		else if (facing_direction >= 135 && facing_direction < 225) dir = 2; // Left
		else if (facing_direction >= 225 && facing_direction < 315) dir = 1; // Up
		else dir = 0; // Right
		
		// Select correct idle frame (0: right, 1: up, 2: left, 3: down)
		image_index = dir;
	}
	
	// Reset image_xscale since we're not flipping sprites anymore
	image_xscale = 1;
}

