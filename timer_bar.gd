extends Control
class_name TimerBar

@export var color1:Color
@export var color2:Color

@onready var progress:TextureProgressBar = $VBoxContainer/ProgressBar

@onready var count_down_label:Label = $VBoxContainer/HBoxContainer/Label
@onready var timer:Timer = $Timer



func _ready() -> void:
	start_count()
	pass
	
## 开始倒计时
func start_count():
	progress.value = progress.max_value
	progress.tint_progress = color1
	count_down_label.label_settings.font_color = color1
	count_down()
	timer.timeout.connect(count_down)
	timer.start()
	var tween1 = get_tree().create_tween()
	tween1.tween_property(progress,"tint_progress",color2,progress.max_value)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(count_down_label.label_settings,"font_color",color2,progress.max_value)
	pass
func count_down():
	count_down_label.text = "读题时间还剩%s秒" % floor(progress.value)
	var tween = get_tree().create_tween()
	tween.tween_property(progress,"value",progress.value-1,1)
	
	pass
