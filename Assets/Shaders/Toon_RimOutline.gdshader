shader_type spatial;
render_mode blend_mix;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform int diffuse_steps = 3;
uniform int specular_steps = 3;
uniform float specular_intensity = 1.0;
uniform float specular_shininess = 32.0;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width = 0.6;
uniform float outline_power = 2.0;

float cel_step(float value, int steps) {
	if (steps <= 1) return value;
	float step_size = 1.0 / float(steps);
	return floor(value / step_size) * step_size;
}

void fragment() {
	float NdotV = dot(NORMAL, VIEW);
	float fresnel = pow(1.0 - abs(NdotV), outline_power);
	float rim_intensity = step(1.0 - outline_width, fresnel);
	
	ALBEDO = mix(albedo.rgb, outline_color.rgb, rim_intensity);
}

void light() {
	float NdotL = dot(NORMAL, LIGHT);
	
	float diffuse_raw = clamp(NdotL, 0.0, 1.0);
	float diffuse_stepped = cel_step(diffuse_raw, diffuse_steps);
	
	DIFFUSE_LIGHT = max(diffuse_stepped * ATTENUATION * ALBEDO * LIGHT_COLOR, DIFFUSE_LIGHT);
	
	if (specular_steps > 0 && NdotL > 0.0 && ATTENUATION > 0.0) {
		vec3 reflected = normalize(reflect(-LIGHT, NORMAL));
		float NdotV = dot(VIEW, reflected);
		
		float specular_raw = pow(clamp(NdotV, 0.0, 1.0), specular_shininess) * specular_intensity;
		float specular_stepped = cel_step(specular_raw, specular_steps);
		
		SPECULAR_LIGHT = max(specular_stepped * vec3(1.0) * ATTENUATION, SPECULAR_LIGHT);
	}
}