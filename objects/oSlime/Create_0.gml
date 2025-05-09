/// @description Initialize Slime
// You can write your code in this editor

// Movement properties
spd = 0.3;               // Base movement speed (increased)
chase_spd = .75;         // Speed when chasing player (increased significantly)
detection_range = 100;   // Range to detect player
chase_range = 75;        // Range to start chasing player directly
avoid_range = 50;        // Range to start avoiding obstacles

// Velocity variables for collision handling
hspd = 0;                // Horizontal speed (current)
vspd = 0;                // Vertical speed (current)

// Movement state and timers
move_dir = irandom(359);  // Random initial direction (0-359 degrees)
change_dir_timer = 0;
change_dir_delay = room_speed * irandom_range(1, 3); // Change direction every 1-3 seconds
facing_right = false;     // Track facing direction for sprite flipping (false = left, true = right)

// Pathfinding variables 
path = path_add();        // Create a new path for the slime
path_update_timer = 0;
path_update_delay = room_speed * 0.5; // Update path every half second when chasing

// State tracking
state = "wander";         // Current state: "wander", "chase", "idle"
wander_pause_timer = 0;   // Timer for pausing during wandering
wander_pause_duration = 0; // Duration to pause 

// Debug control variables
room_entry_frames = 0;    // Used to prevent debug flashing during room transitions

// Explicitly check and sync with global debug state (initializing if needed)
if (!variable_global_exists("debug_mode")) {
    if (script_exists(asset_get_index("game_debug_system_init"))) {
        game_debug_system_init();
        global.debug_mode = false; // Default to debug OFF
    }
}

// Initialize random seed
randomize(); 