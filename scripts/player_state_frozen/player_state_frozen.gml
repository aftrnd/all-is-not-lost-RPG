// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function player_state_frozen(){
	
	// THIS IS A TEST STATE. THIS ONLY CHANGES THE SPRITE! + Gravity...
	
	// Set a debug state name
	global.stateName = "Frozen!";
	
	sprite_index = (spriteFrozen);
	
	// Simple gravity logic
	verticalSpeed = verticalSpeed + playerGravity;
	
	// Moving the player vertically (with gravity)
	if (place_meeting(x, y + verticalSpeed, oWall))
	{
		if (verticalSpeed > 0) allowJump = 5; // Buffer alowing jump to still occure
		while (abs(verticalSpeed) > 0.1)
		{
			verticalSpeed *= 0.5;
			if (!place_meeting(x, y + verticalSpeed, oWall)) y += verticalSpeed;
		}
		verticalSpeed = 0;
	}
	y += verticalSpeed;  // Change the CURRENT vertical speed
	
	// Change state
	if(keyActivate)
	{
		state = player_state_default;
	}
}