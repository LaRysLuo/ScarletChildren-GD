@tool
extends Control
class_name TwoDFog

const MASK_WIDTH = 512
const MASK_HEIGHT = 512
const VISION_RADIUS = 16

var img: Image
var tex: ImageTexture
@export_range(0,1) var fog_density:float = 0.3:
	set(val):
		if val != fog_density:
			fog_density = val
			mat.set_shader_parameter('fog_density',fog_density)

#@onready var fog_sprite := $FogSprite

var time := 0.0
var mat:ShaderMaterial:
	get: return self.material as ShaderMaterial
func _ready():
	# 初始化遮罩图（黑色）
	img = Image.create(MASK_WIDTH, MASK_HEIGHT, false, Image.FORMAT_RF)
	img.fill(Color(0.1,0,0))  # 全黑表示未解锁

	tex = ImageTexture.create_from_image(img)
	# 传给 Shader
	
	mat.set_shader_parameter("mask_texture", tex)



func _process(delta):
	time += delta
	mat.set_shader_parameter("time", time)

# func _unhandled_input(event):
# 	if event is InputEventMouseButton and event.pressed:
# 		var click_pos = event.position	
# 		var tex_pos = click_pos / self.texture.get_size() * Vector2(MASK_WIDTH, MASK_HEIGHT)
# 		draw_white_circle(tex_pos, 50)
		
func draw_white_circle(center: Vector2, radius: int):
	for y in range(-radius,radius):
		for x in range(-radius,radius):
			if Vector2(x, y).length() < radius:
				var px = int(clamp(center.x + x, 0, MASK_WIDTH - 1))
				var py = int(clamp(center.y + y, 0, MASK_HEIGHT - 1))
				img.set_pixel(px, py, Color(1, 0, 0))  # 设置为白色（已解锁）
	tex.update(img)
