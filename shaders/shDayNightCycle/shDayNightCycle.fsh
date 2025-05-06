//
// Day/Night cycle fragment shader - TRUE NEUTRAL VERSION
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// Uniform variables to control the time of day effect
uniform float u_Brightness; // 0.0 to 1.0, where 1.0 is full brightness (day)
uniform vec3 u_ColorTint;   // RGB color tint for different times (night=blue, dusk=orange, etc)

void main()
{
    // Get the base texture color (original pixel)
    vec4 baseColor = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
    
    // A direct neutral multiplier approach where:
    // - When color tint is [1,1,1], no color change occurs
    // - When brightness is 1.0, no brightness change occurs
    
    // Output pixel = Original pixel × Color tint × Brightness
    gl_FragColor = vec4(
        baseColor.r * u_ColorTint.r * u_Brightness,
        baseColor.g * u_ColorTint.g * u_Brightness,
        baseColor.b * u_ColorTint.b * u_Brightness,
        baseColor.a  // Alpha remains unchanged
    );
}
