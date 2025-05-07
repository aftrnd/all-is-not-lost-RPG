/// @description Post Room Start - Check Player Position
// This event is called at the end of the first step after room start
// to double-check the player's position

// If we're supposed to be at a specific position, verify we're there
if (variable_global_exists("player_target_x") && 
    global.player_target_x != -1 && 
    instance_exists(oPlayer)) {
    
    // Force position the player again
    with (oPlayer) {
        // Get target position from globals
        var target_x = global.player_target_x;
        var target_y = global.player_target_y;
        
        // Always force position regardless of current position
        x = target_x;
        y = target_y;
        
        // Make sure player's internal coordinates are updated
        playerX = x;
        playerY = y;
        
        // Reset movement values to prevent momentum carrying over
        hspd = 0;
        vspd = 0;
        
        // Force freeze state for a few more frames to ensure position takes
        freeze_state = true;
        
        // Log the correction
        debug_log("POST-START POSITION ENFORCED: (" + 
                 string(x) + "," + string(y) + ")", c_lime);
                 
        // Set alarm to monitor position for the next 5 frames
        // This will help identify if something is moving the player after room start
        alarm[0] = 1; // Will trigger Room Monitor event
    }
    
    // Set an alarm to check position again after a few frames
    // This helps catch any code that might be repositioning the player
    alarm[5] = 3;
} 