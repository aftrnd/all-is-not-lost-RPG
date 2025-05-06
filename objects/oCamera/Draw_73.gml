/// @description Reset shader
// Only reset if we previously set a shader
if (variable_global_exists("time_brightness")) {
    shader_reset();
}