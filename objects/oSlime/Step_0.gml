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
        seen_player = true; // Mark that we've seen the player
    }
}

// Reset movement variables for this frame
hspd = 0;
vspd = 0;

// Store previous speeds for smoothing
prev_hspd_stored = prev_hspd;
prev_vspd_stored = prev_vspd;
prev_hspd = hspd;
prev_vspd = vspd;

// STATE MANAGEMENT - Determine current state
if (player != noone) {
    // Player position memory is already handled at the start of the step event
    
    if (can_see_player && dist_to_player <= chase_range) {
        // Player is visible and within chase range - enter chase state
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
        going_to_last_seen = false; // Reset this flag when actively chasing
    } else if (state == "chase") {
        // If we're chasing but player is no longer visible
        if (!can_see_player) {
            // Player is no longer visible - go to last known position
            state = "wander";
            going_to_last_seen = true;
            // Force immediate path update
            path_update_timer = path_update_delay; // This will trigger path update immediately
            
            // Verify the last known position is valid
            if (last_known_target_x == -1 || last_known_target_y == -1) {
                // This should never happen, but if it does, set a fallback position
                show_debug_message("ERROR: Invalid last known position, setting fallback");
                last_known_target_x = x + irandom_range(-100, 100);
                last_known_target_y = y + irandom_range(-100, 100);
                seen_player = true;
            }
            
            // Debug message
            if (variable_global_exists("debug_mode") && global.debug_mode) {
                var debug_msg = "Slime lost sight of player - heading to last known position";
                show_debug_message(debug_msg);
                show_debug_message("Last known position set to: [" + string(last_known_target_x) + ", " + string(last_known_target_y) + "]");
                show_debug_message("Current position: [" + string(x) + ", " + string(y) + "]");
                show_debug_message("Distance to last known: " + string(point_distance(x, y, last_known_target_x, last_known_target_y)));
                
                // Use player's debug log if available
                var player_obj = instance_find(oPlayer, 0);
                if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                    player_obj.debug_log(debug_msg, c_orange);
                }
            }
        } else if (dist_to_player > chase_range) {
            // Player is visible but outside chase range - just wander
            state = "wander";
            going_to_last_seen = false;
            // Reset wandering parameters
            change_dir_timer = 0;
            move_dir = irandom(359);
            
            // Debug message for player moving out of range
            if (variable_global_exists("debug_mode") && global.debug_mode) {
                var debug_msg = "Player moved out of chase range, slime returned to wandering";
                show_debug_message(debug_msg);
                
                // Use player's debug log if available
                var player_obj = instance_find(oPlayer, 0);
                if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                    player_obj.debug_log(debug_msg, c_gray);
                }
            }
        }
    } else if (state == "wander" && can_see_player && dist_to_player <= chase_range) {
        // If we're wandering but the player comes into chase range and is visible
        state = "chase";
        going_to_last_seen = false;
        
        // Debug message
        if (variable_global_exists("debug_mode") && global.debug_mode) {
            var debug_msg = "Slime spotted player within chase range";
            show_debug_message(debug_msg);
        }
    }
}

