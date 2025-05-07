/// @description Setup window day/night variables
// Default setting for sprite frames
day_frame = 0;    // Day frame is the first frame (0)
night_frame = 1;  // Night frame is the second frame (1)

// Default time settings for day/night transition
// These match the values in game_day_night_cycle script
day_start_hour = 7;    // 7 AM - start of day
night_start_hour = 20; // 8 PM - start of night

// Set initial image_index based on current time
image_index = game_day_night_update_sprite(day_frame, night_frame, day_start_hour, night_start_hour); 