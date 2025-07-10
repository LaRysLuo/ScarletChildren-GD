extends CanvasLayer
class_name SFXVignette

static var instance:SFXVignette


var color_rect:ColorRect:
	get():return get_node("ColorRect")

var material:ShaderMaterial:
	get():return color_rect.material

## 暗角着色器	
var shader = preload("res://shaders/sfx_vignette.gdshader")

func _ready() -> void:
	instance = self
	self.hide()
	
static func get_sfx() -> SFXVignette:
	return instance
	
## 设置颜色
func set_color():
	return self
	
## 应用暗角特效
# range:float/取值0 - 1 ，根据range显示不同程度的
func apply_vignette(_range:float,_time:float = 0):
	# 如果range为0，关闭特效
	if _range == 0:
		clear_effect()
	else:
		# 配置着色器
		material.shader = shader
		
		# 配置参数
		material.set_shader_parameter("vignette_factor",range)
		
		# 显示特效
		if !visible: show()
		
		# 如果time大于0，在等待一段时间后，隐藏该特效
		if _time > 0 :
			await  get_tree().create_timer(_time).timeout
			clear_effect()

## 清除特效
func clear_effect():
	material.shader = null
	self.hide()