// STATE BEHAVIOR - Act based on current state
if (state == "chase") {
    // CHASE STATE - Player is detected
    
    // Direct targeting only when player is visible
    if (can_see_player) {
        var target_x, target_y;
        
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
        
        // Check for obstacles between slime and player
        var has_clear_path = !collision_line(x, y, target_x, target_y, oUtilityWall, false, true);
        
        // Use direct movement only when very close AND with a clear path
        if (dist_to_player <= chase_range && has_clear_path) {
            // DIRECT CHASE - Player is very close and directly visible (no obstacles)
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
                hspd = raw_hspd * direct_smooth_factor + prev_hspd_stored * (1 - direct_smooth_factor);
                vspd = raw_vspd * direct_smooth_factor + prev_vspd_stored * (1 - direct_smooth_factor);
            } else {
                hspd = raw_hspd;
                vspd = raw_vspd;
            }
            
            // Debug message
            if (variable_global_exists("debug_mode") && global.debug_mode) {
                show_debug_message("Slime using direct movement to player");
            }
        } else {
            // A* PATHFINDING CHASE - Player is either further away or there are obstacles
            
            // Update path less frequently to save performance
            path_update_timer++;
            if (path_update_timer >= path_update_delay) {
                path_update_timer = 0;
                search_attempts = 0;
                
                // Find path to target using our pathfinding function
                var path_found = mob_pathfinding_find_path(path, x, y, target_x, target_y, path_max_length);
                
                // Debug message for pathfinding result
                if (variable_global_exists("debug_mode") && global.debug_mode) {
                    show_debug_message("Slime pathfinding result: " + (path_found ? "Path found" : "No path found"));
                }
                
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
                    hspd = move_data.hspd * path_smooth_factor + prev_hspd_stored * (1 - path_smooth_factor);
                    vspd = move_data.vspd * path_smooth_factor + prev_vspd_stored * (1 - path_smooth_factor);
                } else {
                    hspd = move_data.hspd;
                    vspd = move_data.vspd;
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
                    
                    // Debug message for fallback movement
                    if (variable_global_exists("debug_mode") && global.debug_mode) {
                        show_debug_message("Slime using fallback movement");
                    }
                    
                    // Apply fallback movement with stronger smoothing for more natural movement
                    var raw_hspd = lengthdir_x(chase_spd * 0.8, dir_to_target); // Slightly slower
                    var raw_vspd = lengthdir_y(chase_spd * 0.8, dir_to_target);
                    
                    if (movement_smoothing) {
                        hspd = raw_hspd * fallback_smooth_factor + prev_hspd_stored * (1 - fallback_smooth_factor);
                        vspd = raw_vspd * fallback_smooth_factor + prev_vspd_stored * (1 - fallback_smooth_factor);
                    } else {
                        hspd = raw_hspd;
                        vspd = raw_vspd;
                    }
                }
            }
        }
    } else {
        // Lost sight of player, switch to wandering
        state = "wander";
        going_to_last_seen = true; // Go to last known position
        
        // Force immediate path update
        path_update_timer = path_update_delay; // This will trigger path update immediately
        
        // Debug message
        if (variable_global_exists("debug_mode") && global.debug_mode) {
            var debug_msg = "Slime lost sight of player - heading to last known position";
            show_debug_message(debug_msg);
            show_debug_message("Last known position set to: [" + string(last_known_target_x) + ", " + string(last_known_target_y) + "]");
        }
    }
} else if (state == "wander") {
    // WANDER STATE - Either random wandering or going to last seen position
    
    // If we're going to the last known player position
    if (going_to_last_seen && last_known_target_x != -1 && last_known_target_y != -1) {
        // Use A* pathfinding to go to the last known position
        path_update_timer++;
        
        // Debug current status every few frames
        if (variable_global_exists("debug_mode") && global.debug_mode && (path_update_timer % 30 == 0)) {
            show_debug_message("ONGOING: Slime going to last seen [" + string(last_known_target_x) + 
                               ", " + string(last_known_target_y) + "], current pos [" + 
                               string(x) + ", " + string(y) + "], distance: " + 
                               string(point_distance(x, y, last_known_target_x, last_known_target_y)));
        }
        
        // Force path update if no path or update timer triggered
        if (path_update_timer >= path_update_delay || path_get_number(path) <= 1) {
            path_update_timer = 0;
            search_attempts = 0;
            
            // Try to find a path to the last known position
            var path_found = mob_pathfinding_find_path(path, x, y, last_known_target_x, last_known_target_y, path_max_length);
            
            if (variable_global_exists("debug_mode") && global.debug_mode) {
                show_debug_message("Finding path to last known position: " + (path_found ? "Success" : "Failed"));
                show_debug_message("Last known position: [" + string(last_known_target_x) + ", " + string(last_known_target_y) + "]");
                if (path_found) {
                    show_debug_message("Path points: " + string(path_get_number(path)));
                }
            }
        }
        
        // Calculate distance to the last known position
        var dist_to_last_known = point_distance(x, y, last_known_target_x, last_known_target_y);
        
        // Check if we've reached the destination or got very close
        if (dist_to_last_known < 10) {
            // We've reached the last known position
            
            // Check if player is now in sight and within chase range
            if (can_see_player && dist_to_player <= chase_range) {
                // Player is visible and within chase range - resume chase
                state = "chase";
                going_to_last_seen = false;
                
                // Debug message
                if (variable_global_exists("debug_mode") && global.debug_mode) {
                    var debug_msg = "Slime reached last known position and found player - resuming chase";
                    show_debug_message(debug_msg);
                    
                    // Use player's debug log if available
                    var player_obj = instance_find(oPlayer, 0);
                    if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                        player_obj.debug_log(debug_msg, c_lime);
                    }
                }
            } else {
                // Player not found - resume normal wandering
                going_to_last_seen = false;
                change_dir_timer = 0; 
                move_dir = irandom(359);
                
                // Debug message
                if (variable_global_exists("debug_mode") && global.debug_mode) {
                    var debug_msg = "Slime reached last known player position - player not found - resuming wandering";
                    show_debug_message(debug_msg);
                    
                    // Use player's debug log if available
                    var player_obj = instance_find(oPlayer, 0);
                    if (player_obj != noone && variable_instance_exists(player_obj, "debug_log")) {
                        player_obj.debug_log(debug_msg, c_gray);
                    }
                }
            }
        } else {
            // We haven't reached the destination yet - move toward it
            var movement_handled = false;
            
            // Check if we have a valid path and try to follow it
            if (path_get_number(path) > 1) {
                // Get movement vector from pathfinding helper
                var move_data = mob_pathfinding_follow_path(path, chase_spd, 0); // Use chase_spd
                
                // Apply smoothing if enabled
                if (movement_smoothing) {
                    hspd = move_data.hspd * path_smooth_factor + prev_hspd_stored * (1 - path_smooth_factor);
                    vspd = move_data.vspd * path_smooth_factor + prev_vspd_stored * (1 - path_smooth_factor);
                } else {
                    hspd = move_data.hspd;
                    vspd = move_data.vspd;
                }
                
                movement_handled = true;
                
                // Debug path following
                if (variable_global_exists("debug_mode") && global.debug_mode && (path_update_timer % 30 == 0)) {
                    show_debug_message("MOVEMENT: Following path to last known position, movement vector: [" + 
                                      string(hspd) + ", " + string(vspd) + "]");
                }
            }
            
            // If no valid path was found, or movement is not producing results, use direct movement as fallback
            if (!movement_handled || (abs(hspd) < 0.1 && abs(vspd) < 0.1)) {
                // Check if there's a direct path
                var direct_path_clear = !collision_line(x, y, last_known_target_x, last_known_target_y, oUtilityWall, false, true);
                
                // If direct path is clear, or we've been stuck too long, go direct
                if (direct_path_clear) {
                    // Direct movement toward the last known position
                    var dir_to_last_known = point_direction(x, y, last_known_target_x, last_known_target_y);
                    var raw_hspd = lengthdir_x(chase_spd, dir_to_last_known);
                    var raw_vspd = lengthdir_y(chase_spd, dir_to_last_known);
                    
                    if (movement_smoothing) {
                        var direct_smooth = 0.5; // Moderate smoothing
                        hspd = raw_hspd * direct_smooth + prev_hspd_stored * (1 - direct_smooth);
                        vspd = raw_vspd * direct_smooth + prev_vspd_stored * (1 - direct_smooth);
                    } else {
                        hspd = raw_hspd;
                        vspd = raw_vspd;
                    }
                    
                    // Debug direct movement
                    if (variable_global_exists("debug_mode") && global.debug_mode) {
                        show_debug_message("FALLBACK: Using direct movement to last known position");
                    }
                } else {
                    // Try obstacle avoidance if direct path isn't clear
                    var found_direction = false;
                    var best_angle = 0;
                    var max_clear_distance = 0;
                    
                    // Try to find the direction with the most clearance
                    var test_angles = [0, 45, -45, 90, -90, 135, -135, 180];
                    
                    for (var i = 0; i < array_length(test_angles); i++) {
                        var test_angle = test_angles[i];
                        var max_test_distance = 48; // Test further
                        var clear_distance = 0;
                        
                        // Check how far we can go in this direction
                        for (var dist = 8; dist <= max_test_distance; dist += 8) {
                            var test_x = x + lengthdir_x(dist, test_angle);
                            var test_y = y + lengthdir_y(dist, test_angle);
                            
                            if (collision_line(x, y, test_x, test_y, oUtilityWall, false, true)) {
                                break;
                            }
                            clear_distance = dist;
                        }
                        
                        // If this direction has more clearance than previous best
                        if (clear_distance > max_clear_distance) {
                            max_clear_distance = clear_distance;
                            best_angle = test_angle;
                            found_direction = true;
                        }
                    }
                    
                    if (found_direction) {
                        // Use the direction with the most clearance
                        var raw_hspd = lengthdir_x(chase_spd * 0.75, best_angle);
                        var raw_vspd = lengthdir_y(chase_spd * 0.75, best_angle);
                        
                        // Preserve facing during obstacle avoidance if moving sideways
                        var facing_preserving_angle = abs(best_angle);
                        if (facing_preserving_angle >= 45 && facing_preserving_angle <= 135) {
                            // Moving mostly vertically, don't change facing
                            last_facing_change = current_time + 15; // Extended cooldown
                        }
                        
                        if (movement_smoothing) {
                            var avoidance_smooth = 0.5; // Less responsive, smoother movement
                            hspd = raw_hspd * avoidance_smooth + prev_hspd_stored * (1 - avoidance_smooth);
                            vspd = raw_vspd * avoidance_smooth + prev_vspd_stored * (1 - avoidance_smooth);
                        } else {
                            hspd = raw_hspd;
                            vspd = raw_vspd;
                        }
                        
                        // Debug obstacle avoidance
                        if (variable_global_exists("debug_mode") && global.debug_mode && (path_update_timer % 30 == 0)) {
                            show_debug_message("AVOIDANCE: Using direction with most clearance: " + string(best_angle) + "°, clearance: " + string(max_clear_distance));
                        }
                    } else {
                        // If still stuck, try a random direction
                        var random_dir = irandom(359);
                        var raw_hspd = lengthdir_x(chase_spd * 0.5, random_dir);
                        var raw_vspd = lengthdir_y(chase_spd * 0.5, random_dir);
                        
                        if (movement_smoothing) {
                            var random_smooth = 0.8; // Very responsive for escaping
                            hspd = raw_hspd * random_smooth + prev_hspd_stored * (1 - random_smooth);
                            vspd = raw_vspd * random_smooth + prev_vspd_stored * (1 - random_smooth);
                        } else {
                            hspd = raw_hspd;
                            vspd = raw_vspd;
                        }
                        
                        // Prevent facing changes during random movement
                        last_facing_change = current_time + 20; // Extra long cooldown
                        
                        // Debug random movement
                        if (variable_global_exists("debug_mode") && global.debug_mode) {
                            show_debug_message("EMERGENCY: Using random movement to escape, completely stuck");
                        }
                    }
                }
            }
        }
    } else {
        // Normal wandering behavior
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
                    hspd = raw_hspd * wander_smoothing + prev_hspd_stored * (1 - wander_smoothing);
                    vspd = raw_vspd * wander_smoothing + prev_vspd_stored * (1 - wander_smoothing);
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
                        hspd = raw_hspd * bounce_smoothing + prev_hspd_stored * (1 - bounce_smoothing);
                        vspd = raw_vspd * bounce_smoothing + prev_vspd_stored * (1 - bounce_smoothing);
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
}

