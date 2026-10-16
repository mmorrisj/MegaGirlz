shader_type canvas_item;
// Recolors the shared sister sprite into one sister's palette: outfit, hair
// (which the boots share), and the sword slash arc. The outline, skin, and
// any other color pass through unchanged.

uniform vec4 source_outfit : source_color = vec4(0.839, 0.141, 0.067, 1.0);
uniform vec4 source_outfit_shade : source_color = vec4(0.498, 0.024, 0.133, 1.0);
uniform vec4 source_hair : source_color = vec4(1.0, 0.663, 0.224, 1.0);
uniform vec4 source_hair_mid : source_color = vec4(0.753, 0.459, 0.114, 1.0);
uniform vec4 source_hair_dark : source_color = vec4(0.569, 0.345, 0.086, 1.0);
uniform vec4 source_slash : source_color = vec4(0.612, 1.0, 0.992, 1.0);

uniform vec4 target_outfit : source_color = vec4(0.839, 0.141, 0.067, 1.0);
uniform vec4 target_outfit_shade : source_color = vec4(0.498, 0.024, 0.133, 1.0);
uniform vec4 target_hair : source_color = vec4(1.0, 0.663, 0.224, 1.0);
uniform vec4 target_hair_mid : source_color = vec4(0.753, 0.459, 0.114, 1.0);
uniform vec4 target_hair_dark : source_color = vec4(0.569, 0.345, 0.086, 1.0);
uniform vec4 target_slash : source_color = vec4(0.612, 1.0, 0.992, 1.0);

const float TOLERANCE = 0.02;

// Node modulate, kept separately so flashes still tint the swapped colors.
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

vec3 swap(vec3 color, vec4 from, vec4 to) {
	return distance(color, from.rgb) < TOLERANCE ? to.rgb : color;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec3 rgb = color.rgb;
	rgb = swap(rgb, source_outfit, target_outfit);
	rgb = swap(rgb, source_outfit_shade, target_outfit_shade);
	rgb = swap(rgb, source_hair, target_hair);
	rgb = swap(rgb, source_hair_mid, target_hair_mid);
	rgb = swap(rgb, source_hair_dark, target_hair_dark);
	rgb = swap(rgb, source_slash, target_slash);
	COLOR = vec4(rgb, color.a) * modulate;
}
