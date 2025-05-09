/// @description Draw slime and debug information
// You can write your code in this editor

// Draw the sprite normally
draw_self();

// Draw debug visualization if enabled
if (show_debug_ranges) {
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
} 