/// @description Slime AI Behavior
// You can write your code in this editor

// Find player
var player = instance_nearest(x, y, oPlayer);
var dist_to_player = infinity;
var can_see_player = false;

// Check if player exists and calculate distance
if (player != noone) {
    dist_to_player = point_distance(x, y, player.x, player.y);
    
    // Check line of sight to player (simple check for walls between slime and player)
    can_see_player = !collision_line(x, y, player.x, player.y, oUtilityWall, false, true);
}

// Reset movement variables for this frame
hspd = 0;
vspd = 0;

// Temporarily disable path following when checking for player
var was_following_path = false;
if (path_index != -1) {
    was_following_path = true;
    path_end(); // Temporarily stop path following to calculate manual movement
}

// STATE MANAGEMENT - Determine current state
if (player != noone && dist_to_player <= detection_range && can_see_player) {
    // Player detected - enter chase state
    state = "chase";
    
    // If detection was just made, we can provide a debug message
    if (state == "wander") {
        if (variable_global_exists("debug_mode") && global.debug_mode) {
            var debug_msg = "Slime detected player at distance: " + string(dist_to_player);
            show_debug_message(debug_msg);
            
            // Use player's debug log if available
            var player_obj = instance_find(oPlayer, 0);
            if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                player_obj.debug_log(debug_msg, c_yellow);
            }
        }
    }
} else {
    // Player not detected, continue or return to wandering state
    if (state == "chase") {
        // Just lost detection of player
        if (variable_global_exists("debug_mode") && global.debug_mode) {
            var debug_msg = "Slime lost sight of player";
            show_debug_message(debug_msg);
            
            // Use player's debug log if available
            var player_obj = instance_find(oPlayer, 0);
            if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                player_obj.debug_log(debug_msg, c_red);
            }
        }
        state = "wander";
        // Reset wandering parameters
        change_dir_timer = 0;
        move_dir = irandom(359);
    }
}

