shader_type spatial;
render_mode blend_mix;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform int diffuse_steps = 5;
uniform int specular_steps = 3;
uniform float specular_intensity = 1.0;
uniform float specular_shininess = 32.0;

const vec3 outline_color= vec3(0.0);
uniform float outline_width = 0.75;
uniform float outline_power = 2.0;
uniform float hatch_density = 0.2;

varying vec3 vertex;

float cel_step(float value, int steps) {
	if (steps <= 1) return value;
	float step_size = 1.0 / float(steps);
	return floor(value / step_size) * step_size;
}

void fragment() {
	ALBEDO = albedo.rgb;
	vertex = VERTEX;
}

void light() {
	float NdotL = dot(NORMAL, LIGHT);
	
	float diffuse_raw = clamp(NdotL, 0.0, 1.0);
	float diffuse_stepped = cel_step(diffuse_raw, diffuse_steps);
	
	if (diffuse_stepped == 0.8){
		DIFFUSE_LIGHT = max(vec3(1.0) * ATTENUATION, DIFFUSE_LIGHT);
	} else {
		vec2 screen_pixel = vertex.xy * VIEWPORT_SIZE / 2.0;
		
		float pixel_hatch_density_x = hatch_density / 1.777;
		float pixel_hatch_density_y = hatch_density;

		float hatch1 = step(0.5, fract(screen_pixel.x * pixel_hatch_density_x));
		float hatch2 = step(0.5, fract(screen_pixel.y * pixel_hatch_density_y));
		float hatch3 = step(0.5, fract((screen_pixel.x + screen_pixel.y) * pixel_hatch_density_x));
		float hatch4 = step(0.5, fract((screen_pixel.x - screen_pixel.y) * pixel_hatch_density_x));
		
		float result = 0.0;

		if (diffuse_stepped <= 0.6)
			result += hatch1;
			if (diffuse_stepped <= 0.4)
				result += hatch2;
				if (diffuse_stepped <= 0.2)
					result += hatch3;

		float hatch = pow(result, 4);
		DIFFUSE_LIGHT = max(mix(outline_color, albedo.rgb, 1.0 - hatch) * ATTENUATION, DIFFUSE_LIGHT);
	}

	if (specular_steps > 0 && NdotL > 0.0 && ATTENUATION > 0.0) {
		vec3 reflected = normalize(reflect(-LIGHT, NORMAL));
		float NdotV = dot(VIEW, reflected);
		
		float specular_raw = pow(clamp(NdotV, 0.0, 1.0), specular_shininess) * specular_intensity;
		float specular_stepped = cel_step(specular_raw, specular_steps);
		
		SPECULAR_LIGHT += specular_stepped * vec3(1.0) * ATTENUATION;
	}
}