// === IMPROVED PIXEL-PERFECT COLLISION HANDLING ===
// Horizontal Collision Check - Pixel perfect approach
if (hspd != 0) {
    if (place_meeting(x + hspd, y, oUtilityWall)) {
        // Move as close as possible to the wall
        var step_size = sign(hspd);
        var iterations = 0;
        var max_iterations = ceil(abs(hspd)) + 2; // Add buffer to prevent infinite loops
        
        while (!place_meeting(x + step_size, y, oUtilityWall) && iterations < max_iterations) {
            x += step_size;
            iterations++;
        }
        
        hspd = 0; // Stop horizontal movement completely
        
        // When hitting a wall, don't change facing for a while
        last_facing_change = current_time + 30; // Extended cooldown to prevent flickering
    }
}

// Apply horizontal movement only after collision check
x += hspd;

// Vertical Collision Check - Pixel perfect approach
if (vspd != 0) {
    if (place_meeting(x, y + vspd, oUtilityWall)) {
        // Move as close as possible to the wall
        var step_size = sign(vspd);
        var iterations = 0;
        var max_iterations = ceil(abs(vspd)) + 2; // Add buffer to prevent infinite loops
        
        while (!place_meeting(x, y + step_size, oUtilityWall) && iterations < max_iterations) {
            y += step_size;
            iterations++;
        }
        
        vspd = 0; // Stop vertical movement completely
    }
}

