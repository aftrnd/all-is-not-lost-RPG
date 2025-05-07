/// @function game_day_night_update_sprite(day_frame, night_frame, day_start_hour, night_start_hour, transition_duration)
/// @description Updates an object's image_index based on the game's time of day
/// @param {real} day_frame The sprite frame index to use during day time
/// @param {real} night_frame The sprite frame index to use during night time
/// @param {real} day_start_hour Hour when day begins (default 7 = 7AM)
/// @param {real} night_start_hour Hour when night begins (default 20 = 8PM)
/// @param {real} transition_duration Duration of transition in game hours (default 1)
/// @returns {struct} A struct containing frame and blend info
function game_day_night_update_sprite(day_frame = 0, night_frame = 1, day_start_hour = 7, night_start_hour = 20, transition_duration = 1) {
    // Verify time system is initialized
    if (!variable_global_exists("time_hours")) {
        show_debug_message("ERROR: Time system not initialized. Call time_init() first.");
        return {
            primary_frame: day_frame,
            secondary_frame: day_frame,
            blend_amount: 0
        };
    }
    
    var hour_now = global.time_hours;
    var minute_now = global.time_minutes;
    var time_decimal = hour_now + (minute_now / 60); // Current time as decimal (e.g., 7.5 = 7:30)
    
    // Calculate transition periods
    var day_transition_start = day_start_hour - transition_duration;
    var day_transition_end = day_start_hour;
    var night_transition_start = night_start_hour - transition_duration;
    var night_transition_end = night_start_hour;
    
    // Create return struct with default values
    var result = {
        primary_frame: day_frame,
        secondary_frame: day_frame,
        blend_amount: 0
    };
    
    // Check which time period we're in
    if (time_decimal >= day_transition_start && time_decimal < day_transition_end) {
        // Transitioning from night to day
        result.primary_frame = night_frame;
        result.secondary_frame = day_frame;
        // Calculate blend amount (0.0 to 1.0)
        result.blend_amount = (time_decimal - day_transition_start) / transition_duration;
    }
    else if (time_decimal >= night_transition_start && time_decimal < night_transition_end) {
        // Transitioning from day to night
        result.primary_frame = day_frame;
        result.secondary_frame = night_frame;
        // Calculate blend amount (0.0 to 1.0)
        result.blend_amount = (time_decimal - night_transition_start) / transition_duration;
    }
    else if (time_decimal >= day_transition_end && time_decimal < night_transition_start) {
        // Solid daytime
        result.primary_frame = day_frame;
        result.secondary_frame = day_frame;
        result.blend_amount = 0;
    }
    else {
        // Solid nighttime
        result.primary_frame = night_frame;
        result.secondary_frame = night_frame;
        result.blend_amount = 0;
    }
    
    return result;
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

/// @function game_day_night_draw_sprite_ext(sprite_index, x, y, xscale, yscale, rot, color, alpha, day_frame, night_frame, day_start_hour, night_start_hour, transition_duration)
/// @description Draws a sprite with day/night transition using alpha blending
/// @param {asset} sprite_index The sprite to draw
/// @param {real} x X position
/// @param {real} y Y position 
/// @param {real} xscale X scale
/// @param {real} yscale Y scale
/// @param {real} rot Rotation
/// @param {color} color Color blend
/// @param {real} alpha Alpha value
/// @param {real} day_frame Day frame index
/// @param {real} night_frame Night frame index
/// @param {real} day_start_hour Hour when day begins
/// @param {real} night_start_hour Hour when night begins
/// @param {real} transition_duration Duration of transition in hours
function game_day_night_draw_sprite_ext(
    sprite_index, x, y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1,
    day_frame = 0, night_frame = 1, day_start_hour = 7, night_start_hour = 20, transition_duration = 1
) {
    var frame_data = game_day_night_update_sprite(
        day_frame, night_frame, day_start_hour, night_start_hour, transition_duration
    );
    
    // If we're in a transition, draw both frames with alpha blending
    if (frame_data.blend_amount > 0 && frame_data.blend_amount < 1 && 
        frame_data.primary_frame != frame_data.secondary_frame) {
        
        // Draw primary frame
        var primary_alpha = alpha * (1 - frame_data.blend_amount);
        draw_sprite_ext(
            sprite_index, frame_data.primary_frame, 
            x, y, xscale, yscale, rot, color, primary_alpha
        );
        
        // Draw secondary frame (the one we're blending to)
        var secondary_alpha = alpha * frame_data.blend_amount;
        draw_sprite_ext(
            sprite_index, frame_data.secondary_frame, 
            x, y, xscale, yscale, rot, color, secondary_alpha
        );
    } 
    else {
        // Just draw the primary frame with full alpha when not transitioning
        draw_sprite_ext(
            sprite_index, frame_data.primary_frame, 
            x, y, xscale, yscale, rot, color, alpha
        );
    }
}