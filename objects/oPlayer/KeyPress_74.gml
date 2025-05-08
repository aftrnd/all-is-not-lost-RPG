/// @description Developer Menu
// You can write your code in this editor

// Toggle the debug menu visibility
drawDebugMenu = !drawDebugMenu;

// Make sure global debug mode matches our debug menu
// Only toggle global debug if it doesn't match our menu state
if (global.debug_mode != drawDebugMenu) {
    debug_toggle();
}
