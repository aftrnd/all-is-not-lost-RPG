/// @function settings_save()
/// @description Save game settings to file
function settings_save() {
    // Create a DS map to store our settings
    var settings_map = ds_map_create();
    
    // Store GUI scale setting
    ds_map_add(settings_map, "gui_scale", global.gui_scale);
    
    // Save the DS map to a file
    var file = "game_settings.json";
    var json_string = json_encode(settings_map);
    var buffer = buffer_create(string_byte_length(json_string) + 1, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, json_string);
    buffer_save(buffer, file);
    
    // Clean up
    buffer_delete(buffer);
    ds_map_destroy(settings_map);
}

/// @function settings_load()
/// @description Load game settings from file
function settings_load() {
    // Set default values for settings (1x is pixel perfect default)
    global.gui_scale = 1.0;
    
    // Check if settings file exists
    var file = "game_settings.json";
    if (file_exists(file)) {
        // Read the file
        var buffer = buffer_load(file);
        var json_string = buffer_read(buffer, buffer_string);
        buffer_delete(buffer);
        
        // Decode the JSON
        var settings_map = json_decode(json_string);
        
        // Get the settings values (with error checking)
        if (ds_map_exists(settings_map, "gui_scale")) {
            global.gui_scale = ds_map_find_value(settings_map, "gui_scale");
            
            // Validate that it's one of our allowed values (1x, 2x, 3x)
            if (global.gui_scale != 1.0 && global.gui_scale != 2.0 && global.gui_scale != 3.0) {
                global.gui_scale = 1.0; // Reset to default if invalid
            }
        }
        
        // Apply the settings
        display_set_gui_maximize(global.gui_scale, global.gui_scale);
        
        // Clean up
        ds_map_destroy(settings_map);
    } else {
        // No settings file found, use defaults
        display_set_gui_maximize(global.gui_scale, global.gui_scale);
    }
}

/// @function settings_apply_gui_scale(scale)
/// @description Apply the GUI scale setting
/// @param {real} scale The scale value to apply
function settings_apply_gui_scale(scale) {
    // Store the value in the global variable
    global.gui_scale = scale;
    
    // Apply the scale
    display_set_gui_maximize(global.gui_scale, global.gui_scale);
    
    // Save the settings
    settings_save();
}