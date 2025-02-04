shader_type canvas_item;

uniform float animation_range : hint_range(0.0, 1.0) = 0.0; //动画效果
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap; // 屏幕纹理
uniform float vignette_factor : hint_range(0.0, 1.0) = 0.5; // 暗角系数
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.5; // 暗角强度
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.8; // 暗角范围
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0,1.0); // 暗角颜色
uniform float animation_speed :hint_range(0.0, 1.0) = 1; //速度

void fragment() {
	// 获取屏幕坐标 (0.0 到 1.0)
    vec2 screen_uv = UV;
	// 获取原始颜色
    vec4 origin_color = texture(SCREEN_TEXTURE, screen_uv);
	if(vignette_factor == 0.0){
		vec4 final = vec4(vignette_color.rgb,0);
		COLOR = final;
	}
	else{

	    // 计算从屏幕中心到当前像素的距离
	    vec2 center = vec2(0.5, 0.5); // 屏幕中心
	    float distance_from_center = distance(screen_uv, center);
		
		float time = abs(sin(TIME * animation_speed * 3.14159 * 2.0));
		
	    // 计算暗角效果
	    float vignette = smoothstep(vignette_radius, vignette_radius + 0.1, distance_from_center);
	    vignette = vignette * vignette_strength * vignette_factor  * (animation_range * time);

		vec4 final_color = mix(origin_color, vec4(vignette_color.rgb,vignette),0.9);

	    // 应用暗角效果
	    COLOR =  final_color;
	}
	

}