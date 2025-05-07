/// @description Draw Button on GUI
// You can write your code in this editor

// Only draw in GUI layer if using GUI coordinates
if (use_gui_coords) {
    // Determine button color based on state
    var button_color;
    if (clicked) {
        button_color = color_clicked;
    } else if (hover) {
        button_color = color_hover;
    } else {
        button_color = color_normal;
    }
    
    // Save previous draw settings
    var prev_font = draw_get_font();
    var prev_halign = draw_get_halign();
    var prev_valign = draw_get_valign();
    var prev_color = draw_get_color();
    var prev_alpha = draw_get_alpha();
    
    // Draw button
    draw_set_color(button_color);
    draw_set_alpha(1); // Ensure full opacity for button
    draw_roundrect(gui_x - width/2, gui_y - height/2, gui_x + width/2, gui_y + height/2, false);
    
    // Draw button outline
    draw_set_color(c_black);
    draw_roundrect(gui_x - width/2, gui_y - height/2, gui_x + width/2, gui_y + height/2, true);
    
    // Draw button text only if this is not a menu button (otherwise drawn by controller)
    if (!variable_instance_exists(id, "is_menu_button") || !is_menu_button) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white); // Hardcode white instead of using text_color
        draw_set_alpha(1); // Ensure full opacity for text
        draw_text(gui_x, gui_y, button_text);
    }
    
    // Restore previous draw settings
    draw_set_font(prev_font);
    draw_set_halign(prev_halign);
    draw_set_valign(prev_valign);
    draw_set_color(prev_color);
    draw_set_alpha(prev_alpha);
} 