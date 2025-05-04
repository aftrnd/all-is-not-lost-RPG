// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function player_state_frozen(){
	
	// THIS IS A TEST STATE. THIS ONLY CHANGES THE SPRITE!
	
	// Set a debug state name
	global.stateName = "Frozen!";
	
	// Set frozen sprite
	sprite_index = spriteFrozen;
	
	// No movement in frozen state
	hspd = 0;
	vspd = 0;
	
	// Change state back if activation key pressed again
	if(keyActivate) {
		state = player_state_default;
	}
}