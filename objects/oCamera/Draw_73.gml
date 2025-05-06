/// @description Reset shader
// IMPORTANT: We now handle all day/night shader effects in oGameController
// This event is no longer needed

/// @description Ensure camera positioning
// This event runs right after application surface is drawn

// This Draw_73 event ensures that camera positioning remains consistent
// even when day/night effects are being applied

/// @description Ensure camera is source of truth

// This event runs after shader application in oGameController
// Ensure the camera position hasn't been altered by other processes

// Verify camera position matches what oCamera intended
if (camera_get_view_x(global.camera_view) != global.camera_x ||
    camera_get_view_y(global.camera_view) != global.camera_y ||
    camera_get_view_width(global.camera_view) != global.camera_width ||
    camera_get_view_height(global.camera_view) != global.camera_height) {
    
    // Restore the intended camera position and size
    camera_set_view_pos(global.camera_view, global.camera_x, global.camera_y);
    camera_set_view_size(global.camera_view, global.camera_width, global.camera_height);
}