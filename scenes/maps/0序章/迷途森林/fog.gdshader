shader_type canvas_item;

uniform float time_speed = 0.02;         // 雾移动速度
uniform float scale = 1.5;               // 贴图缩放
uniform float opacity = 0.2;             // 雾气透明度
uniform vec2 direction = vec2(1.0, 0.3); // 雾气流动方向

void fragment() {
    // 动态 UV 偏移
    float t = TIME * time_speed;
    vec2 uv = UV * scale + t * direction;

    // 采样贴图
    vec4 tex = texture(TEXTURE, uv);

    // 使用红通道作为雾密度（可按需改为平均值）
    float fog = tex.r;

    // 输出柔和白雾
    COLOR = vec4(1.0, 1.0, 1.0, fog * opacity);
}