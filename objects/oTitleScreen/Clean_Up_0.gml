/// @description Clean up resources
// You can write your code in this editor

// Destroy buttons
if (instance_exists(start_button)) {
    instance_destroy(start_button);
}

if (instance_exists(quit_button)) {
    instance_destroy(quit_button);
}

if (instance_exists(settings_button)) {
    instance_destroy(settings_button);
} 