/// @description Ensure pathfinding is initialized
// You can write your code in this editor

// Check if pathfinding grid exists, if not, initialize it
if (!variable_global_exists("pathfinding_initialized") || !global.pathfinding_initialized) {
    // Initialize the motion planning grid for this room
    mob_pathfinding_init();
}

// CRITICAL: Force debug system to be properly synced on room entry
// This ensures we don't show debug visuals inappropriately
if (!variable_global_exists("debug_mode")) {
    // Debug system not initialized, initialize with default off
    if (script_exists(asset_get_index("game_debug_system_init"))) {
        game_debug_system_init();
        global.debug_mode = false; // Explicitly disable debug mode if just initialized
    }
} else {
    // Check if oPlayer exists and sync with its debug setting if possible
    var player_obj = instance_find(oPlayer, 0);
    if (player_obj != noone && variable_instance_exists(player_obj, "drawDebugMenu")) {
        // Ensure debug mode matches player's menu state
        global.debug_mode = player_obj.drawDebugMenu;
    }
}

// Extra check - force disable debug visuals on specific rooms if needed
// This is a failsafe in case other checks don't work
var current_room = room_get_name(room);
if (string_pos("StartRoom", current_room) > 0 || string_pos("TitleScreen", current_room) > 0) {
    // Force disable debug on specific rooms like title screens
    global.debug_mode = false;
}

// Log slime spawn in debug mode if enabled
// Only run this AFTER all debug checks are complete
if (variable_global_exists("debug_mode") && global.debug_mode) {
    var debug_msg = "Slime spawned at room position: [" + string(x) + ", " + string(y) + "]";
    show_debug_message(debug_msg);
    
    // Use player's debug log if available
    var player_obj = instance_find(oPlayer, 0);
    if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
        player_obj.debug_log(debug_msg, c_aqua);
    }
    
    // Additional message to confirm debug state
    show_debug_message("Slime debug visuals ENABLED in room: " + room_get_name(room));
} else {
    // Explicit message when debug is disabled
    show_debug_message("Slime debug visuals DISABLED in room: " + room_get_name(room));
} 