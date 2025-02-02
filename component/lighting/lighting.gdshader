shader_type canvas_item;

uniform float glitch_strength : hint_range(0.0, 1.0) = 0.3;
uniform float glitch_speed : hint_range(0.0, 1.0) = 0.5;
uniform float flicker_speed : hint_range(0.0, 1.0) = 0.5;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment(){
	vec2 uv = UV;
    float time = TIME * glitch_speed;

    // 随机偏移
    vec2 offset = vec2(fract(sin(uv.x * 10.0 + time) * 10.0), fract(sin(uv.y * 10.0 + time) * 10.0)) * glitch_strength;
    vec4 color1 = texture(TEXTURE, uv + offset);

    // 颜色分离
    vec2 rgb_offset = vec2(fract(sin(uv.x * 5.0 + time) * 5.0), fract(sin(uv.y * 5.0 + time) * 5.0)) * glitch_strength;
    vec4 color2 = texture(TEXTURE, uv + rgb_offset);

    // 混合颜色
    vec4 final_color = mix(color1, color2, glitch_strength);

    // 闪烁效果
    float flicker = fract(sin(time * 10.0) * 10.0);
    final_color.a *= smoothstep(0.5 - flicker_intensity, 0.5 + flicker_intensity, flicker);

    COLOR = final_color;
}
    