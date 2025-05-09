/// @description Initialize Slime
// You can write your code in this editor

// Movement properties
spd = 0.3;               // Base movement speed (increased)
chase_spd = .75;         // Speed when chasing player (increased significantly)
detection_range = 100;   // Range to detect player
chase_range = 75;        // Range to start chasing player directly
avoid_range = 50;        // Range to avoid obstacles

// Movement smoothing
movement_smoothing = true;   // Whether to apply smoothing (can be toggled)
prev_hspd = 0;               // Previous horizontal speed for smoothing
prev_vspd = 0;               // Previous vertical speed for smoothing
direct_smooth_factor = 0.8;  // Direct chase smoothing (80% new, 20% old)
path_smooth_factor = 0.7;    // Path following smoothing
fallback_smooth_factor = 0.5; // Fallback movement smoothing (more aggressive)

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
path_point_simplification = true;    // Whether to simplify paths for smoother movement
path_prediction = true;              // Whether to predict player movement for better targeting

// Enhanced pathfinding variables
last_known_target_x = -1;       // Last known player X position
last_known_target_y = -1;       // Last known player Y position
last_known_target_time = 0;     // When the player was last seen
memory_duration = 5000;         // How long to remember player position (in milliseconds)
path_max_length = 300;          // Maximum path length to consider
search_attempts = 0;            // How many search attempts have been made
max_search_attempts = 3;        // Maximum number of attempts before giving up
using_memory = false;           // Whether currently using memory to find player
lost_target_timer = 0;          // Timer for how long the target has been lost
investigate_time = room_speed * 8; // How long to investigate the last known position

// State tracking
state = "wander";         // Current state: "wander", "chase", "investigate"
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