// Apply vertical movement only after collision check
y += vspd;

// Store current movement direction for stability
var current_movement_dir = -1;
if (hspd != 0 || vspd != 0) {
    current_movement_dir = point_direction(0, 0, hspd, vspd);
}

// Facing direction stability variables - these should be initialized in Create event
if (!variable_instance_exists(id, "facing_stability_timer")) {
    facing_stability_timer = 0;
    facing_cooldown = 15; // Frames to wait before allowing facing change
    last_facing_change = current_time;
    facing_change_debounce = false;
    facing_history = array_create(5, facing_right); // Track last 5 facing states
}

// Update facing history array (for debouncing)
if (!variable_instance_exists(id, "facing_history_index")) {
    facing_history_index = 0;
}
facing_history_index = (facing_history_index + 1) % array_length(facing_history);
facing_history[facing_history_index] = facing_right;

// Function to check if facing is stable (not flickering)
var is_facing_stable = function() {
    var all_same = true;
    var first_value = facing_history[0];
    for (var i = 1; i < array_length(facing_history); i++) {
        if (facing_history[i] != first_value) {
            all_same = false;
            break;
        }
    }
    return all_same;
};

// Update facing direction based on movement with stability protection
// This is important for sprite flipping in the Draw event
if (hspd != 0) {
    // Calculate if we should change facing
    var new_facing = (hspd > 0);
    
    // Special case: if extremely slow movement, maintain current facing
    if (abs(hspd) < 0.08) {
        // Skip facing update for very tiny movements
        // This prevents flickering when slime is against a wall or in tight spaces
        // Nothing to do here - keep current facing
    } else {
        // Only change facing if:
        // 1. The new direction is different from current
        // 2. The movement is significant enough
        // 3. Enough time has passed since last change
        if (new_facing != facing_right) {
            // Check if we're still in cooldown
            if (current_time - last_facing_change < facing_cooldown) {
                // Still in cooldown, accumulate consistency
                facing_stability_timer++;
                
                // Only change if consistent movement for extended period
                if (facing_stability_timer >= 12) { // Increased for more stability
                    // Prepare for facing change (debounce)
                    facing_change_debounce = true;
                }
            } else {
                // Cooldown expired, check if we should change
                if (facing_change_debounce) {
                    // If stable enough, make the change
                    facing_right = new_facing;
                    facing_change_debounce = false;
                    facing_stability_timer = 0;
                    last_facing_change = current_time;
                    
                    // Reset facing history
                    for (var i = 0; i < array_length(facing_history); i++) {
                        facing_history[i] = new_facing;
                    }
                } else {
                    // Start debounce process
                    facing_change_debounce = true;
                    facing_stability_timer = 0;
                }
            }
        } else {
            // Moving in current facing direction, reinforce stability
            facing_stability_timer = 0;
            facing_change_debounce = false;
        }
    }
} else if (vspd != 0 && state == "chase") {
    // Only update facing during vertical movement if actively chasing
    var player = instance_nearest(x, y, oPlayer);
    if (player != noone) {
        // Face toward player's position, but with stability checks
        var should_face_right = (player.x > x);
        
        // Only change if it's different and cooldown has passed
        if (should_face_right != facing_right) {
            if (current_time - last_facing_change >= facing_cooldown * 2) { // Double cooldown for vertical movement
                // Update facing history to check stability
                var all_same = true;
                for (var i = 0; i < array_length(facing_history); i++) {
                    if (facing_history[i] != facing_right) {
                        all_same = false;
                        break;
                    }
                }
                
                // Only change if previous facing was stable
                if (all_same) {
                    facing_right = should_face_right;
                    last_facing_change = current_time;
                    
                    // Reset facing history
                    for (var i = 0; i < array_length(facing_history); i++) {
                        facing_history[i] = should_face_right;
                    }
                }
            }
        }
    }
} else if (state == "wander" && move_dir != -1) {
    // Update facing based on wander direction with stability
    // Right-side directions (between 270 and 90 degrees) should face right
    var should_face_right = (move_dir < 90 || move_dir > 270);
    
    // Only change if it's different, cooldown has passed, and previous facing was stable
    if (should_face_right != facing_right) {
        if (current_time - last_facing_change >= facing_cooldown * 1.5) { // 1.5x cooldown for wandering
            // Check if previous facing was stable
            var all_same = true;
            for (var i = 0; i < array_length(facing_history); i++) {
                if (facing_history[i] != facing_right) {
                    all_same = false;
                    break;
                }
            }
            
            // Only change if previous facing was stable
            if (all_same) {
                facing_right = should_face_right;
                last_facing_change = current_time;
                
                // Reset facing history
                for (var i = 0; i < array_length(facing_history); i++) {
                    facing_history[i] = should_face_right;
                }
            }
        }
    }
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