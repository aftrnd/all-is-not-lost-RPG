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
	if (place_meeting(x + hspd, y, oWall)) {
		// Move as close as possible to the wall
		while (!place_meeting(x + sign(hspd), y, oWall)) {
			x += sign(hspd);
		}
		hspd = 0;
	}
	
	// Apply horizontal movement
	x += hspd;
	
	// Vertical Collision Check
	if (place_meeting(x, y + vspd, oWall)) {
		// Move as close as possible to the wall
		while (!place_meeting(x, y + sign(vspd), oWall)) {
			y += sign(vspd);
		}
		vspd = 0;
	}
	
	// Apply vertical movement
	y += vspd;
	
	// Update player coordinates for UI display
	playerX = floor(x);
	playerY = floor(y);
	
	// Change state if activation key pressed
	if (keyActivate) {
		state = player_state_frozen;
	}
	
	// PLAYER ANIMATION
	image_speed = 1;
	
	// If moving, play walking animation
	if (hspd != 0 || vspd != 0) {
		sprite_index = sPlayerRunning; // Assuming you have a running sprite
	} else {
		sprite_index = sPlayer; // Idle sprite
	}
	
	// Flip sprite based on horizontal movement
	if (hspd != 0) {
		image_xscale = sign(hspd);
	}
	
	// For RPG style, you might want to add directional sprites later
	// This would replace the simple left/right flip above
	// Example logic (comment out for now until you have directional sprites):
	/*
	// Determine sprite based on facing direction
	if (abs(hspd) > 0 || abs(vspd) > 0) {
		// Only change facing when moving
		if (facing_direction >= 45 && facing_direction < 135) {
			// Facing down
			sprite_index = sPlayerDown;
		} else if (facing_direction >= 135 && facing_direction < 225) {
			// Facing left
			sprite_index = sPlayerLeft;
		} else if (facing_direction >= 225 && facing_direction < 315) {
			// Facing up
			sprite_index = sPlayerUp;
		} else {
			// Facing right
			sprite_index = sPlayerRight;
		}
	}
	*/
}

