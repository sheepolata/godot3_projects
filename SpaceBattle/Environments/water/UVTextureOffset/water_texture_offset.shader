shader_type canvas_item;

uniform float tile_factor = 10.0;
uniform float aspect_ratio = 0.5;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(1.0, 1.0);

uniform vec2 waves_size = vec2(0.1, 0.1);

uniform float time_scale = 0.05;

void fragment() {
	vec2 offset_texture_uvs = UV * uv_offset_scale;
	offset_texture_uvs += TIME * time_scale;
	
	vec2 texture_based_offset = texture(uv_offset_texture, offset_texture_uvs).rg;
	texture_based_offset = texture_based_offset * 2.0 - 1.0;
	
	vec2 adjusted_uv = UV * tile_factor;
	adjusted_uv.y *= aspect_ratio;
	
	COLOR = texture(TEXTURE, adjusted_uv + texture_based_offset * waves_size);
	//COLOR = vec4(texture_based_offset, vec2(0.0, 1.0));
}