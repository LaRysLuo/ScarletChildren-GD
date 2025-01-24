extends ColorRect
class_name FilmGrain

@export var shader_material:ShaderMaterial = self.material as ShaderMaterial
@export var time:float

@export var scratch_time = 0.0  # 累计时间
@export var scratch_speed = 0.2  # 控制划痕的变化速度


func _ready() -> void:
	self.show()

func _process(delta: float) -> void:
	scratch_time += delta
	
	if scratch_time > scratch_speed:
		scratch_time = 0
		time += delta
		shader_material.set_shader_parameter("time",time)
	
