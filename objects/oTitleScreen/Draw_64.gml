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

// Restore previous draw settings
draw_set_font(prev_font);
draw_set_halign(prev_halign);
draw_set_valign(prev_valign);
draw_set_color(prev_color); 