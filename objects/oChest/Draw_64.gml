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
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);

            var center_x = x_pos + slot_w / 2;
            var center_y = y_pos + slot_h / 2;

            draw_text(center_x, center_y, item.name + " x" + string(item.count));
        }
    }
    #endregion

    #region Dragged Item
    // Draw the item being dragged over the chest UI
    if (dragging_item != noone && is_struct(dragging_item)) {
        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);
        draw_set_alpha(0.6);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(mx, my, dragging_item.name + " x" + string(dragging_item.count));
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    #endregion
}