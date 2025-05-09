/// @description Free resources
// You can write your code in this editor

// Free the path resource to prevent memory leaks
if (path_exists(path)) {
    path_delete(path);
}

// Debug cleanup message
if (variable_global_exists("debug_mode") && global.debug_mode) {
    show_debug_message("Slime destroyed at position: [" + string(x) + ", " + string(y) + "]");
} 