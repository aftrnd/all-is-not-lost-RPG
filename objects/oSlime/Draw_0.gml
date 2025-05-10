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
    
    // Detection range circle (outer - yellow)
    draw_set_color(c_yellow);
    draw_set_alpha(0.15);
    draw_circle(x, y, detection_range, false); // Filled semi-transparent circle
    draw_set_alpha(0.8);
    draw_circle(x, y, detection_range, true);  // Outline
    
    // Chase range (inner - orange-red)
    draw_set_color(c_orange);
    draw_set_alpha(0.25);
    draw_circle(x, y, chase_range, false); // Filled semi-transparent circle
    draw_set_alpha(0.9);
    draw_set_color(c_red);
    draw_circle(x, y, chase_range, true); // Outline
    
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
    
    // Draw the pathfinding path if it exists and has points
    if (path_exists(path) && path_get_number(path) > 1) {
        // Draw the path with gradient colors
        var path_points = path_get_number(path);
        
        for (var i = 0; i < path_points - 1; i++) {
            // Get current and next points
            var px1 = path_get_point_x(path, i);
            var py1 = path_get_point_y(path, i);
            var px2 = path_get_point_x(path, i + 1);
            var py2 = path_get_point_y(path, i + 1);
            
            // Calculate color based on position in path (start to end gradient)
            var progress = i / (path_points - 1);
            
            // Gradient from cyan at start to purple at end
            var r = lerp(0, 192, progress);    // 0 to 192 (cyan to purple)
            var g = lerp(192, 0, progress);    // 192 to 0 (cyan to purple)
            var b = 255;                        // Always high blue component
            
            draw_set_color(make_color_rgb(r, g, b));
            draw_set_alpha(0.7);
            
            // Draw line segment
            draw_line_width(px1, py1, px2, py2, 2);
            
            // Draw point markers
            if (i == 0) {
                // First point (start) - larger green circle
                draw_set_color(c_lime);
                draw_set_alpha(0.8);
                draw_circle(px1, py1, 4, false);
            } else if (i == path_points - 2) {
                // Last connection to endpoint
                draw_set_color(c_fuchsia);
                draw_set_alpha(0.8);
                draw_circle(px2, py2, 4, false);
            } else {
                // Intermediary points - small dots
                draw_set_color(c_white);
                draw_set_alpha(0.6);
                draw_circle(px1, py1, 2, false);
            }
        }
        
        // Draw text showing number of path points
        draw_set_color(c_white);
        draw_set_alpha(1.0);
        draw_text(x + 15, y - 36, "Path: " + string(path_points) + " pts");
    }
    
    // Draw last known position marker if it exists
    if (variable_instance_exists(id, "last_known_target_x") && 
        variable_instance_exists(id, "last_known_target_y") &&
        last_known_target_x != -1 && last_known_target_y != -1 &&
        seen_player) {
        
        // X marks the spot
        var lkx = last_known_target_x;
        var lky = last_known_target_y;
        
        // Different color depending on whether we're currently going to that position
        if (going_to_last_seen) {
            draw_set_color(c_orange);
            draw_set_alpha(0.9);
        } else {
            draw_set_color(c_gray);
            draw_set_alpha(0.6);
        }
        
        // Draw X marker
        var marker_size = 6;
        draw_line_width(lkx - marker_size, lky - marker_size, 
                       lkx + marker_size, lky + marker_size, 2);
        draw_line_width(lkx + marker_size, lky - marker_size, 
                       lkx - marker_size, lky + marker_size, 2);
                       
        // Draw circle around last known position
        draw_circle(lkx, lky, 10, true);
        
        // Draw line from slime to last known position if actively going there
        if (going_to_last_seen) {
            draw_line_width(x, y, lkx, lky, 1);
            
            // Add a text label
            draw_set_color(c_orange);
            draw_text(lkx + 15, lky - 10, "Last seen");
        }
    }
    
    // Draw current state name with different colors
    draw_set_color(c_white);
    if (state == "chase") {
        draw_set_color(c_lime);
    } else if (state == "wander" && going_to_last_seen) {
        draw_set_color(c_orange);
        draw_text(x, y - 24, "going_to_last_seen");
    } else {
        draw_set_color(c_white);
    }
    draw_text(x, y - 36, state);
    
    // Distance info
    if (player != noone) {
        draw_set_color(c_white);
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