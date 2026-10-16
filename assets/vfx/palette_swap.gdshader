shader_type canvas_item;
// Swaps the placeholder sprite's three body colors for a sister's palette,
// Mega Man style. The black outline and any other color pass through.

uniform vec4 source_main : source_color = vec4(1.0, 0.635, 0.0, 1.0);
uniform vec4 source_shade : source_color = vec4(0.890, 0.318, 0.0, 1.0);
uniform vec4 source_accent : source_color = vec4(0.922, 0.827, 0.125, 1.0);
uniform vec4 target_main : source_color = vec4(1.0, 0.635, 0.0, 1.0);
uniform vec4 target_shade : source_color = vec4(0.890, 0.318, 0.0, 1.0);
uniform vec4 target_accent : source_color = vec4(0.922, 0.827, 0.125, 1.0);

const float TOLERANCE = 0.02;

// Node modulate, kept separately so flashes still tint the swapped colors.
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (distance(color.rgb, source_main.rgb) < TOLERANCE) {
		color.rgb = target_main.rgb;
	} else if (distance(color.rgb, source_shade.rgb) < TOLERANCE) {
		color.rgb = target_shade.rgb;
	} else if (distance(color.rgb, source_accent.rgb) < TOLERANCE) {
		color.rgb = target_accent.rgb;
	}
	COLOR = color * modulate;
}
