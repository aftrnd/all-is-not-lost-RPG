/// @description Apply day/night shader to entire screen

// Only proceed if time system is initialized
if (variable_global_exists("time_brightness")) {
    // NOTE: Instead of creating a surface and drawing the application_surface
    // we'll use shader_set and directly apply to all subsequent drawing
    
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
    
    // Draw a full-screen rectangle that will be processed by the shader
    // This preserves camera scaling
    var _vw = view_wport[0];
    var _vh = view_hport[0];
    
    // Save blend mode
    var _blend = gpu_get_blendmode();
    gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
    
    draw_rectangle_color(0, 0, _vw, _vh, 
                         c_white, c_white, c_white, c_white, 
                         false);
    
    // Restore blend mode
    gpu_set_blendmode(_blend);
    
    // Reset shader
    shader_reset();
}