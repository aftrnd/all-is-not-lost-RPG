
function player_state_default(){
	// PLAYER'S DEFAULT MOVEMENT
	
	//Set a debug state name
	global.stateName = "Default";
	
	// Set default sprite for this state
	sprite_index = spriteDefault;
	
	// Moving horizontally
	// This is what modifies the Player's CURRENT speed (this is NOT walkingSpeed)
	horizontalSpeed  = (keyRight - keyLeft) * walkingSpeed;
	

	// Simple gravity logic
	verticalSpeed = verticalSpeed + playerGravity;

	// Can the player jump?
	if (allowJump-- > 0) && (keyJump)
	{
		verticalSpeed = jumpSpeed;
		allowJump = 0;
	}

	/// Moving the Player horizontally
	// x & y are simply the Player's current position
	if (place_meeting(x + horizontalSpeed, y, oWall))
	{
		while (abs(horizontalSpeed) > 1) // abs is absolute value of input argument (Positive is positive / Negative becomes positive)
		{
			horizontalSpeed *= 0.5; // Cut movement speed in half
			if (!place_meeting(x + horizontalSpeed, y, oWall)) x += horizontalSpeed;
		}
		horizontalSpeed = 0;
	}
	x += horizontalSpeed; // Change the CURRENT horizontal speed

	// Moving the player vertically (with gravity)
	if (place_meeting(x, y + verticalSpeed, oWall))
	{
		if (verticalSpeed > 0) allowJump = 5; // Buffer alowing jump to still occure
		while (abs(verticalSpeed) > 1)
		{
			verticalSpeed *= 0.5;
			if (!place_meeting(x, y + verticalSpeed, oWall)) y += verticalSpeed;
		}
		verticalSpeed = 0;
	}
	y += verticalSpeed;  // Change the CURRENT vertical speed
	
	// Change state
	if(keyActivate) // Using the 'E' button set in oPlayer STEP event 
	{
		state = player_state_frozen;
	}
	
	//PLAYER ANIMATION
	//Controlls player's animation in the air while falling or jumping
	if (!place_meeting(x, y + 1, oWall))
	{
		sprite_index = sPlayerAir;
		image_speed = 0;
		if (sign(verticalSpeed) > 0) image_index = 1; else image_index = 0;
	
	}
	// Controlls player's idle or running animation
	else
	{
		image_speed = 1;
		if (horizontalSpeed == 0)
		{
			sprite_index = sPlayer;
		}
		else
		{
			sprite_index = sPlayerRunning;
		}
	}

	// Flips sprite horizontally based on direction/key
	if (horizontalSpeed != 0) image_xscale = sign(horizontalSpeed);

}

