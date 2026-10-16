shader_type canvas_item;
// Solid silhouette of a sprite in its modulate color, e.g. dash afterimages.

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	COLOR = vec4(tint.rgb, tint.a * texture(TEXTURE, UV).a);
}