// STATE BEHAVIOR - Act based on current state
if (state == "chase") {
    // CHASE STATE - Player is detected
    
    if (dist_to_player <= chase_range) {
        // DIRECT CHASE - Player is very close, move directly toward them
        var dir_to_player = point_direction(x, y, player.x, player.y);
        
        // Use full chase speed when close to player
        // Only scale down when extremely close (< 5 pixels)
        var chase_factor = 1.0;
        if (dist_to_player < 5) {
            chase_factor = dist_to_player / 5;
        }
        
        hspd = lengthdir_x(chase_spd * chase_factor, dir_to_player);
        vspd = lengthdir_y(chase_spd * chase_factor, dir_to_player);
    }
    else {
        // PATHFINDING CHASE - Player is further away but still in detection range
        
        // Use direct movement as a fallback
        var dir_to_player = point_direction(x, y, player.x, player.y);
        var direct_hspd = lengthdir_x(chase_spd, dir_to_player);
        var direct_vspd = lengthdir_y(chase_spd, dir_to_player);
        
        // Check if pathfinding has been initialized
        if (variable_global_exists("pathfinding_initialized") && global.pathfinding_initialized) {
            // Update path less frequently to save performance
            path_update_timer++;
            if (path_update_timer >= path_update_delay) {
                path_update_timer = 0;
                
                // Clear any existing path
                path_clear_points(path);
                
                // Calculate a path to the player
                var path_found = mp_grid_path(global.mp_grid, path, x, y, player.x, player.y, true);
                
                if (path_found) {
                    // We found a valid path
                    if (path_get_number(path) > 1) {
                        // Get the next point on the path (index 1, as 0 is our current position)
                        var next_x = path_get_point_x(path, 1);
                        var next_y = path_get_point_y(path, 1);
                        
                        // Calculate direction and set movement
                        var path_dir = point_direction(x, y, next_x, next_y);
                        hspd = lengthdir_x(chase_spd, path_dir);
                        vspd = lengthdir_y(chase_spd, path_dir);
                    } else {
                        // Path too short, fallback to direct movement
                        hspd = direct_hspd;
                        vspd = direct_vspd;
                    }
                } else {
                    // No path found, use direct movement with wall avoidance
                    // Check for walls in our direct path
                    var wall_ahead = collision_line(x, y, 
                                                x + lengthdir_x(avoid_range, dir_to_player), 
                                                y + lengthdir_y(avoid_range, dir_to_player), 
                                                oUtilityWall, false, true);
                    
                    if (wall_ahead) {
                        // Wall in the way, try to move around it by adjusting direction
                        var test_angles = [45, -45, 90, -90];
                        var found_clear_path = false;
                        
                        for (var i = 0; i < array_length(test_angles); i++) {
                            var test_dir = dir_to_player + test_angles[i];
                            var test_x = x + lengthdir_x(avoid_range, test_dir);
                            var test_y = y + lengthdir_y(avoid_range, test_dir);
                            
                            if (!collision_line(x, y, test_x, test_y, oUtilityWall, false, true)) {
                                // Found a clear direction, use it
                                dir_to_player = test_dir;
                                found_clear_path = true;
                                break;
                            }
                        }
                        
                        if (!found_clear_path) {
                            // No clear path found, just pick a random direction
                            dir_to_player = irandom(359);
                        }
                    }
                    
                    hspd = lengthdir_x(chase_spd, dir_to_player);
                    vspd = lengthdir_y(chase_spd, dir_to_player);
                }
            } else {
                // Between path updates, continue moving to next point
                if (was_following_path && path_get_number(path) > 1) {
                    // Get the next point on the path
                    var next_x = path_get_point_x(path, 1);
                    var next_y = path_get_point_y(path, 1);
                    
                    // Calculate direction and set movement
                    var path_dir = point_direction(x, y, next_x, next_y);
                    hspd = lengthdir_x(chase_spd, path_dir);
                    vspd = lengthdir_y(chase_spd, path_dir);
                } else {
                    // No valid path point, use direct movement
                    hspd = direct_hspd;
                    vspd = direct_vspd;
                }
            }
        } else {
            // Pathfinding not initialized, fall back to direct movement with wall avoidance
            // Check for walls in our direct path
            var wall_ahead = collision_line(x, y, 
                                          x + lengthdir_x(avoid_range, dir_to_player), 
                                          y + lengthdir_y(avoid_range, dir_to_player), 
                                          oUtilityWall, false, true);
            
            if (wall_ahead) {
                // Wall in the way, try to move around it by adjusting direction
                var test_angles = [45, -45, 90, -90];
                var found_clear_path = false;
                
                for (var i = 0; i < array_length(test_angles); i++) {
                    var test_dir = dir_to_player + test_angles[i];
                    var test_x = x + lengthdir_x(avoid_range, test_dir);
                    var test_y = y + lengthdir_y(avoid_range, test_dir);
                    
                    if (!collision_line(x, y, test_x, test_y, oUtilityWall, false, true)) {
                        // Found a clear direction, use it
                        dir_to_player = test_dir;
                        found_clear_path = true;
                        break;
                    }
                }
                
                if (!found_clear_path) {
                    // No clear path found, just pick a random direction
                    dir_to_player = irandom(359);
                }
            }
            
            hspd = lengthdir_x(chase_spd, dir_to_player);
            vspd = lengthdir_y(chase_spd, dir_to_player);
        }
    }
}
else if (state == "wander") {
    // WANDER STATE - Moving randomly around the area
    
    // Check if we're in a paused state
    if (wander_pause_timer > 0) {
        // Currently paused
        wander_pause_timer--;
        
        // When pause ends, choose a new direction
        if (wander_pause_timer <= 0) {
            move_dir = irandom(359);
            change_dir_timer = 0;
        }
    } else {
        // Active wandering
        
        // Increment timer for changing direction
        change_dir_timer++;
        
        if (change_dir_timer >= change_dir_delay) {
            // Time to change direction or possibly pause
            
            // 30% chance to pause briefly during wandering
            if (irandom(100) < 30) {
                // Pause for a random duration (0.5 to 2 seconds)
                wander_pause_timer = irandom_range(room_speed * 0.5, room_speed * 2);
                wander_pause_duration = wander_pause_timer;
                
                // Clear movement
                hspd = 0;
                vspd = 0;
            } else {
                // Change to a new direction
                move_dir = irandom(359);
                change_dir_timer = 0;
                change_dir_delay = room_speed * irandom_range(1, 3); // Randomize next delay
            }
        }
        
        // Only calculate movement if not paused
        if (wander_pause_timer <= 0) {
            // Calculate movement based on current direction
            hspd = lengthdir_x(spd, move_dir);
            vspd = lengthdir_y(spd, move_dir);
            
            // Check for collision in the movement direction
            var will_hit_wall = collision_line(x, y, x + hspd * avoid_range, y + vspd * avoid_range, 
                                              oUtilityWall, false, true);
            
            if (will_hit_wall) {
                // About to hit a wall, change direction to bounce off
                move_dir = (move_dir + 180 + irandom_range(-45, 45)) % 360;
                hspd = lengthdir_x(spd, move_dir);
                vspd = lengthdir_y(spd, move_dir);
                
                // Reset direction change timer
                change_dir_timer = 0;
            }
        }
    }
}

