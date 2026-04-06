shader_type canvas_item;

uniform float shield_strength : hint_range(0.0,1.0);
uniform float energy_speed = 1.5;
uniform float energy_scale = 8.0;

void fragment() {
    vec2 uv = UV;
    vec4 tex = texture(TEXTURE, uv);

    // --- Color shift (faster toward red) ---
    vec3 strong_color = vec3(0.2, 0.6, 1.0);
    vec3 weak_color   = vec3(1.0, 0.2, 0.2);

    float adjusted_strength = pow(shield_strength, 1.15);
    vec3 shield_color = mix(weak_color, strong_color, adjusted_strength);

    // --- Energy animation ---
    float energy = sin((uv.x + TIME * energy_speed) * energy_scale) * 0.5 + 0.5;

    // --- Flicker (stronger when weak) ---
    float flicker_strength = pow(1.0 - shield_strength, 3.0);

    float flicker = sin(TIME * 40.0) * 0.5 +
                    sin(TIME * 73.0) * 0.3 +
                    sin(TIME * 120.0) * 0.2;
//
    flicker = step(0.6, fract(flicker));
    float instability = flicker * flicker_strength * 1.;
	//instability = 0.0;

    // Optional: push color toward red during flicker
    vec3 flicker_color = mix(shield_color, weak_color, flicker * flicker_strength);

    // --- Final color ---
    vec3 final_color = flicker_color * (1.0 + energy * 0.4 + instability);

    COLOR = vec4(final_color, tex.a * COLOR.a);
}