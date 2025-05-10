/// @description Initialize Slime
// You can write your code in this editor

// Movement properties
spd = 0.5;               // Base movement speed (increased)
chase_spd = .75;         // Speed when chasing player (increased significantly)
detection_range = 125;   // Range to detect player
chase_range = 100;       // Range to start chasing player directly (reduced from 75)
avoid_range = 50;        // Range to avoid obstacles

// Movement smoothing
movement_smoothing = true;    // Whether to apply smoothing (can be toggled)
prev_hspd = 0;                // Previous horizontal speed for smoothing
prev_vspd = 0;                // Previous vertical speed for smoothing
prev_hspd_stored = 0;         // Stored previous horizontal speed for consistent smoothing
prev_vspd_stored = 0;         // Stored previous vertical speed for consistent smoothing
direct_smooth_factor = 0.8;   // Direct chase smoothing (80% new, 20% old)
path_smooth_factor = 0.7;     // Path following smoothing
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
path_max_length = 300;          // Maximum path length to consider
search_attempts = 0;            // How many search attempts have been made
max_search_attempts = 3;        // Maximum number of attempts before giving up
seen_player = false;            // Whether the slime has seen the player
going_to_last_seen = false;     // Whether the slime is currently going to the last seen position

// Facing direction stability
facing_stability_timer = 0;     // Counter for consistent movement in one direction
facing_cooldown = 20;           // Frames to wait before allowing facing change (increased from 15)
last_facing_change = current_time; // When facing direction last changed
facing_change_debounce = false; // Whether we're in debounce mode for facing changes
facing_history = array_create(5, false); // Track last 5 facing states for stability
facing_history_index = 0;       // Current index in facing history array

// State tracking
state = "wander";         // Current state: "wander" or "chase"
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