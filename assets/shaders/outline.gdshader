shader_type spatial;

uniform vec4 lineColor : source_color = vec4(1.0);
uniform float lineThickness : hint_range(0.0, 10.0) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 size = VIEWPORT_SIZE * lineThickness;
	
	float outline = texture(SCREEN_TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(SCREEN_TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);
	
	vec4 color = texture(SCREEN_TEXTURE, UV);
	if (lineThickness == 0.0) {
		ALBEDO = ALBEDO * color;
	} else {
		COLOR = mix(color * opacity, lineColor, outline - color.a);
	}
}
