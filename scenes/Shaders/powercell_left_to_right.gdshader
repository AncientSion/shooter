shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float glow_strength : hint_range(0.0, 3.0) = 1.5;
uniform float band_width : hint_range(0.01, 0.5) = 0.2;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Moving band
    float x = fract(UV.x - TIME * speed);

    // Soft highlight that travels left -> right
    float highlight = smoothstep(
        band_width,
        0.0,
        abs(x - 0.5)
    );

    vec3 color = tex.rgb;

    // Brighten pixels as the wave passes
    color += highlight * glow_strength * tex.rgb;

    COLOR = vec4(color, tex.a);
}