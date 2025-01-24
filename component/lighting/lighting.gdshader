shader_type canvas_item;

uniform vec4 fog_color:source_color;

void fragment() {
	COLOR.rgb = fog_color.rgb;
	COLOR.a = texture(TEXTURE,UV).r;
	//COLOR = texture(screen_texture,SCREEN_UV);
	////vec2 sprite_uv = FRAGCOORD.xy / vec2(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y);
	////sprite_uv = clamp(sprite_uv, 0.0, 1.0);
	//vec4 mask = texture(protection_mask,SCREEN_UV);
	//if(mask.a == 0.0){
		//COLOR = modulate(COLOR,distance_to_light(FRAGCOORD.xy));
	//}
}
