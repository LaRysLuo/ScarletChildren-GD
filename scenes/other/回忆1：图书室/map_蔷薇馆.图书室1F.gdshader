shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
// 定义 Uniform 参数
uniform float noise_intensity = 0.3; // 噪点强度
uniform float scratches_intensity = 0.2; // 划痕强度
uniform float time; // 时间，用于动态动画

// 输入的纹理（需要通过 GDScript 动态传递）
uniform sampler2D input_texture;

void fragment() {
    // 屏幕 UV 坐标（0-1 范围）
    vec2 uv = UV;

    // 从输入纹理采样颜色
    //vec4 original_color = texture(input_texture, uv);
	vec4 original_color = texture(screen_texture, SCREEN_UV);

    // 黑白滤镜
    //float gray = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    //vec4 bw_color = vec4(vec3(gray), 1.0);

    // 动态噪点效果
    float noise = fract(sin(dot(uv * time * 50.0, vec2(12.9898, 78.233))) * 43758.5453);
    vec4 noise_effect = vec4(vec3(noise * noise_intensity), 1.0);

    // 动态划痕效果（垂直条纹）
	//float scratches = step(0.98, fract(uv.x * 100.0 + time * 5.0)) * noise * scratches_intensity;
    //vec4 scratches_effect = vec4(vec3(scratches), scratches_intensity);


	float scratch_x = fract(sin(time * 1.0) * 10000.0); // 划痕的横向随机位置

	float time_factor = sin(TIME) * 0.5 + 0.5;  // 使其在 0 到 1 之间波动
    float scratch_width = mix(0, 0.001, time_factor);  // 在 min 和 max 之间插值
    //float scratch_width = 0.001; // 划痕宽度

   // 只让划痕出现在少数随机区域
    float scratch = step(scratch_x - scratch_width, uv.x) * step(uv.x, scratch_x + scratch_width)*noise;
    scratch *= step(0, fract(uv.y * 20.0 + time * 5.0)); // 随时间和垂直方向变化的随机性
    scratch *= scratches_intensity; // 划痕强度控制

    vec4 scratches_effect = vec4(vec3(scratch), scratch);


    // 最终颜色混合
	original_color += noise_effect + scratches_effect;
    //vec4 final_color =   noise_effect + scratches_effect;
    //original_color *= vignette_effect;

    // 输出颜色
    //COLOR = final_color;
	COLOR = clamp(original_color, 0.0, 1.0);
}
