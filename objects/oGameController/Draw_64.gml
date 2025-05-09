// BUILD VERSION
draw_set_font(fnt_body);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_colour(c_white); 
draw_text(global.window_width -10, global.window_height - 10, "0.4.0 Pre-Alpha");

// Get mouse position for tracking
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var mx_room = mouse_x;
var my_room = mouse_y;

// Get GUI dimensions for positioning
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

// Draw in-game menu if either the flag is true OR we have some alpha
if (menu_open || menu_alpha > 0) {
    // Save previous draw settings
    var prev_alpha = draw_get_alpha();
    
    // Draw darkened background
    draw_set_alpha(menu_alpha * 0.8); // 80% of the menu alpha
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_width, gui_height, false);
    
    // Reset alpha for menu elements
    draw_set_alpha(menu_alpha);
    
    // Calculate consistent menu title position
    var menu_title_y = gui_height * 0.25;
    
    // Draw menu title using pixel-perfect approach
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    // Draw MENU as a single text element
    draw_text(gui_width/2, menu_title_y, "MENU");
    
    // Update button visibility based on menu alpha
    var i;
    for (i = 0; i < ds_list_size(menu_buttons); i++) {
        var btn = menu_buttons[|i];
        if (instance_exists(btn)) {
            // Only make buttons visible when menu is sufficiently visible
            btn.visible = (menu_alpha >= 0.5);
            // We don't need to draw buttons here as they draw themselves
        }
    }
    
    // Draw button text directly in this layer to ensure it's on top
    if (menu_alpha >= 0.5) {
        // Set drawing properties
        draw_set_alpha(1); // Full opacity
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white); // Force white color
        
        // Draw resume button text
        if (instance_exists(resume_button)) {
            draw_text(resume_button.gui_x, resume_button.gui_y, resume_button.button_text);
        }
        
        // Draw quit button text
        if (instance_exists(quit_button)) {
            draw_text(quit_button.gui_x, quit_button.gui_y, quit_button.button_text);
        }
    }
    
    // Restore previous draw settings
    draw_set_alpha(prev_alpha);
}