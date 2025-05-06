/// @description Apply day/night shader to entire screen

// Only proceed if time system is initialized
if (variable_global_exists("time_brightness")) {
    // For daytime (brightness exactly 1.0), skip shader effect entirely
    if (global.time_brightness == 1.0 && 
        global.time_color_tint[0] == 1.0 && 
        global.time_color_tint[1] == 1.0 && 
        global.time_color_tint[2] == 1.0) {
        // Skip shader during pure daytime - render original colors
        // Free surface if it exists to save memory
        if (surface_exists(global.daynightSurface)) {
            surface_free(global.daynightSurface);
            global.daynightSurface = -1;
        }
        return;
    }
    
    // Create a surface if needed
    if (!surface_exists(global.daynightSurface)) {
        global.daynightSurface = surface_create(view_wport[0], view_hport[0]);
    }
    
    // Copy the application surface to our day/night surface
    surface_set_target(global.daynightSurface);
    draw_clear_alpha(c_black, 0); // Clear with transparency
    draw_surface(application_surface, 0, 0);
    surface_reset_target();
    
    // Set shader
    shader_set(shDayNightCycle);
    
    // Set shader uniforms
    var brightness_uniform = shader_get_uniform(shDayNightCycle, "u_Brightness");
    var color_tint_uniform = shader_get_uniform(shDayNightCycle, "u_ColorTint");
    
    // Pass values to shader
    shader_set_uniform_f(brightness_uniform, global.time_brightness);
    shader_set_uniform_f(color_tint_uniform, 
                         global.time_color_tint[0], 
                         global.time_color_tint[1], 
                         global.time_color_tint[2]);
    
    // Draw our surface with the shader applied
    draw_surface(global.daynightSurface, 0, 0);
    
    // Reset shader
    shader_reset();
}