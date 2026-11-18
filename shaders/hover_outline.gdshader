shader_type canvas_item;
// Outline putih saat hover. Aktifkan lewat uniform outline_enabled (lihat HoverOutline).
// Garis digambar di area transparan sekitar sprite, jadi tekstur perlu margin transparan >= outline_width.

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 24.0, 0.5) = 6.0;
uniform float outline_enabled : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (outline_enabled > 0.5) {
		vec2 step = TEXTURE_PIXEL_SIZE * outline_width;
		float edge = 0.0;
		for (int i = 0; i < 16; i++) {
			float angle = float(i) * TAU / 16.0;
			vec2 uv = UV + vec2(cos(angle), sin(angle)) * step;
			float inside = (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0) ? 1.0 : 0.0;
			edge = max(edge, texture(TEXTURE, uv).a * inside);
		}
		vec4 line = vec4(outline_color.rgb, edge * outline_color.a);
		COLOR = mix(line, base, base.a);
	} else {
		COLOR = base;
	}
}
