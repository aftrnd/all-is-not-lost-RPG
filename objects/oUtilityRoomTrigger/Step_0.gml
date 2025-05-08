/// @description Check for player collision
// Check if player is colliding with this trigger

// Update visibility based on debug settings
// This ensures that when debug settings change, the trigger visibility updates immediately
visible = global.debug_mode && global.debug_settings.show_triggers;

// Only proceed if we haven't been triggered yet and we have a valid destination
if (!triggered && destination_room != -1) {
    if (place_meeting(x, y, oPlayer)) {
        triggered = true;
        
        // IMPORTANT: Store target coordinates in globals for the room transition
        // These will be used in the destination room to position the player
        global.player_target_x = destination_x;
        global.player_target_y = destination_y + y_offset;
        
        // Log the transition details
        show_debug_message("======= ROOM TRANSITION TRIGGERED =======");
        show_debug_message("  From: " + room_get_name(room));
        show_debug_message("  To:   " + room_get_name(destination_room));
        show_debug_message("  Target position: (" + string(global.player_target_x) + 
                         ", " + string(global.player_target_y) + ")");
        
        // Debug information with player
        if (instance_exists(oPlayer)) {
            with (oPlayer) {
                // Log player's current position
                debug_log("Room transition from: (" + string(x) + ", " + string(y) + ")", c_yellow);
                
                // Log target position details
                debug_log("Room transition to: " + room_get_name(other.destination_room) + 
                         " at position (" + string(other.destination_x) + 
                         ", " + string(other.destination_y + other.y_offset) + ")", c_lime);
                
                // CRITICAL: DO NOT CHANGE PERSISTENCE
                // We'll handle this differently now that we know the player is designed to be persistent
                debug_log("Room transition in progress - player will be repositioned", c_orange);
            }
        }
        
        // Initialize transition system if needed
        if (!variable_global_exists("room_transition_state")) {
            room_transition_init();
        }
        
        // Start the room transition
        room_transition_start(destination_room, transition_speed);
    }
} 