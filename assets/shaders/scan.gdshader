/*
	レーダースキャンシェーダー by あるる（きのもと 結衣）
	Radar Scanning Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type spatial;
render_mode unshaded;

uniform vec3 shift = vec3( 0.0, 0.0, 0.0 );
uniform vec3 time_shift_scale = vec3( 0.0, 0.0, 0.0 );
uniform vec3 scan_power = vec3( 1.8, 0.0, 0.0 );
uniform vec4 scan_color : source_color = vec4( 0.26, 1.0, 0.48, 1.0 );
uniform float scan_line_size = 0.25;
uniform float scan_line_delay : hint_range( 0.0, 1.0 ) = 0.65;

varying vec3 local_vertex;

float get_ratio_scan_line( float p, float speed )
{
	float p2 = mix( -p, p, max( 0.0, sign( speed ) ) );
	return mod( p2, scan_line_size ) / scan_line_size - ( 1.0 - scan_line_delay );
}

void vertex( )
{
	local_vertex = VERTEX + shift - time_shift_scale * TIME;
}

void fragment( )
{
	float v = clamp(
		get_ratio_scan_line( local_vertex.x, time_shift_scale.x ) * scan_power.x
	+	get_ratio_scan_line( local_vertex.y, time_shift_scale.y ) * scan_power.y
	+	get_ratio_scan_line( local_vertex.z, time_shift_scale.z ) * scan_power.z
	,	0.0
	,	1.0
	);

	ALBEDO = scan_color.rgb;
	ALPHA = scan_color.a * v;
}