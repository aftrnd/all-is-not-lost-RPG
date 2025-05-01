/// @desc Chest UI
// You can write your code in this editor

if (ui_open) {

    #region Layout Settings
    draw_set_font(fnt_body);

    var chest_x = 64;
    var chest_y = 64;
    var slot_w = 64;
    var slot_h = 32;
    var padding = 4;

    var box_w = (slot_w + padding) * 5 - padding;
    var box_h = (slot_h + padding) * ceil(array_length(inventory) / 5) - padding;

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    #endregion

    #region Draw Background Box
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_roundrect(
        chest_x - padding,
        chest_y - padding - 32,
        chest_x + box_w + padding,
        chest_y + box_h + padding,
        false
    );
    draw_set_alpha(1);
    #endregion

    #region Draw Title
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(chest_x + box_w / 2, chest_y - 15, "Chest Inventory");
    #endregion

    #region Draw Chest Inventory Slots
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    for (var i = 0; i < array_length(inventory); i++) {
        var row = i div 5;
        var col = i mod 5;

        var x_pos = chest_x + col * (slot_w + padding);
        var y_pos = chest_y + row * (slot_h + padding);

        var is_hovered = point_in_rectangle(mx, my, x_pos, y_pos, x_pos + slot_w, y_pos + slot_h);

        // Base slot outline
        draw_set_color(c_black);
        draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, false);

        // Hovered: white fill with black inset outline
        if (is_hovered) {
            draw_set_color(c_white);
            draw_rectangle(x_pos, y_pos, x_pos + slot_w, y_pos + slot_h, true);

            draw_set_color(c_black);
            draw_rectangle(x_pos + 1, y_pos + 1, x_pos + slot_w - 1, y_pos + slot_h - 1, false);
        }

        // Draw item name + count
        if (inventory[i] != noone) {
            var item = inventory[i];
            var icon = item.data.icon;
            // Calculate scaling to fit slot
            var spr_w = sprite_get_width(icon);
            var spr_h = sprite_get_height(icon);
            var scale = min((slot_h - padding * 2) / spr_h, (slot_w - padding * 2) / spr_w);
            var icon_x = x_pos + (slot_w - spr_w * scale) / 2;
            var icon_y = y_pos + (slot_h - spr_h * scale) / 2;
            draw_sprite_ext(icon, 0, icon_x, icon_y, scale, scale, 0, c_white, 1);

            // Draw count in bottom right
            draw_set_color(c_white);
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            draw_text(x_pos + slot_w - padding, y_pos + slot_h - padding, string(item.count));

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
        var scale = min((slot_h - padding * 2) / spr_h, (slot_w - padding * 2) / spr_w);
        var draw_x = mx - (spr_w * scale / 2);
        var draw_y = my - (spr_h * scale / 2);
        draw_sprite_ext(icon, 0, draw_x, draw_y, scale, scale, 0, c_white, 0.6);

        // Draw count at bottom right of icon
        draw_set_color(c_white);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        draw_text(draw_x + spr_w * scale, draw_y + spr_h * scale, string(item.count));

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    #endregion
}