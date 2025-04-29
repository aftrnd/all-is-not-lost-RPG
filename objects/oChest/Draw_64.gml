if (ui_open) {
    draw_set_font(fnt_body);

    var chest_x = 64;
    var chest_y = 64;
    var slot_w = 64;
    var slot_h = 32;
    var padding = 4;

    // Background box (optional)
    var box_w = (slot_w + padding) * 5 - padding;
    var box_h = (slot_h + padding) * ceil(array_length(inventory) / 5) - padding;

    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_roundrect(chest_x - padding, chest_y - padding - 32, chest_x + box_w + padding, chest_y + box_h + padding, false);
    draw_set_alpha(1);

    // Draw chest title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(chest_x + box_w/2, chest_y - 20, "Chest Inventory");

    // Draw inventory slots
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    for (var i = 0; i < array_length(inventory); i++) {
        var row = i div 5;
        var col = i mod 5;

        var x_pos = chest_x + col * (slot_w + padding);
        var y_pos = chest_y + row * (slot_h + padding);

        // Draw empty slot
        draw_set_color(c_black);
        var hover = point_in_rectangle(mouse_x, mouse_y, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h);
        draw_set_color(hover ? c_white : c_black);
        draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, false);
        
        // OPTIONAL: highlight fill
        if (hover) {
            draw_set_alpha(0.1);
            draw_set_color(c_white);
            draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, false);
            draw_set_alpha(1);
        }
        
        // Draw item info
        if (inventory[i] != noone) {
            var item = inventory[i];
            draw_set_color(c_white);
            draw_text(x_pos + 4, y_pos + 4, item.name + " x" + string(item.count));
        }
    }
}