// Pre-check for collisions - do not allow movement that would cause a collision
// This extra check prevents attempting to move into walls in the first place

// Check horizontal movement for potential collision
if (place_meeting(x + hspd, y, oUtilityWall)) {
    // Will hit a wall horizontally, reduce speed until safe
    var safe_hspd = hspd;
    while (place_meeting(x + safe_hspd, y, oUtilityWall)) {
        safe_hspd *= 0.5; // Cut speed in half
        if (abs(safe_hspd) < 0.1) {
            safe_hspd = 0; // If very small, just stop
            break;
        }
    }
    hspd = safe_hspd;
}

// Check vertical movement for potential collision
if (place_meeting(x, y + vspd, oUtilityWall)) {
    // Will hit a wall vertically, reduce speed until safe
    var safe_vspd = vspd;
    while (place_meeting(x, y + safe_vspd, oUtilityWall)) {
        safe_vspd *= 0.5; // Cut speed in half
        if (abs(safe_vspd) < 0.1) {
            safe_vspd = 0; // If very small, just stop
            break;
        }
    }
    vspd = safe_vspd;
}

// === MAIN COLLISION HANDLING ===
// Exactly matching player_state_default collision

// Horizontal Collision Check - Pixel perfect approach
if (hspd != 0) {
    if (place_meeting(x + hspd, y, oUtilityWall)) {
        // Move as close as possible to the wall
        while (!place_meeting(x + sign(hspd), y, oUtilityWall)) {
            x += sign(hspd);
        }
        hspd = 0; // Stop horizontal movement completely
    }
}

// Apply horizontal movement only after collision check
x += hspd;

// Vertical Collision Check - Pixel perfect approach
if (vspd != 0) {
    if (place_meeting(x, y + vspd, oUtilityWall)) {
        // Move as close as possible to the wall
        while (!place_meeting(x, y + sign(vspd), oUtilityWall)) {
            y += sign(vspd);
        }
        vspd = 0; // Stop vertical movement completely
    }
}

// Apply vertical movement only after collision check
y += vspd;

// Final safety check - prevent getting stuck inside walls
if (place_meeting(x, y, oUtilityWall)) {
    // Try to move out of the wall with increasing distance
    for (var push_dist = 1; push_dist <= 5; push_dist++) {
        var angles = [0, 90, 180, 270, 45, 135, 225, 315];
        
        for (var i = 0; i < array_length(angles); i++) {
            var test_x = x + lengthdir_x(push_dist, angles[i]);
            var test_y = y + lengthdir_y(push_dist, angles[i]);
            
            if (!place_meeting(test_x, test_y, oUtilityWall)) {
                x = test_x;
                y = test_y;
                exit; // Found a free spot, exit the collision correction
            }
        }
    }
} 