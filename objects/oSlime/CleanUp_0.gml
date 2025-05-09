/// @description Free resources
// You can write your code in this editor

// Free the path resource to prevent memory leaks
if (path_exists(path)) {
    path_delete(path);
} 