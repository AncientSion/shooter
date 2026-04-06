shader_type canvas_item;

uniform float shield_strength : hint_range(0.0,1.0);
uniform float time;

void fragment() {
    vec2 uv = UV;

    vec4 tex = texture(TEXTURE, uv);

    vec3 strong_color = vec3(0.2, 0.6, 1.0); // blue
    vec3 weak_color   = vec3(1.0, 0.2, 0.2); // red

    float t = 1.0 - shield_strength;

    vec3 shield_color = mix(strong_color, weak_color, t);
	float edge = smoothstep(0.3, 0.5, length(uv - vec2(0.5)));
	shield_color += edge * 0.5;
	
    float glow = mix(2.0, 1.0, shield_strength);

    COLOR = vec4(shield_color * glow, tex.a);
}