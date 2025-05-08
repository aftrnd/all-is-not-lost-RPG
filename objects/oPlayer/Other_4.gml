/// @description Handle room transitions and player positioning
// This event runs when a room starts

// Log the room entry for debugging
debug_log("Entered room: " + room_get_name(room), c_aqua);

// Initialize transition system if needed (failsafe)
if (!variable_global_exists("room_transition_state")) {
    room_transition_init();
    debug_log("Room transition system initialized (failsafe)", c_orange);
}

// Check if we're coming from a room transition 
// and if target coordinates were set
if (variable_global_exists("player_target_x") && 
    variable_global_exists("player_target_y") && 
    global.player_target_x != -1 && 
    global.player_target_y != -1) {
    
    // Log the repositioning for debugging
    debug_log("Repositioning after room transition from (" + string(x) + "," + string(y) + 
              ") to (" + string(global.player_target_x) + "," + string(global.player_target_y) + ")", c_yellow);
    
    // Apply the target coordinates
    x = global.player_target_x;
    y = global.player_target_y;
    
    // Update internal coordinate tracking
    playerX = x;
    playerY = y;
    
    // Reset movement to prevent sliding
    hspd = 0;
    vspd = 0;
    
    // Reset the global target variables to prevent reusing them
    global.player_target_x = -1;
    global.player_target_y = -1;
    
    // Briefly prevent player movement for one frame to avoid any input overlap
    freeze_state = true;
}