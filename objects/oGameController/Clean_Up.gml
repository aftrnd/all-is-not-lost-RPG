/// @description Clean up resources
// Call our cleanup function to destroy buttons and free memory
cleanup_menu();

// Also clean up the sign text map if it exists
if (ds_exists(global.sign_texts, ds_type_map)) {
    ds_map_destroy(global.sign_texts);
} 