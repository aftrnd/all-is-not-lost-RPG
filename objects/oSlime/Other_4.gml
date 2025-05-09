/// @description Ensure pathfinding is initialized
// You can write your code in this editor

// Check if pathfinding grid exists, if not, initialize it
if (!variable_global_exists("pathfinding_initialized") || !global.pathfinding_initialized) {
    // Initialize the motion planning grid for this room
    mob_pathfinding_init();
} 