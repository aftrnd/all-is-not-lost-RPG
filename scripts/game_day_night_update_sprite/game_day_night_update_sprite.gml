/// @function game_day_night_update_sprite(day_frame, night_frame, day_start_hour, night_start_hour)
/// @description Updates an object's image_index based on the game's time of day
/// @param {real} day_frame The sprite frame index to use during day time
/// @param {real} night_frame The sprite frame index to use during night time
/// @param {real} day_start_hour Hour when day begins (default 7 = 7AM)
/// @param {real} night_start_hour Hour when night begins (default 20 = 8PM)
/// @returns {real} The appropriate frame index based on current time
function game_day_night_update_sprite(day_frame = 0, night_frame = 1, day_start_hour = 7, night_start_hour = 20) {
    // Verify time system is initialized
    if (!variable_global_exists("time_hours")) {
        show_debug_message("ERROR: Time system not initialized. Call time_init() first.");
        return day_frame; // Default to day frame if time system not initialized
    }
    
    var hour_now = global.time_hours;
    
    // Determine if it's day or night based on the hour
    // Day: From day_start_hour until night_start_hour
    // Night: From night_start_hour until day_start_hour
    if (hour_now >= day_start_hour && hour_now < night_start_hour) {
        return day_frame; // It's daytime
    } else {
        return night_frame; // It's nighttime
    }
}

/// @function game_day_night_apply_to_object(object_id, day_frame, night_frame, day_start_hour, night_start_hour)
/// @description Applies day/night frame to all instances of the specified object
/// @param {id} object_id The object ID to update all instances of
/// @param {real} day_frame The sprite frame index to use during day time
/// @param {real} night_frame The sprite frame index to use during night time
/// @param {real} day_start_hour Hour when day begins (default 7 = 7AM)
/// @param {real} night_start_hour Hour when night begins (default 20 = 8PM)
function game_day_night_apply_to_object(object_id, day_frame = 0, night_frame = 1, day_start_hour = 7, night_start_hour = 20) {
    // Get appropriate frame based on time
    var correct_frame = game_day_night_update_sprite(day_frame, night_frame, day_start_hour, night_start_hour);
    
    // Apply to all instances of the object
    with (object_id) {
        image_index = correct_frame;
    }
}