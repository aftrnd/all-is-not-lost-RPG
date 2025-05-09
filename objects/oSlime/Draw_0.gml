/// @description Draw slime and debug information
// You can write your code in this editor

// Draw the sprite with appropriate flipping based on facing_right variable
// CORRECTED: The sprite's default orientation must be facing RIGHT 
// When facing left, we need to flip it horizontally
draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    facing_right ? 1 : -1, // Completely inverted logic: right = normal, left = flipped
    1, // No vertical flipping
    0, // No rotation
    image_blend,
    image_alpha
);

// Skip all debug drawing if we're in the first few frames after room load
// This prevents flashing of debug elements during transitions
if (variable_instance_exists(id, "room_entry_frames")) {
    room_entry_frames += 1;
    if (room_entry_frames < 3) { // Skip first 3 frames
        exit; // Early exit - no debug visuals during initial frames
    }
} else {
    room_entry_frames = 0;
}

// Thorough check for debug mode - multiple checks for reliability
var debug_enabled = false;

// Primary check: Global debug mode must exist and be TRUE
if (variable_global_exists("debug_mode")) {
    debug_enabled = global.debug_mode;
    
    // Secondary check: If player exists, sync with its debug menu
    var player_obj = instance_find(oPlayer, 0);
    if (player_obj != noone && variable_instance_exists(player_obj, "drawDebugMenu")) {
        // Only show debug if BOTH global AND player debug are enabled
        debug_enabled = debug_enabled && player_obj.drawDebugMenu;
    }
    
    // Tertiary check: Debug settings must also allow it if they exist
    if (variable_global_exists("debug_settings")) {
        // We can require specific debug settings here
        // This is future-proofing for more granular debug controls
    }
}

// FINAL GATE: Only proceed if debug is 100% confirmed enabled
if (debug_enabled) {
    // Find player
    var player = instance_nearest(x, y, oPlayer);
    var dist_to_player = infinity;
    if (player != noone) {
        dist_to_player = point_distance(x, y, player.x, player.y);
    }
    
    // Detection range circle
    draw_set_color(c_yellow);
    draw_set_alpha(0.3);
    draw_circle(x, y, detection_range, false); // Filled semi-transparent circle
    draw_set_alpha(1.0);
    draw_circle(x, y, detection_range, true);  // Outline
    
    // Chase range
    draw_set_color(c_red);
    draw_circle(x, y, chase_range, true);
    
    // Draw line to player if in range
    if (player != noone && dist_to_player <= detection_range) {
        // Line color based on whether player is detected
        if (state == "chase") {
            draw_set_color(c_lime); // Green if actively chasing
        } else {
            // Red if in range but not chasing (likely due to walls)
            draw_set_color(c_red);
        }
        draw_line(x, y, player.x, player.y);
        
        // Draw distance text
        draw_set_color(c_white);
        var mid_x = x + (player.x - x) / 2;
        var mid_y = y + (player.y - y) / 2;
        draw_text(mid_x, mid_y, string(floor(dist_to_player)) + "px");
    }
    
    // Current state and distance info
    draw_set_color(c_white);
    draw_text(x, y - 24, state);
    if (player != noone) {
        draw_text(x, y - 12, "Dist: " + string(floor(dist_to_player)) + "px");
    }
    
    // Draw direction indicator
    var dir_x = x + lengthdir_x(16, move_dir);
    var dir_y = y + lengthdir_y(16, move_dir);
    draw_set_color(c_lime);
    draw_line(x, y, dir_x, dir_y);
    draw_circle(dir_x, dir_y, 2, false);
    
    // Also show facing direction
    var facing_x = x + lengthdir_x(20, facing_right ? 0 : 180);
    var facing_y = y;
    draw_set_color(c_aqua);
    draw_circle(facing_x, facing_y, 3, false);
    
    // Reset drawing properties
    draw_set_alpha(1.0);
    draw_set_color(c_white);
} 