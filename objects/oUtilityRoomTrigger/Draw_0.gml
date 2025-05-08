/// @description Display destination room name
// Draw the room trigger with the destination room name

// Draw self first (if visible)
draw_self();

// Only draw text if we have a valid destination room
if (destination_room != -1) {
    // Setup the font and text properties
    draw_set_font(fnt_body);
    
    // Get the room name
    var room_name = room_get_name(destination_room);
    
    // Format the room name for display (remove prefix if exists)
    if (string_pos("rm", room_name) == 1) {
        room_name = string_delete(room_name, 1, 2); // Remove "rm" prefix
    }
    
    // Set text drawing properties
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    
    // Draw the text centered above the trigger, accounting for top-left sprite origin
    // Calculate center of the trigger
    var center_x = x + sprite_width/2;
    var center_y = y - 5; // Position slightly above the top edge
    
    draw_text(center_x, center_y, room_name);
    
    // Reset drawing properties
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
} 