/// @function mob_pathfinding_init()
/// @description Initializes pathfinding grid for the current room
function mob_pathfinding_init() {
    // Check if grid already exists and clean it up
    if (variable_global_exists("mp_grid")) {
        mp_grid_destroy(global.mp_grid);
    }
    
    // Get room dimensions
    var room_width_cells = room_width div 16;
    var room_height_cells = room_height div 16;
    
    // Create motion planning grid (cell size of 16x16 pixels)
    global.mp_grid = mp_grid_create(0, 0, room_width_cells, room_height_cells, 16, 16);
    
    // Add solid instances to the grid (making them obstacles)
    mp_grid_add_instances(global.mp_grid, oUtilityWall, true);
    
    // Optional: Add any other obstacle objects that should block movement
    // mp_grid_add_instances(global.mp_grid, oWater, true);
    // mp_grid_add_instances(global.mp_grid, oLava, true);
    
    // Set global flag indicating the grid is ready
    global.pathfinding_initialized = true;
    
    // Debug message
    show_debug_message("Pathfinding grid initialized for room: " + room_get_name(room));
}