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
        
        // Shader control values
        global.time_brightness = 1.0;     // Full brightness during day
        global.time_color_tint = [1.0, 1.0, 1.0]; // Neutral tint (RGB)
        
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
    
    // Calculate brightness and color tint based on time of day
    if (time_val >= global.time_dawn_start && time_val < global.time_day_start) {
        // Dawn: Gradually transition from night to day
        var t = (time_val - global.time_dawn_start) / (global.time_day_start - global.time_dawn_start);
        global.time_brightness = 0.6 + (0.4 * t);
        // Dawn color: strong orange/yellow tint transitioning to neutral
        global.time_color_tint = [
            1.0, 
            0.7 + (0.3 * t), 
            0.5 + (0.5 * t)
        ];
    }
    else if (time_val >= global.time_day_start && time_val < global.time_dusk_start) {
        // Daytime: Full brightness, no tint
        global.time_brightness = 1.0;
        global.time_color_tint = [1.0, 1.0, 1.0];
    }
    else if (time_val >= global.time_dusk_start && time_val < global.time_night_start) {
        // Dusk: Gradually transition from day to night
        var t = (time_val - global.time_dusk_start) / (global.time_night_start - global.time_dusk_start);
        global.time_brightness = 1.0 - (0.4 * t);
        // Dusk color: strong orangish-red tint
        global.time_color_tint = [
            1.0,
            0.6 - (0.2 * t),
            0.4 - (0.2 * t)
        ];
    }
    else {
        // Night: Much darker with strong blue tint
        // If close to dawn, start brightening
        if (hour >= global.time_night_start || time_val < global.time_dawn_start) {
            if (hour < global.time_dawn_start && hour >= 0) {
                // Pre-dawn transition
                var t = time_val / global.time_dawn_start;
                global.time_brightness = 0.4 + (0.2 * t);
                // Transition from night blue to dawn orange
                global.time_color_tint = [
                    0.5 + (0.5 * t),
                    0.5 + (0.2 * t),
                    1.0 - (0.5 * t)
                ];
            } else {
                // Middle of night
                global.time_brightness = 0.4;
                global.time_color_tint = [0.5, 0.5, 1.0]; // Stronger blue tint
            }
        }
    }
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