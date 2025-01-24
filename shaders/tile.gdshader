shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 1.0; // 控制透明度的 uniform 参数

void fragment() {
    COLOR.a *= opacity *0.5; // 根据 opacity 参数调整颜色的 alpha 值
}