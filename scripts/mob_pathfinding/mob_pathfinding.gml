/// @function mob_pathfinding_find_path(path_id, start_x, start_y, target_x, target_y, max_path_length)
/// @description Finds an A* path from start to target position, with optional memory of last known position
/// @param {Id.Path} path_id Path to store the route
/// @param {Real} start_x Starting X position 
/// @param {Real} start_y Starting Y position
/// @param {Real} target_x Target X position
/// @param {Real} target_y Target Y position
/// @param {Real} max_path_length Maximum distance to consider pathfinding
/// @returns {Bool} True if path was found, false otherwise
function mob_pathfinding_find_path(path_id, start_x, start_y, target_x, target_y, max_path_length) {
    // Ensure pathfinding is initialized
    if (!variable_global_exists("pathfinding_initialized") || !global.pathfinding_initialized) {
        show_debug_message("Warning: Attempting to pathfind before initialization");
        return false;
    }
    
    // Clear any existing path
    path_clear_points(path_id);
    
    // Calculate direct distance
    var direct_dist = point_distance(start_x, start_y, target_x, target_y);
    
    // If target is too far away, don't bother pathfinding
    if (direct_dist > max_path_length) {
        return false;
    }

    // First attempt - Find path normally
    var path_found = mp_grid_path(global.mp_grid, path_id, start_x, start_y, target_x, target_y, true);
    
    // Check if path was found and has points
    if (path_found && path_get_number(path_id) > 0) {
        return true;
    }
    
    // If direct path failed, try finding a path to a nearby location
    var angle_step = 45; // Try 8 directions
    var search_range_step = 16; // Increment by 16 pixels (grid cell size)
    var max_search_range = 80; // Maximum search distance for alternative target
    
    for (var search_range = search_range_step; search_range <= max_search_range; search_range += search_range_step) {
        for (var angle = 0; angle < 360; angle += angle_step) {
            var alt_x = target_x + lengthdir_x(search_range, angle);
            var alt_y = target_y + lengthdir_y(search_range, angle);
            
            // Check if this position is walkable
            if (!mp_grid_get_cell(global.mp_grid, alt_x div 16, alt_y div 16)) {
                // Try to find a path to this alternative position
                if (mp_grid_path(global.mp_grid, path_id, start_x, start_y, alt_x, alt_y, true)) {
                    return true;
                }
            }
        }
    }
    
    // No path found after all attempts
    return false;
}

/// @function mob_pathfinding_follow_path(path_id, move_speed, start_path_position)
/// @description Makes a mob follow a path and returns movement speeds
/// @param {Id.Path} path_id Path to follow
/// @param {Real} move_speed Speed to move at
/// @param {Real} start_path_position Starting position on the path (0-1)
/// @returns {Struct} Contains hspd and vspd movement values
function mob_pathfinding_follow_path(path_id, move_speed, start_path_position = 0) {
    var result = {
        hspd: 0,
        vspd: 0,
        reached_end: false
    };
    
    // Check if path exists and has points
    if (path_id == -1 || path_get_number(path_id) <= 1) {
        return result;
    }
    
    // Get the next point on the path
    var path_point = max(1, start_path_position * (path_get_number(path_id) - 1));
    var target_x = path_get_point_x(path_id, path_point);
    var target_y = path_get_point_y(path_id, path_point);
    
    // Calculate direction to that point
    var path_dir = point_direction(x, y, target_x, target_y);
    
    // Calculate movement speeds
    result.hspd = lengthdir_x(move_speed, path_dir);
    result.vspd = lengthdir_y(move_speed, path_dir);
    
    // Check if we've reached the end of the path
    var dist_to_target = point_distance(x, y, target_x, target_y);
    if (dist_to_target < move_speed) {
        result.reached_end = true;
    }
    
    return result;
}

/// @function mob_pathfinding_set_last_known_position(x_pos, y_pos)
/// @description Stores the last known position of a target for a mob
/// @param {Real} x_pos X position of the target
/// @param {Real} y_pos Y position of the target
function mob_pathfinding_set_last_known_position(x_pos, y_pos) {
    // Store last known position in mob's instance variables
    last_known_target_x = x_pos;
    last_known_target_y = y_pos;
    last_known_target_time = current_time;
}

/// @function mob_pathfinding_memory_is_valid(memory_duration)
/// @description Checks if the stored memory of a target's position is still valid
/// @param {Real} memory_duration How long to remember the position in milliseconds
/// @returns {Bool} True if memory is still valid
function mob_pathfinding_memory_is_valid(memory_duration) {
    if (variable_instance_exists(id, "last_known_target_time")) {
        var time_elapsed = current_time - last_known_target_time;
        return (time_elapsed < memory_duration);
    }
    return false;
}