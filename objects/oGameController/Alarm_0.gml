/// @description Check Player Existence
// This alarm checks if the player exists and tries to create it if not

if (!instance_exists(oPlayer) && variable_global_exists("player_target_x") && global.player_target_x != -1) {
    show_debug_message("RECOVERY: No player found, attempting to create one");
    
    // Find a valid layer
    var layer_name = "Instances";
    if (layer_exists("Player")) layer_name = "Player";
    else if (layer_exists("Players")) layer_name = "Players";
    
    // Create player at target position
    var new_player = instance_create_layer(
        global.player_target_x,
        global.player_target_y,
        layer_name,
        oPlayer
    );
    
    if (instance_exists(new_player)) {
        show_debug_message("RECOVERY SUCCESS: Player created");
        with (new_player) {
            // Set key properties
            freeze_state = true;
            hspd = 0;
            vspd = 0;
            playerX = x;
            playerY = y;
            visible = true;
            depth = -1000;
            persistent = true;
            debug_log("RECOVERY: Player created at: (" + string(x) + "," + string(y) + ")", c_orange);
        }
    } else {
        show_debug_message("RECOVERY FAILED: Could not create player");
    }
} 