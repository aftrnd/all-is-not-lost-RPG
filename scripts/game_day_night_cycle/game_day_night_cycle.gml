/// @function time_init()
/// @description Initialize the time system
function time_init() {
    // Initialize time variables if they don't exist
    if (!variable_global_exists("time_minutes")) {
        global.time_minutes = 0;          // Current minute (0-59)
        global.time_hours = 6;            // Current hour (0-23), start at 6 AM
        global.time_days = 1;             // Current day
        global.time_seasons = 0;          // Current season (0-3: Spring, Summer, Fall, Winter)
        global.time_years = 1;            // Current year
        
        // Time progression rate (how many real-time seconds = 1 game minute)
        global.time_rate = 5.0;           // INCREASED SPEED: 10 game minutes per real second
        
        // Time of day periods
        global.time_dawn_start = 5;       // 5:00 AM
        global.time_day_start = 7;        // 7:00 AM
        global.time_dusk_start = 18;      // 6:00 PM
        global.time_night_start = 20;     // 8:00 PM
        
        // Shader control values - initialize to noon/day settings
        global.time_brightness = 1.0;     // Exactly 1.0 for noon/day - no effect
        global.time_color_tint = [1.0, 1.0, 1.0]; // Neutral tint (RGB)
        
        // Surface for the day/night system
        global.daynightSurface = -1;
        
        // Time transition variables
        global.time_transitioning = false;
        global.time_transition_start_hour = 0;
        global.time_transition_start_minute = 0;
        global.time_transition_target_hour = 0;
        global.time_transition_target_minute = 0;
        global.time_transition_progress = 0;
        global.time_transition_duration = 1.5; // How many seconds the transition takes
    }
}

/// @function time_update()
/// @description Update game time (call in Step event)
function time_update() {
    // Check if we're transitioning between times
    if (global.time_transitioning) {
        // Update transition progress
        global.time_transition_progress += delta_time / (global.time_transition_duration * 1000000);
        
        if (global.time_transition_progress >= 1.0) {
            // Transition complete
            global.time_transitioning = false;
            global.time_hours = global.time_transition_target_hour;
            global.time_minutes = global.time_transition_target_minute;
        } else {
            // Interpolate between start and target time
            var start_time_decimal = global.time_transition_start_hour + (global.time_transition_start_minute / 60);
            var target_time_decimal = global.time_transition_target_hour + (global.time_transition_target_minute / 60);
            
            // Handle day boundary crossing (e.g., 23:00 to 1:00)
            if (target_time_decimal < start_time_decimal) {
                target_time_decimal += 24; // Add 24 hours to make math work
            }
            
            // Calculate interpolated time
            var current_time_decimal = lerp(start_time_decimal, target_time_decimal, global.time_transition_progress);
            
            // Handle overflow
            if (current_time_decimal >= 24) {
                current_time_decimal -= 24;
            }
            
            // Convert back to hours and minutes
            global.time_hours = floor(current_time_decimal);
            global.time_minutes = (current_time_decimal - global.time_hours) * 60;
        }
    } else {
        // Normal time progression
        global.time_minutes += global.time_rate * delta_time / 1000000;
        
        // Handle minute overflow
        if (global.time_minutes >= 60) {
            global.time_minutes -= 60;
            global.time_hours++;
            
            // Handle hour overflow
            if (global.time_hours >= 24) {
                global.time_hours = 0;
                global.time_days++;
                
                // Handle season change (every 28 days)
                if (global.time_days > 28) {
                    global.time_days = 1;
                    global.time_seasons++;
                    
                    // Handle year change
                    if (global.time_seasons > 3) {
                        global.time_seasons = 0;
                        global.time_years++;
                    }
                }
            }
        }
    }
    
    // Update time-of-day effects
    time_update_lighting();
}

