extends HBoxContainer
class_name StaminaBar

# 耐力条


@export var progress_bar:ProgressBar:
	get():return get_node("ProgressBar")
	
@export var style:StyleBoxFlat:
	get():return progress_bar.get_theme_stylebox("fill")

var timer:SceneTreeTimer
var is_normal:bool = false

const NORMAL_COLOR:Color = Color("#cb8a37")
const RECOVER_COLOR:Color = Color("#cf3c4d")

func _ready() -> void:
	hide()

## 更新耐力条
func refresh(val:float,is_normal:bool):
	progress_bar.value = val
	if self.is_normal != is_normal:
		self.is_normal = is_normal
		style.bg_color = NORMAL_COLOR if is_normal else RECOVER_COLOR
	if !timer:
		self.show()
		timer =get_tree().create_timer(1)
		timer.timeout.connect(_hide_bar)
	else: timer.time_left = 1

func _hide_bar():
	self.hide()
	timer = null
