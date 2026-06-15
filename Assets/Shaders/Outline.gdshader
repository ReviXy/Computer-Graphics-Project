shader_type spatial;
render_mode unshaded, cull_front;

uniform float thickness = 0.01;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
	VERTEX += NORMAL * thickness;
}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}