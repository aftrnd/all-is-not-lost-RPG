/// @description Final Position Check
// This alarm does a final check of the player position a few frames after room change

// Only do this check if we have target coordinates and the player exists
if (variable_global_exists("player_target_x") && 
    global.player_target_x != -1 && 
    instance_exists(oPlayer)) {
    
    with (oPlayer) {
        // Check if we're at the target position
        if (x != global.player_target_x || y != global.player_target_y) {
            // Position has drifted, force it back one last time
            debug_log("FINAL POSITION CORRECTION: Force to (" + 
                     string(global.player_target_x) + "," + 
                     string(global.player_target_y) + ")", c_red);
                     
            // Force position
            x = global.player_target_x;
            y = global.player_target_y;
            playerX = x;
            playerY = y;
            hspd = 0;
            vspd = 0;
            freeze_state = true;
        } else {
            // Position is correct, log success
            debug_log("Final position check: Position maintained correctly", c_lime);
        }
    }
} 