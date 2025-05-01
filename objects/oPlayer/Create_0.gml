/// @desc oPlayer - Properties
// You can write your code in this editor

#region Variables
// Player's Coordinates 
playerX = 0;
playerY = 0;

// Developer Menu
drawDebugMenu = false;
debug_logs = ds_list_create(); // Store log messages
debug_log_max = 10; // Maximum number of logs to display
debug_log_colors = ds_list_create(); // Store colors for each log entry

// Activity Tracking
last_pickup = "None"; // Last item picked up
pickup_time = 0;      // When it was picked up
last_sign = "None";   // Last sign interacted with
sign_time = 0;        // When it was read

// Player States
spriteDefault = sPlayer;
spriteFrozen = sPlayerFrozen;

// Define initial state
state = player_state_default;
#endregion

/// @function debug_log(message, color)
/// @description Adds a message to the debug log display
/// @param {string} message The message to log
/// @param {constant} color The color of the message (optional, defaults to white)
function debug_log(_message, _color = c_white) {
    // Add to GameMaker's built-in debug console
    show_debug_message(_message);
    
    // Add to our in-game debug display
    ds_list_insert(debug_logs, 0, _message);
    ds_list_insert(debug_log_colors, 0, _color);
    
    // Trim lists if they exceed max size
    while (ds_list_size(debug_logs) > debug_log_max) {
        ds_list_delete(debug_logs, debug_log_max);
        ds_list_delete(debug_log_colors, debug_log_max);
    }
    
    // Track specific activities
    if (string_pos("Picked up", _message) > 0) {
        // Extract the item name from the message
        var item_start = string_pos("x ", _message) + 2;
        last_pickup = string_copy(_message, item_start, string_length(_message) - item_start + 1);
        pickup_time = current_time;
    } else if (string_pos("Sign read:", _message) > 0) {
        // Extract the sign ID from the message
        var sign_start = string_pos("Sign read: ", _message) + 11;
        last_sign = string_copy(_message, sign_start, string_length(_message) - sign_start + 1);
        sign_time = current_time;
    }
}

#region Properties
playerGravity = 0.25; // Global value for player's gravity. Higher is more gravity (Might make a global value)
horizontalSpeed = 0; // Current horizontal speed
verticalSpeed = 0; // Current vertical speed
walkingSpeed = 1.45; // Speed the player walks
jumpSpeed = -5.0; // Speed the player moves off the ground
allowJump = 0; // Jump frame buffer
#endregion

#region Hotbar & Player Inventory
hotbar_size = 5;
inventory_size = 10;
total_slots = hotbar_size + inventory_size;
inventory = array_create(total_slots, noone);
selected_slot = 0; // Default selected hotbar slot
inventory_open = false; // Track if inventory is open
#endregion

#region Inventory Management
// Removed recursive inventory_add_item function
#endregion

#region Drag and Drop Variables
dragging_item = noone;
drag_origin_index = -1;
drag_offset_x = 0;
drag_offset_y = 0;
#endregion

slot_size = 48;
padding = 6;