/// @function room_transition_init()
/// @description Initialize the room transition system
function room_transition_init() {
    // Initialize transition variables
    global.room_transition_state = "none";    // Current state: "none", "fade_out", "fade_in"
    global.room_transition_alpha = 0;         // Transition overlay transparency
    global.room_transition_speed = 0.05;      // How fast to fade (default)
    global.room_transition_target = -1;       // Target room ID
    
    // Set up the player target position globals (used after room change)
    global.player_target_x = -1;
    global.player_target_y = -1;
    
    // Flag to track whether we need to create the player in the new room
    global.create_player_in_new_room = false;
}

/// @function room_transition_start(target_room, speed)
/// @description Start a room transition fade out
/// @param {id} target_room The target room to go to
/// @param {real} speed The fade speed (optional)
function room_transition_start(target_room, speed = 0.05) {
    // Initialize if needed
    if (!variable_global_exists("room_transition_state")) {
        room_transition_init();
    }
    
    // We ALWAYS want to create a new player if we've disabled persistence
    global.create_player_in_new_room = true;
    if (instance_exists(oPlayer)) {
        show_debug_message("Player persistence status: " + string(oPlayer.persistent));
        show_debug_message("Setting create_player_in_new_room to TRUE");
    }
    
    // Set up the transition
    global.room_transition_state = "fade_out";
    global.room_transition_alpha = 0;
    global.room_transition_speed = speed;
    global.room_transition_target = target_room;
}

/// @function room_transition_update()
/// @description Update the room transition (call this in oGameController's Step event)
function room_transition_update() {
    // Only process if we're in a transition
    if (global.room_transition_state != "none") {
        
        // Handle fade out
        if (global.room_transition_state == "fade_out") {
            global.room_transition_alpha += global.room_transition_speed;
            
            // When fully faded out, change room
            if (global.room_transition_alpha >= 1) {
                global.room_transition_alpha = 1;
                
                // Change to the target room
                if (global.room_transition_target != -1) {
                    room_goto(global.room_transition_target);
                    global.room_transition_state = "fade_in";
                }
            }
        }
        // Handle fade in
        else if (global.room_transition_state == "fade_in") {
            global.room_transition_alpha -= global.room_transition_speed;
            
            // When fully faded in, end transition
            if (global.room_transition_alpha <= 0) {
                global.room_transition_alpha = 0;
                global.room_transition_state = "none";
                global.room_transition_target = -1;
            }
        }
    }
}

/// @function room_transition_draw()
/// @description Draw the room transition overlay (call this in oGameController's Draw GUI event)
function room_transition_draw() {
    if (global.room_transition_state != "none") {
        // Draw black overlay with transition alpha
        draw_set_color(c_black);
        draw_set_alpha(global.room_transition_alpha);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
        draw_set_alpha(1);
    }
}

/// @function ensure_player_exists(x, y)
/// @description Make sure a player instance exists at the specified coordinates
/// @param {real} x The x position to create the player at
/// @param {real} y The y position to create the player at
function ensure_player_exists(x_pos, y_pos) {
    // Special forced implementation that handles the persistent player issue
    if (instance_exists(oPlayer)) {
        // Player exists, update its properties
        var existing_player = instance_find(oPlayer, 0);
        
        with (existing_player) {
            // Log current state
            show_debug_message("Player repositioning from (" + string(x) + "," + string(y) + 
                             ") to (" + string(x_pos) + "," + string(y_pos) + ")");
            
            // Force visibility
            visible = true;
            depth = -1000; // Ensure drawn above other objects
            
            // Force coordinates
            x = x_pos;
            y = y_pos;
            playerX = x;
            playerY = y;
            
            // Reset movement
            hspd = 0;
            vspd = 0;
            
            // Ensure the player is unfrozen
            freeze_state = false;
            
            // Log success
            debug_log("Player repositioned successfully", c_lime);
        }
        
        return true;
    }
    
    // No player exists, which shouldn't happen with a persistent player,
    // but we'll handle it by creating a new one
    show_debug_message("NO PLAYER FOUND! Creating emergency player at: (" + 
                    string(x_pos) + "," + string(y_pos) + ")");
    
    // Find a valid layer
    var layer_name = "Instances";
    if (layer_exists("Player")) layer_name = "Player";
    else if (layer_exists("Players")) layer_name = "Players";
    
    // Create new player
    var new_player = instance_create_layer(x_pos, y_pos, layer_name, oPlayer);
    
    if (instance_exists(new_player)) {
        with (new_player) {
            // Set basic properties
            freeze_state = false;
            hspd = 0;
            vspd = 0;
            playerX = x;
            playerY = y;
            visible = true;
            depth = -1000;
            persistent = true;
            debug_log("EMERGENCY: Player created at: (" + string(x) + "," + string(y) + ")", c_red);
        }
        return true;
    }
    
    show_debug_message("CRITICAL FAILURE: Could not create player object!");
    return false;
}