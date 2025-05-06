/// @description Draw Title on GUI
// You can write your code in this editor

// Save previous draw settings
var prev_font = draw_get_font();
var prev_halign = draw_get_halign();
var prev_valign = draw_get_valign();
var prev_color = draw_get_color();

// Set draw properties
draw_set_font(title_font);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Get GUI dimensions
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

// Draw background
draw_set_color(c_black);
draw_rectangle(0, 0, gui_width, gui_height, false);

// Draw the title
draw_set_color(title_color);
var title_y = gui_height * 0.3;
draw_text_transformed(gui_width/2, title_y, game_title, 2, 2, 0);

// Button positions
var start_y = gui_height * 0.6;
var quit_y = start_y + button_height + button_spacing;
var settings_y = quit_y + button_height + button_spacing;

// Draw Start Button
var start_color;
if (start_clicked) {
    start_color = color_clicked;
} else if (start_hover) {
    start_color = color_hover;
} else {
    start_color = color_normal;
}

draw_set_color(start_color);
draw_roundrect(gui_width/2 - button_width/2, start_y - button_height/2, 
               gui_width/2 + button_width/2, start_y + button_height/2, false);
draw_set_color(c_black);
draw_roundrect(gui_width/2 - button_width/2, start_y - button_height/2, 
               gui_width/2 + button_width/2, start_y + button_height/2, true);
draw_set_color(text_color);
draw_text(gui_width/2, start_y, "Start Game");

// Draw Quit Button
var quit_color;
if (quit_clicked) {
    quit_color = color_clicked;
} else if (quit_hover) {
    quit_color = color_hover;
} else {
    quit_color = color_normal;
}

draw_set_color(quit_color);
draw_roundrect(gui_width/2 - button_width/2, quit_y - button_height/2, 
               gui_width/2 + button_width/2, quit_y + button_height/2, false);
draw_set_color(c_black);
draw_roundrect(gui_width/2 - button_width/2, quit_y - button_height/2, 
               gui_width/2 + button_width/2, quit_y + button_height/2, true);
draw_set_color(text_color);
draw_text(gui_width/2, quit_y, "Quit Game");

// Draw Settings Button
var settings_color;
if (settings_clicked) {
    settings_color = color_clicked;
} else if (settings_hover) {
    settings_color = color_hover;
} else {
    settings_color = color_normal;
}

draw_set_color(settings_color);
draw_roundrect(gui_width/2 - button_width/2, settings_y - button_height/2, 
               gui_width/2 + button_width/2, settings_y + button_height/2, false);
draw_set_color(c_black);
draw_roundrect(gui_width/2 - button_width/2, settings_y - button_height/2, 
               gui_width/2 + button_width/2, settings_y + button_height/2, true);
draw_set_color(text_color);
draw_text(gui_width/2, settings_y, "Settings");

// Draw Settings Panel if active
if (show_settings) {
    // Settings panel dimensions
    var panel_width = 300;
    var panel_height = 200;
    var panel_x = gui_width/2;
    var panel_y = gui_height/2;
    
    // Draw panel background with slight transparency
    draw_set_alpha(0.9);
    draw_set_color(c_black);
    draw_roundrect(panel_x - panel_width/2, panel_y - panel_height/2,
                   panel_x + panel_width/2, panel_y + panel_height/2, false);
    draw_set_alpha(1.0);
    
    // Draw panel border
    draw_set_color(c_white);
    draw_roundrect(panel_x - panel_width/2, panel_y - panel_height/2,
                   panel_x + panel_width/2, panel_y + panel_height/2, true);
    
    // Draw panel title
    draw_set_color(c_white);
    draw_text(panel_x, panel_y - panel_height/2 + 20, "Settings");
    
    // Draw slider label
    draw_set_halign(fa_center);
    draw_text(panel_x, panel_y - 30, "GUI Scale");
    
    // Draw scale value
    draw_text(panel_x, panel_y + 30, string(gui_scale) + "x");
    
    // Slider dimensions
    var slider_width = 200;
    var slider_height = 20;
    var slider_x = panel_x;
    var slider_y = panel_y;
    
    // Draw slider track
    draw_set_color(c_dkgray);
    draw_roundrect(slider_x - slider_width/2, slider_y - slider_height/4,
                   slider_x + slider_width/2, slider_y + slider_height/4, false);
    
    // Define the discrete scale values (1x, 2x, 3x)
    var scale_values = [1.0, 2.0, 3.0];
    var num_values = array_length(scale_values);
    
    // Draw scale point markers for each discrete value
    draw_set_color(c_gray);
    for (var i = 0; i < num_values; i++) {
        var marker_x = slider_x - slider_width/2 + (slider_width * i / (num_values - 1));
        draw_circle(marker_x, slider_y, 4, false);
        
        // Draw scale labels below markers
        draw_set_color(c_white);
        draw_text(marker_x, slider_y + 15, string(scale_values[i]) + "x");
    }
    
    // Find the current value index
    var current_index = 0;
    for (var i = 0; i < num_values; i++) {
        if (scale_values[i] == gui_scale) {
            current_index = i;
            break;
        }
    }
    
    // Calculate handle position based on current discrete index
    var handle_x = slider_x - slider_width/2 + (slider_width * current_index / (num_values - 1));
    
    // Draw slider handle
    draw_set_color(c_white);
    draw_circle(handle_x, slider_y, slider_height/2, false);
    
    // Draw close button
    var close_size = 20;
    var close_x = panel_x + panel_width/2 - close_size/2 - 10;
    var close_y = panel_y - panel_height/2 + close_size/2 + 10;
    
    draw_set_color(c_red);
    draw_rectangle(close_x - close_size/2, close_y - close_size/2,
                  close_x + close_size/2, close_y + close_size/2, false);
    
    draw_set_color(c_white);
    draw_line(close_x - close_size/3, close_y - close_size/3, 
              close_x + close_size/3, close_y + close_size/3);
    draw_line(close_x + close_size/3, close_y - close_size/3, 
              close_x - close_size/3, close_y + close_size/3);
}

// Draw Copyright Text
draw_set_font(fnt_body);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(10, display_get_gui_height() - 10, "Copyright 2025, Nick Jackson");

// Restore previous draw settings
draw_set_font(prev_font);
draw_set_halign(prev_halign);
draw_set_valign(prev_valign);
draw_set_color(prev_color); 