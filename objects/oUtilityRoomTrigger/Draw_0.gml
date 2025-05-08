/// @description Display destination room name
// Draw the room trigger with the destination room name

// Check if this trigger should be visible (debug mode enabled AND show_triggers is ON)
if (global.debug_mode && global.debug_settings.show_triggers) {
    // Draw the trigger sprite
    draw_self();
    
    // Draw the destination room name
    if (destination_room != -1) {
        draw_set_font(fnt_body);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(c_white);
        
        // Get and format room name
        var room_name = room_get_name(destination_room);
        if (string_pos("rm", room_name) == 1) {
            room_name = string_delete(room_name, 1, 2);
        }
        
        // Draw text above the trigger
        var center_x = x + sprite_width/2;
        var center_y = y - 5;
        draw_text(center_x, center_y, room_name);
        
        // Reset drawing properties
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
} 
else if (global.debug_mode) {
    // Debug mode is ON but triggers are OFF
    // Draw a faint outline to show where triggers are
    draw_set_color(c_red);
    draw_set_alpha(0.3);
    draw_rectangle(x, y, x + sprite_width, y + sprite_height, true);
    draw_set_alpha(1.0);
} 