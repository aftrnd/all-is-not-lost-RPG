/// @description Global Debug System
/// @function game_debug_system_init()
/// @description Initializes the global debug system

function game_debug_system_init() {
    // Initialize the global debug mode flag if it doesn't exist
    if (!variable_global_exists("debug_mode")) {
        global.debug_mode = false;
    }
    
    // Create a struct to store debug settings
    global.debug_settings = {
        show_triggers: true,        // Show room triggers and other interaction points
        show_collision: false,      // Show collision boxes
        show_paths: false,          // Show NPC paths
        show_grid: false,           // Show grid overlay
        log_level: 2                // 0=none, 1=errors, 2=warnings, 3=info, 4=verbose
    };
    
    show_debug_message("Debug system initialized. Debug mode: " + string(global.debug_mode));
}

/// @function debug_toggle()
/// @description Toggles the debug mode on/off
function debug_toggle() {
    global.debug_mode = !global.debug_mode;
    var status = global.debug_mode ? "ENABLED" : "DISABLED";
    var message = "Debug mode " + status;
    show_debug_message(message);
    
    // If a player object exists, also log it to the in-game console
    var player = instance_find(oPlayer, 0);
    if (player != noone && variable_instance_exists(player, "debug_log")) {
        var color = global.debug_mode ? c_lime : c_red;
        player.debug_log(message, color);
    }
    
    return global.debug_mode;
}

/// @function debug_is_enabled()
/// @description Returns whether debug mode is enabled
/// @returns {boolean} Whether debug mode is enabled
function debug_is_enabled() {
    if (variable_global_exists("debug_mode")) {
        return global.debug_mode;
    }
    return false;
}

/// @function debug_setting_get(setting_name)
/// @description Gets a debug setting value
/// @param {string} setting_name The name of the setting
/// @returns {any} The value of the setting
function debug_setting_get(setting_name) {
    if (variable_global_exists("debug_settings") && 
        variable_struct_exists(global.debug_settings, setting_name)) {
        return variable_struct_get(global.debug_settings, setting_name);
    }
    return undefined;
}

/// @function debug_setting_set(setting_name, value)
/// @description Sets a debug setting value
/// @param {string} setting_name The name of the setting
/// @param {any} value The value to set
function debug_setting_set(setting_name, value) {
    // Make sure debug settings exist
    if (!variable_global_exists("debug_settings")) {
        game_debug_system_init();
    }
    
    // Set value if the setting exists
    if (variable_struct_exists(global.debug_settings, setting_name)) {
        // Use both methods for redundancy
        variable_struct_set(global.debug_settings, setting_name, value);
        global.debug_settings[$ setting_name] = value;
        
        // Log the change if a player object exists
        var player = instance_find(oPlayer, 0);
        if (player != noone && variable_instance_exists(player, "debug_log")) {
            var status = value ? "ON" : "OFF";
            var color = value ? c_lime : c_red;
            player.debug_log("Debug setting '" + setting_name + "' set to " + status, color);
        }
        
        return true;
    }
    return false;
}

/// @function debug_toggle_triggers()
/// @description Toggles trigger visibility specifically (convenience function)
/// @returns {boolean} The new state of show_triggers
function debug_toggle_triggers() {
    // Make sure debug settings exist
    if (!variable_global_exists("debug_settings")) {
        game_debug_system_init();
    }
    
    // Toggle the triggers value
    var current = global.debug_settings.show_triggers;
    global.debug_settings.show_triggers = !current;
    
    // Return the new state
    return global.debug_settings.show_triggers;
}