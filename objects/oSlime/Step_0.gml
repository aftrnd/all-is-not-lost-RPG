/// @description Slime AI Behavior
// You can write your code in this editor

// Find player
var player = instance_nearest(x, y, oPlayer);
var dist_to_player = infinity;
var can_see_player = false;

// Check if player exists and calculate distance
if (player != noone) {
    dist_to_player = point_distance(x, y, player.x, player.y);
    
    // Check line of sight to player
    can_see_player = !collision_line(x, y, player.x, player.y, oUtilityWall, false, true);
    
    // Update memory of player's position if visible
    if (can_see_player) {
        mob_pathfinding_set_last_known_position(player.x, player.y);
        lost_target_timer = 0;
        using_memory = false;
    } else if (state == "chase") {
        // If we lost sight of the player while chasing
        lost_target_timer++;
    }
}

// Reset movement variables for this frame
hspd = 0;
vspd = 0;

// Store previous speeds for smoothing
prev_hspd = hspd;
prev_vspd = vspd;

// STATE MANAGEMENT - Determine current state
if (player != noone) {
    if (can_see_player && dist_to_player <= detection_range) {
        // Player is visible and within detection range - enter chase state
        if (state != "chase") {
            // Debug message for detection
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
        
        state = "chase";
    } else if (state == "chase") {
        // Check if we should switch to investigate state (player not visible anymore)
        if (!can_see_player) {
            if (mob_pathfinding_memory_is_valid(memory_duration)) {
                // Still remember where player was - continue chasing but use memory
                using_memory = true;
            } else if (lost_target_timer >= investigate_time) {
                // Too much time has passed since seeing player - return to wandering
                state = "wander";
                // Reset wandering parameters
                change_dir_timer = 0;
                move_dir = irandom(359);
                
                // Debug message for losing player completely
                if (variable_global_exists("debug_mode") && global.debug_mode) {
                    var debug_msg = "Slime gave up searching for player";
                    show_debug_message(debug_msg);
                    
                    // Use player's debug log if available
                    var player_obj = instance_find(oPlayer, 0);
                    if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                        player_obj.debug_log(debug_msg, c_gray);
                    }
                }
            } else if (state != "investigate") {
                // Switch to investigate state
                state = "investigate";
                
                // Debug message for starting to investigate
                if (variable_global_exists("debug_mode") && global.debug_mode) {
                    var debug_msg = "Slime investigating last known player position";
                    show_debug_message(debug_msg);
                    
                    // Use player's debug log if available
                    var player_obj = instance_find(oPlayer, 0);
                    if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                        player_obj.debug_log(debug_msg, c_orange);
                    }
                }
            }
        } else {
            // Player is visible again, reset lost target timer
            lost_target_timer = 0;
        }
    }
}

