/// @description Free memory
// You can write your code in this editor

// Free data structures
if (ds_exists(debug_logs, ds_type_list)) {
    ds_list_destroy(debug_logs);
}

if (ds_exists(debug_log_colors, ds_type_list)) {
    ds_list_destroy(debug_log_colors);
} 