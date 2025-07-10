shader_type canvas_item;

uniform float blur_radius : hint_range(1.0, 10.0); // 模糊半径，您可以根据需要调整这个值

void fragment() {
    vec2 pixel = UV / TEXTURE_PIXEL_SIZE;

    // 计算采样的范围，模糊半径控制采样的大小

    int x_min = max(int(pixel.x - blur_radius), 0);
    int x_max = min(int(pixel.x + blur_radius + 1.0), int(1. / TEXTURE_PIXEL_SIZE.x));
    int y_min = max(int(pixel.y - blur_radius), 0);
    int y_max = min(int(pixel.y + blur_radius + 1.0), int(1. / TEXTURE_PIXEL_SIZE.y));

    vec4 total = vec4(0.0, 0.0, 0.0, 0.0);
    int count = 0;

    // 采样周围的像素
    for (int i = x_min; i < x_max; i++) {
        for (int j = y_min; j < y_max; j++) {
            total += texture(TEXTURE, vec2(float(i), float(j)) * TEXTURE_PIXEL_SIZE);
            count++;
        }
    }

    total /= float(count); // 归一化
    COLOR = total;
}
