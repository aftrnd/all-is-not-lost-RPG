/// @description Apply day/night shader
// Only apply the shader if time system is initialized
if (variable_global_exists("time_brightness")) {
    // Enable the shader
    shader_set(shDayNightCycle);
    
    // Set the shader uniforms for time of day effects
    var brightness_uniform = shader_get_uniform(shDayNightCycle, "u_Brightness");
    var color_tint_uniform = shader_get_uniform(shDayNightCycle, "u_ColorTint");
    
    // Pass values to the shader
    shader_set_uniform_f(brightness_uniform, global.time_brightness);
    shader_set_uniform_f(color_tint_uniform, 
                         global.time_color_tint[0], 
                         global.time_color_tint[1], 
                         global.time_color_tint[2]);
}