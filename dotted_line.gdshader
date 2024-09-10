shader_type canvas_item;

uniform float dotFrequency;

void fragment() {
    float pattern = step(0.5, fract(UV.y * dotFrequency));
    vec4 color = vec4(1,1,1, pattern);
	COLOR = color;
}