// oSign → Draw Event
draw_self(); // Draw the sign sprite normally

if (show_textbox) {
    draw_set_font(fnt_body);

    var text = text_displayed;
    var text_w = string_width(text);
    var text_h = string_height(text);
    
    // Box dimensions
    var padding = 8;
    var box_w = max(80, text_w + padding * 2);
    var box_h = text_h + padding * 2;
    var box_x = x - box_w / 2;
    var box_y = y - sprite_height - box_h - 8; // 8px above the sign

    // Rounded Box
    draw_set_alpha(0.8); // 80% opacity
    draw_set_color(c_black);
    draw_roundrect(box_x, box_y, box_x + box_w, box_y + box_h, false);
    draw_set_alpha(1); // Reset alpha immediately after

    // Centered Text
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var text_x = box_x + box_w / 2;
    var text_y = box_y + box_h / 2;

    draw_text(text_x, text_y, text);

    // Reset Sign
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}