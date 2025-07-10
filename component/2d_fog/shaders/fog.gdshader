shader_type canvas_item;

//uniform sampler2D fog_texture;   // 云雾图（如刚刚生成的贴图）
uniform sampler2D mask_texture;  // 解锁遮罩图（R通道控制解锁）
uniform float time;              // 动态控制时间流动

uniform float fog_density:hint_range(0.0,1.0) = 0.3; //雾的浓度
uniform float fog_uv_distort_strength = 0.02; // 扰动强度
uniform vec2 mask_uv_offset = vec2(0.0);      // 手动修正偏移

uniform float tiling1 = 1.5;
uniform float tiling2 = 2.0;
uniform float speed1 = 0.03;
uniform float speed2 = 0.02;

void fragment() {
    vec2 uv = UV;

    // 动态流动的雾图UV偏移
    //vec2 uv1 = uv * tiling1 + vec2(time * speed1, 0.0);
    //vec2 uv2 = uv * tiling2 - vec2(0.0, time * speed2);

	vec2 uv1 = fract(UV * tiling1 + vec2(time * speed1, 0.0));
	vec2 uv2 = fract(UV * tiling2 - vec2(0.0, time * speed2));

    // 采样云雾贴图两次并混合
    vec4 fog1 = texture(TEXTURE, uv1);
    vec4 fog2 = texture(TEXTURE, uv2);
    vec4 fog = mix(fog1, fog2, 0.5);
	// 将雾图去色作为扰动噪声（R通道即可）
    float noise = dot(fog.rgb, vec3(0.333)); // 等效于 grayscale

	// 扰动 mask 的 UV 坐标
	vec2 mask_uv = uv + (noise - 0.5) * fog_uv_distort_strength + mask_uv_offset;

    // 遮罩图（解锁区域 = 1，未解锁 = 0）
    float unlock = texture(mask_texture, mask_uv).r;

    // 淡出迷雾：解锁区域 → alpha 减少
    float alpha = (1.0 - unlock ) * fog.a * fog_density;


    COLOR = vec4(fog.rgb, alpha);
}
