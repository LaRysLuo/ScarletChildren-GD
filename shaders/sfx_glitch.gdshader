shader_type canvas_item;

uniform float glitch_enabled : hint_range(0.0, 1.0) = 1.0; // 启动变量 (0-1)
uniform float glitch_strength : hint_range(0.0, 1.0) = 0.3; // 故障强度
uniform float glitch_speed : hint_range(0.0, 1.0) = 0.5; // 故障速度
uniform float flicker_speed : hint_range(0.0, 1.0) = 0.5; // 闪烁速度
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.5; // 闪烁强度


void fragment() {
    vec2 uv = UV; // 使用 Player 的 UV 坐标
    float time = TIME * glitch_speed;

    // 获取 Player 的原始颜色
    vec4 original_color = texture(TEXTURE, uv);
    if (glitch_enabled == 0.0) {
        COLOR = original_color;
    }else{
	 	// 随机偏移 (glitch effect)
        vec2 offset = vec2(
            fract(sin(uv.x * 10.0 + time) * 10.0),
            fract(sin(uv.y * 10.0 + time) * 10.0)
        ) * glitch_strength;

        vec4 color1 = texture(TEXTURE, uv + offset); // 应用偏移后的颜色

        // 颜色分离 (color separation)
        vec2 rgb_offset = vec2(
            fract(sin(uv.x * 5.0 + time) * 5.0),
            fract(sin(uv.y * 5.0 + time) * 5.0)
        ) * glitch_strength;

        vec4 color2 = texture(TEXTURE, uv + rgb_offset); // 颜色分离后的颜色

        vec4 final_color = mix(color1, color2, 0.5); // 混合两种效果

        // 闪烁效果 (flicker effect)
        float flicker = fract(sin(time * 5.0) * 10.0);
        final_color.a *= smoothstep(0.5 - flicker_intensity, 0.5 + flicker_intensity, flicker);
		COLOR = mix(original_color, final_color, glitch_enabled);
	}

}