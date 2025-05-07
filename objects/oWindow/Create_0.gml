/// @description Setup window day/night variables
// Default setting for sprite frames
day_frame = 0;    // Day frame is the first frame (0)
night_frame = 1;  // Night frame is the second frame (1)

// Default time settings for day/night transition
// These match the values in game_day_night_cycle script
day_start_hour = 7;    // 7 AM - start of day
night_start_hour = 20; // 8 PM - start of night

// Transition duration in hours (how long the fade lasts)
transition_duration = 1.0; // 1 hour transition time

// No need to set image_index - we'll handle drawing in the Draw event 