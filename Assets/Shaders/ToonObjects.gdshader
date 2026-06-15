shader_type spatial;
render_mode blend_mix;

uniform vec4 albedo : source_color = vec4(0.8, 0.8, 0.8, 1.0);
const int steps = 5;

void fragment() {
	ALBEDO = albedo.rgb;
}

void light() {
	float NdotL = max(0.0, dot(NORMAL, LIGHT));
	
	float step_size = 1.0 / float(steps);
	float intensity = floor(NdotL / step_size) * step_size;
	
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, ALBEDO * LIGHT_COLOR * intensity * ATTENUATION);
	SPECULAR_LIGHT = vec3(0.0);
}