/// @description Room Start Logic

// Add debug to help track what's happening
show_debug_message("======= ROOM START: " + room_get_name(room) + " =======");

// Check if we have target coordinates for the player
if (variable_global_exists("player_target_x") && global.player_target_x != -1) {
    show_debug_message("Player target coordinates found: (" + 
                     string(global.player_target_x) + ", " + 
                     string(global.player_target_y) + ")");
    
    // Move the player to the target coordinates (or create if missing)
    if (ensure_player_exists(global.player_target_x, global.player_target_y)) {
        show_debug_message("Player positioned successfully!");
    }
    
    // This is a transition from another room, so reset the targets
    alarm[3] = 5; // Reset target position vars after a few frames
    
    // Check one more time in a few frames
    alarm[5] = 15;
} else {
    // If we're starting fresh (like game start), ensure player exists at room center
    show_debug_message("No player target coordinates, using room center");
    ensure_player_exists(room_width/2, room_height/2);
} 