/// @function time_update_lighting()
/// @description Update lighting based on time of day
function time_update_lighting() {
    var hour = global.time_hours;
    var minute = global.time_minutes;
    var time_val = hour + (minute / 60); // Time as decimal (e.g., 6.5 = 6:30)
    
    // Define key time points
    var dawn_start = global.time_dawn_start;   // 5:00 AM
    var day_start = global.time_day_start;     // 7:00 AM
    var dusk_start = global.time_dusk_start;   // 6:00 PM
    var night_start = global.time_night_start; // 8:00 PM
    
    // Handle brightness and color based on time of day
    if (time_val >= day_start && time_val < dusk_start) {
        // DAY - EXACTLY 1.0 brightness, no color tint (true neutral)
        global.time_brightness = 1.0;
        global.time_color_tint = [1.0, 1.0, 1.0];
    }
    else if (time_val >= dawn_start && time_val < day_start) {
        // DAWN - transition from night (0.5) to day (1.0)
        var t = (time_val - dawn_start) / (day_start - dawn_start);
        
        // Start from night brightness (0.5) and transition toward day (1.0)
        // First half: more orangish light (dawn)
        if (t < 0.5) {
            global.time_brightness = lerp(0.5, 0.75, t * 2); // First half: 0.5 to 0.75
            global.time_color_tint = [
                1.0,
                lerp(0.6, 0.8, t * 2),
                lerp(0.6, 0.7, t * 2)
            ];
        } else {
            global.time_brightness = lerp(0.75, 1.0, (t - 0.5) * 2); // Second half: 0.75 to 1.0
            global.time_color_tint = [
                1.0,
                lerp(0.8, 1.0, (t - 0.5) * 2),
                lerp(0.7, 1.0, (t - 0.5) * 2)
            ];
        }
    }
    else if (time_val >= dusk_start && time_val < night_start) {
        // DUSK - transition from day (1.0) to night (0.5)
        var t = (time_val - dusk_start) / (night_start - dusk_start);
        
        // Start from day brightness (1.0) and transition toward night (0.5)
        if (t < 0.5) {
            global.time_brightness = lerp(1.0, 0.75, t * 2); // First half: 1.0 to 0.75
            global.time_color_tint = [
                1.0,
                lerp(1.0, 0.7, t * 2),
                lerp(1.0, 0.5, t * 2)
            ];
        } else {
            global.time_brightness = lerp(0.75, 0.5, (t - 0.5) * 2); // Second half: 0.75 to 0.5
            global.time_color_tint = [
                lerp(1.0, 0.7, (t - 0.5) * 2),
                lerp(0.7, 0.5, (t - 0.5) * 2),
                lerp(0.5, 0.8, (t - 0.5) * 2)
            ];
        }
    }
    else {
        // NIGHT (after night_start or before dawn_start)
        global.time_brightness = 0.5;
        global.time_color_tint = [0.7, 0.5, 0.8]; // Blueish tint
    }
}

/// @function smoothstep(edge0, edge1, x)
/// @description Smooth interpolation between edge0 and edge1
/// @param {real} edge0 Lower edge
/// @param {real} edge1 Upper edge
/// @param {real} x Value to interpolate
/// @returns {real} Smoothly interpolated value
function smoothstep(edge0, edge1, x) {
    // Clamp x to 0..1 range
    x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    // Apply smoothstep formula: 3x^2 - 2x^3
    return x * x * (3.0 - 2.0 * x);
}

/// @function time_get_string()
/// @description Get formatted time string (e.g. "6:30 AM")
/// @returns {string} Formatted time string
function time_get_string() {
    var hour = global.time_hours;
    var minute = global.time_minutes;
    var period = (hour < 12) ? "AM" : "PM";
    
    // Convert to 12-hour format
    if (hour == 0) hour = 12;
    else if (hour > 12) hour -= 12;
    
    // Format minutes with leading zero if needed
    var minute_str = (minute < 10) ? "0" + string(floor(minute)) : string(floor(minute));
    
    return string(hour) + ":" + minute_str + " " + period;
}

/// @function time_get_period()
/// @description Get the current period of day (dawn, day, dusk, night)
/// @returns {string} Period name
function time_get_period() {
    var hour = global.time_hours;
    var time_val = hour + (global.time_minutes / 60);
    
    if (time_val >= global.time_dawn_start && time_val < global.time_day_start) {
        return "dawn";
    }
    else if (time_val >= global.time_day_start && time_val < global.time_dusk_start) {
        return "day";
    }
    else if (time_val >= global.time_dusk_start && time_val < global.time_night_start) {
        return "dusk";
    }
    else {
        return "night";
    }
}

/// @function time_set(hour, minute)
/// @description Set the time to a specific hour and minute
/// @param {real} hour Hour (0-23)
/// @param {real} minute Minute (0-59)
function time_set(hour, minute) {
    global.time_hours = clamp(hour, 0, 23);
    global.time_minutes = clamp(minute, 0, 59);
    
    // Update lighting immediately
    time_update_lighting();
}

/// @function time_skip(hours)
/// @description Skip ahead by a specified number of hours
/// @param {real} hours Number of hours to skip
function time_skip(hours) {
    var new_hours = global.time_hours + hours;
    var days_to_add = 0;
    
    // Handle overflow across multiple days
    while (new_hours >= 24) {
        new_hours -= 24;
        days_to_add++;
    }
    
    global.time_hours = new_hours;
    global.time_days += days_to_add;
    
    // Update lighting immediately
    time_update_lighting();
}

/// @function time_transition_to(hour, minute)
/// @description Smoothly transition to a target time
/// @param {real} hour Target hour (0-23)
/// @param {real} minute Target minute (0-59)
function time_transition_to(hour, minute) {
    // Store current time as starting point
    global.time_transition_start_hour = global.time_hours;
    global.time_transition_start_minute = global.time_minutes;
    
    // Store target time
    global.time_transition_target_hour = clamp(hour, 0, 23);
    global.time_transition_target_minute = clamp(minute, 0, 59);
    
    // Reset transition progress
    global.time_transition_progress = 0;
    
    // Start transitioning
    global.time_transitioning = true;
}