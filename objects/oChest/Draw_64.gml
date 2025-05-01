/// @desc Chest UI
// You can write your code in this editor

if (ui_open) {

    #region Layout Settings
    draw_set_font(fnt_body);

    var chest_x = 64;
    var chest_y = 64;
    var slot_size = 48; // Smaller square slots
    var padding = 6;    // Scaled down padding
    var border = 2;     // Border thickness
    var corner_radius = 8; // Consistent corner radius for all rounded rectangles

    var box_w = (slot_size + padding) * 5 - padding;
    var box_h = (slot_size + padding) * ceil(array_length(inventory) / 5) - padding;

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    #endregion

    #region Draw Background Box
    // Main background with rounded corners
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_roundrect_ext(
        chest_x - padding * 2,
        chest_y - padding * 2 - 40,
        chest_x + box_w + padding * 2,
        chest_y + box_h + padding * 2,
        corner_radius,
        corner_radius,
        false
    );
    
    // Add a subtle border
    draw_set_alpha(0.8);
    draw_set_color(c_dkgray);
    draw_roundrect_ext(
        chest_x - padding * 2,
        chest_y - padding * 2 - 40,
        chest_x + box_w + padding * 2,
        chest_y + box_h + padding * 2,
        corner_radius,
        corner_radius,
        true
    );
    draw_set_alpha(1);
    #endregion

    #region Draw Title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(chest_x + box_w / 2, chest_y - 20, "Chest Inventory");
    #endregion

    #region Draw Chest Inventory Slots
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    for (var i = 0; i < array_length(inventory); i++) {
        var row = i div 5;
        var col = i mod 5;

        var x_pos = chest_x + col * (slot_size + padding);
        var y_pos = chest_y + row * (slot_size + padding);

        var is_hovered = point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_size, y_pos + slot_size);

        // Base slot with semi-transparent background
        draw_set_alpha(0.5);
        draw_set_color(c_black);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, false);
        
        // Slot border
        draw_set_alpha(0.9);
        draw_set_color(is_hovered ? c_white : c_dkgray);
        draw_roundrect_ext(x_pos, y_pos, x_pos + slot_size, y_pos + slot_size, corner_radius/2, corner_radius/2, true);
        
        // Inner border when hovered
        if (is_hovered) {
            draw_set_alpha(0.7);
            draw_set_color(c_white);
            draw_roundrect_ext(x_pos + border, y_pos + border, x_pos + slot_size - border, y_pos + slot_size - border, corner_radius/2, corner_radius/2, true);
        }
        
        draw_set_alpha(1);

        // Draw item name + count
        if (inventory[i] != noone) {
            var item = inventory[i];
            var icon = item.data.icon;
            // Calculate scaling to fit slot
            var spr_w = sprite_get_width(icon);
            var spr_h = sprite_get_height(icon);
            var scale = min((slot_size - padding) / max(spr_w, spr_h), (slot_size - padding) / max(spr_w, spr_h));
            var icon_x = x_pos + (slot_size - spr_w * scale) / 2;
            var icon_y = y_pos + (slot_size - spr_h * scale) / 2;
            draw_sprite_ext(icon, 0, icon_x, icon_y, scale, scale, 0, c_white, 1);

            // Draw count in bottom right with shadow for better readability
            draw_set_color(c_black);
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            draw_text(x_pos + slot_size - padding/2 + 1, y_pos + slot_size - padding/2 + 1, string(item.count));
            
            draw_set_color(c_white);
            draw_text(x_pos + slot_size - padding/2, y_pos + slot_size - padding/2, string(item.count));

            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
    #endregion

    #region Dragged Item
    // Draw the item being dragged over the chest UI
    if (dragging_item != noone && is_struct(dragging_item)) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        var item = dragging_item;
        var icon = item.data.icon;
        // Calculate scaling to fit slot under mouse
        var spr_w = sprite_get_width(icon);
        var spr_h = sprite_get_height(icon);
        var scale = min((slot_size - padding) / max(spr_w, spr_h), (slot_size - padding) / max(spr_w, spr_h));
        var draw_x = mx - (spr_w * scale / 2);
        var draw_y = my - (spr_h * scale / 2);
        draw_sprite_ext(icon, 0, draw_x, draw_y, scale, scale, 0, c_white, 0.8);

        // Draw count with shadow for better visibility
        draw_set_color(c_black);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(draw_x + spr_w * scale + 1, draw_y + spr_h * scale + 1, string(item.count));
        
        draw_set_color(c_white);
        draw_text(draw_x + spr_w * scale, draw_y + spr_h * scale, string(item.count));

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    #endregion
}