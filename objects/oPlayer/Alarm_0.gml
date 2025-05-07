/// @description Position Monitor
// This alarm checks the player's position and logs any changes
// It's used to debug room transition positioning issues

// Get current position
var current_x = x;
var current_y = y;

// Check if we have stored the previous position
if (variable_instance_exists(id, "prev_monitor_x")) {
    // Check if position changed
    if (current_x != prev_monitor_x || current_y != prev_monitor_y) {
        debug_log("POSITION CHANGED: From (" + 
                 string(prev_monitor_x) + "," + string(prev_monitor_y) + ") to (" + 
                 string(current_x) + "," + string(current_y) + ")", c_red);
                 
        // Force position back if transition is still active and we have target coordinates
        if (variable_global_exists("player_target_x") && global.player_target_x != -1) {
            x = global.player_target_x;
            y = global.player_target_y;
            playerX = x;
            playerY = y;
            hspd = 0;
            vspd = 0;
            freeze_state = true;
            
            debug_log("POSITION CORRECTED AGAIN", c_orange);
        }
    }
}

// Store current position for next check
prev_monitor_x = current_x;
prev_monitor_y = current_y;

// Continue monitoring for up to 5 checks
if (alarm_monitor_count < 5) {
    alarm_monitor_count++;
    alarm[0] = 1; // Check again next frame
} else {
    // Reset counter for next time
    alarm_monitor_count = 0;
    
    // Final position report
    debug_log("Position stabilized at: (" + string(x) + "," + string(y) + ")", c_lime);
} 