//
// Day/Night cycle fragment shader - ENHANCED VERSION
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// Uniform variables to control the time of day effect
uniform float u_Brightness; // 0.0 to 1.0, where 1.0 is full brightness (day)
uniform vec3 u_ColorTint;   // RGB color tint for different times (night=blue, dusk=orange, etc)

void main()
{
    // Get the base texture color
    vec4 baseColor = texture2D(gm_BaseTexture, v_vTexcoord);
    
    // Apply color tinting based on time of day
    vec4 finalColor = baseColor * v_vColour;
    
    // ENHANCED: Apply stronger color mixing for more visible effect
    finalColor.rgb = mix(finalColor.rgb * u_ColorTint, finalColor.rgb, u_Brightness * 0.7);
    
    // ENHANCED: More dramatic brightness adjustment
    finalColor.rgb *= max(u_Brightness, 0.2);
    
    // Output final color
    gl_FragColor = finalColor;
}