// STATE BEHAVIOR - Act based on current state
if (state == "chase") {
    // CHASE STATE - Player is detected or remembered
    
    // Determine target position based on whether player is visible
    var target_x, target_y;
    
    if (can_see_player) {
        // If we can predict player movement and they're moving fast enough, aim ahead of them
        if (path_prediction && instance_exists(player) && 
            (abs(player.hspd) > 0.5 || abs(player.vspd) > 0.5)) {
            // Simple prediction - aim at where the player will be in a few frames
            var prediction_frames = 10; // Look ahead 10 frames
            target_x = player.x + (player.hspd * prediction_frames);
            target_y = player.y + (player.vspd * prediction_frames);
            
            // Make sure the predicted position is walkable
            if (place_meeting(target_x, target_y, oUtilityWall)) {
                // Fallback to current position if prediction is in a wall
                target_x = player.x;
                target_y = player.y;
            }
        } else {
            // Standard targeting
            target_x = player.x;
            target_y = player.y;
        }
    } else {
        target_x = last_known_target_x;
        target_y = last_known_target_y;
    }
    
    if (dist_to_player <= chase_range && can_see_player) {
        // DIRECT CHASE - Player is very close and visible, move directly toward them
        var dir_to_player = point_direction(x, y, player.x, player.y);
        
        // Use full chase speed when close to player
        // Only scale down when extremely close (< 5 pixels)
        var chase_factor = 1.0;
        if (dist_to_player < 5) {
            chase_factor = dist_to_player / 5;
        }
        
        // Clear any active path when doing direct chase to avoid conflicts
        if (path_get_number(path) > 0) {
            path_clear_points(path);
        }
        
        var raw_hspd = lengthdir_x(chase_spd * chase_factor, dir_to_player);
        var raw_vspd = lengthdir_y(chase_spd * chase_factor, dir_to_player);
        
        // Apply smoothing if enabled
        if (movement_smoothing) {
            hspd = raw_hspd * direct_smooth_factor + prev_hspd * (1 - direct_smooth_factor);
            vspd = raw_vspd * direct_smooth_factor + prev_vspd * (1 - direct_smooth_factor);
        } else {
            hspd = raw_hspd;
            vspd = raw_vspd;
        }
    } else {
        // A* PATHFINDING CHASE - Player is further away or not visible
        
        // Update path less frequently to save performance
        path_update_timer++;
        if (path_update_timer >= path_update_delay) {
            path_update_timer = 0;
            search_attempts = 0;
            
            // Find path to target using our pathfinding function
            mob_pathfinding_find_path(path, x, y, target_x, target_y, path_max_length);
            
            // Simplify path if that option is enabled
            if (path_point_simplification && path_get_number(path) > 3) {
                // Simple path simplification - remove points in a straight line
                var i = 1;
                while (i < path_get_number(path) - 1) {
                    var px1 = path_get_point_x(path, i-1);
                    var py1 = path_get_point_y(path, i-1);
                    var px2 = path_get_point_x(path, i);
                    var py2 = path_get_point_y(path, i);
                    var px3 = path_get_point_x(path, i+1);
                    var py3 = path_get_point_y(path, i+1);
                    
                    // Calculate angles between segments
                    var angle1 = point_direction(px1, py1, px2, py2);
                    var angle2 = point_direction(px2, py2, px3, py3);
                    
                    // If the angles are similar (within 5 degrees), this point is unnecessary
                    if (abs(angle_difference(angle1, angle2)) < 5) {
                        // This point is in a straight line, remove it
                        path_delete_point(path, i);
                    } else {
                        i++; // Only increment if we didn't remove a point
                    }
                }
            }
        }
        
        // Check if we have a valid path
        if (path_get_number(path) > 1) {
            // Get movement vector from pathfinding helper
            var move_data = mob_pathfinding_follow_path(path, chase_spd, 0);
            
            // Apply smoothing if enabled
            if (movement_smoothing) {
                hspd = move_data.hspd * path_smooth_factor + prev_hspd * (1 - path_smooth_factor);
                vspd = move_data.vspd * path_smooth_factor + prev_vspd * (1 - path_smooth_factor);
            } else {
                hspd = move_data.hspd;
                vspd = move_data.vspd;
            }
            
            // If we reached the end of our path and were using memory
            if (move_data.reached_end && using_memory) {
                // If we've reached the last known position and player isn't there
                if (!can_see_player) {
                    // Start a wider search by invalidating memory
                    lost_target_timer = investigate_time;
                }
            }
        } else {
            // No valid path found, try alternative methods
            search_attempts++;
            
            if (search_attempts < max_search_attempts) {
                // Try again with different parameters
                mob_pathfinding_find_path(path, x, y, target_x, target_y, path_max_length);
            } else {
                // Only use fallback if pathfinding completely fails after multiple attempts
                var dir_to_target = point_direction(x, y, target_x, target_y);
                
                // Check for walls in our direct path before choosing obstacle avoidance
                var wall_ahead = collision_line(x, y, 
                                             x + lengthdir_x(avoid_range, dir_to_target), 
                                             y + lengthdir_y(avoid_range, dir_to_target), 
                                             oUtilityWall, false, true);
                
                if (wall_ahead) {
                    // Wall in the way, try to find a clear direction
                    var test_angles = [45, -45, 90, -90, 135, -135];
                    var found_clear_path = false;
                    
                    for (var i = 0; i < array_length(test_angles); i++) {
                        var test_dir = dir_to_target + test_angles[i];
                        var test_x = x + lengthdir_x(avoid_range, test_dir);
                        var test_y = y + lengthdir_y(avoid_range, test_dir);
                        
                        if (!collision_line(x, y, test_x, test_y, oUtilityWall, false, true)) {
                            // Found a clear direction, use it
                            dir_to_target = test_dir;
                            found_clear_path = true;
                            break;
                        }
                    }
                    
                    if (!found_clear_path) {
                        // No clear path found, just pick a random direction
                        dir_to_target = irandom(359);
                    }
                }
                
                // Apply fallback movement with stronger smoothing for more natural movement
                var raw_hspd = lengthdir_x(chase_spd * 0.8, dir_to_target); // Slightly slower
                var raw_vspd = lengthdir_y(chase_spd * 0.8, dir_to_target);
                
                if (movement_smoothing) {
                    hspd = raw_hspd * fallback_smooth_factor + prev_hspd * (1 - fallback_smooth_factor);
                    vspd = raw_vspd * fallback_smooth_factor + prev_vspd * (1 - fallback_smooth_factor);
                } else {
                    hspd = raw_hspd;
                    vspd = raw_vspd;
                }
            }
        }
    }
} else if (state == "investigate") {
    // INVESTIGATE STATE - Player was seen but now is hidden
    
    // Move to the last known position of the player
    var target_x = last_known_target_x;
    var target_y = last_known_target_y;
    var dist_to_target = point_distance(x, y, target_x, target_y);
    
    // Check if we've reached the investigation point (or close enough)
    if (dist_to_target < 10) {
        // We've reached the last known position, continue searching for a bit
        lost_target_timer += 2; // Accelerate the timer when we're at the spot
        
        // Randomly look around
        if (irandom(100) < 15) { // 15% chance to change direction
            move_dir = irandom(359);
        }
        
        // Move slowly in random directions with some smoothing
        var raw_hspd = lengthdir_x(spd * 0.5, move_dir);
        var raw_vspd = lengthdir_y(spd * 0.5, move_dir);
        
        // Apply light smoothing for more responsive turns
        if (movement_smoothing) {
            var search_smoothing = 0.9; // High value for more responsive turns
            hspd = raw_hspd * search_smoothing + prev_hspd * (1 - search_smoothing);
            vspd = raw_vspd * search_smoothing + prev_vspd * (1 - search_smoothing);
        } else {
            hspd = raw_hspd;
            vspd = raw_vspd;
        }
    } else {
        // Use pathfinding to reach the last known position
        path_update_timer++;
        if (path_update_timer >= path_update_delay) {
            path_update_timer = 0;
            
            // Find path to last known position
            mob_pathfinding_find_path(path, x, y, target_x, target_y, path_max_length);
        }
        
        // Follow the path if one exists
        if (path_get_number(path) > 1) {
            var move_data = mob_pathfinding_follow_path(path, chase_spd * 0.75, 0);
            
            // Apply smoothing for path following
            if (movement_smoothing) {
                hspd = move_data.hspd * path_smooth_factor + prev_hspd * (1 - path_smooth_factor);
                vspd = move_data.vspd * path_smooth_factor + prev_vspd * (1 - path_smooth_factor);
            } else {
                hspd = move_data.hspd;
                vspd = move_data.vspd;
            }
        } else {
            // Direct path if no valid path found
            var dir_to_target = point_direction(x, y, target_x, target_y);
            var raw_hspd = lengthdir_x(chase_spd * 0.75, dir_to_target);
            var raw_vspd = lengthdir_y(chase_spd * 0.75, dir_to_target);
            
            // Apply smoothing for direct movement
            if (movement_smoothing) {
                var direct_smoothing = 0.7;
                hspd = raw_hspd * direct_smoothing + prev_hspd * (1 - direct_smoothing);
                vspd = raw_vspd * direct_smoothing + prev_vspd * (1 - direct_smoothing);
            } else {
                hspd = raw_hspd;
                vspd = raw_vspd;
            }
        }
    }
    
    // Check if investigate time has expired
    if (lost_target_timer >= investigate_time) {
        // Switch back to wandering
        state = "wander";
        change_dir_timer = 0;
        move_dir = irandom(359);
        
        // Debug message
        if (variable_global_exists("debug_mode") && global.debug_mode) {
            var debug_msg = "Slime gave up searching and returned to wandering";
            show_debug_message(debug_msg);
            
            // Use player's debug log if available
            var player_obj = instance_find(oPlayer, 0);
            if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                player_obj.debug_log(debug_msg, c_gray);
            }
        }
    }
} else if (state == "wander") {
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
            var raw_hspd = lengthdir_x(spd, move_dir);
            var raw_vspd = lengthdir_y(spd, move_dir);
            
            // Apply smoothing for wander movement
            if (movement_smoothing) {
                var wander_smoothing = 0.3; // Low value for very smooth wandering
                hspd = raw_hspd * wander_smoothing + prev_hspd * (1 - wander_smoothing);
                vspd = raw_vspd * wander_smoothing + prev_vspd * (1 - wander_smoothing);
            } else {
                hspd = raw_hspd;
                vspd = raw_vspd;
            }
            
            // Check for collision in the movement direction
            var will_hit_wall = collision_line(x, y, x + hspd * avoid_range, y + vspd * avoid_range, 
                                              oUtilityWall, false, true);
            
            if (will_hit_wall) {
                // About to hit a wall, change direction to bounce off
                move_dir = (move_dir + 180 + irandom_range(-45, 45)) % 360;
                
                // Recalculate movement with the new direction
                raw_hspd = lengthdir_x(spd, move_dir);
                raw_vspd = lengthdir_y(spd, move_dir);
                
                // Apply sharper turn for obstacles (more responsive)
                if (movement_smoothing) {
                    var bounce_smoothing = 0.6; // Higher value for more responsive obstacle avoidance
                    hspd = raw_hspd * bounce_smoothing + prev_hspd * (1 - bounce_smoothing);
                    vspd = raw_vspd * bounce_smoothing + prev_vspd * (1 - bounce_smoothing);
                } else {
                    hspd = raw_hspd;
                    vspd = raw_vspd;
                }
                
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

// Update facing direction based on movement
// This is important for sprite flipping in the Draw event
if (hspd != 0) {
    // Set facing based on horizontal movement
    // When moving right (positive hspd), face right
    // When moving left (negative hspd), face left
    facing_right = (hspd > 0);
} else if (vspd != 0 && (state == "chase" || state == "investigate")) {
    // Only update facing during vertical movement if actively chasing/investigating
    var player = instance_nearest(x, y, oPlayer);
    if (player != noone) {
        // Face toward player's position
        facing_right = (player.x > x);
    }
} else if (state == "wander" && move_dir != -1) {
    // Update facing based on wander direction
    // Right-side directions (between 270 and 90 degrees) should face right
    facing_right = (move_dir < 90 || move_dir > 270);
}

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