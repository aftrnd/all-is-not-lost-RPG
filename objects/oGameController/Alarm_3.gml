/// @description Reset target position
// This alarm delays the reset of target position values
// to ensure they take effect properly

// Reset target position
global.player_target_x = -1;
global.player_target_y = -1;

// Log completion
show_debug_message("Room transition completion: Target position variables reset"); 