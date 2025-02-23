extends CanvasLayer
class_name ScreenEffect

const WHITE = Color.WHITE
const BLACK = Color.BLACK


@export var color_rect:ColorRect:
	get():return get_node("ColorRect")


signal fade_finished

func _ready() -> void:
	color_rect.modulate.a = 0

func set_color(color:Color,with_fade:bool = false,time:float = 1):
	if !with_fade:
		color_rect.color = color
	else:
		var tween = get_tree().create_tween()
		color_rect.color = color
		# var new_color = color_rect.color
		# color_rect.color = new_color
		tween.tween_property(color_rect,"modulate:a",1,time)
		tween.tween_callback(complete)

## 淡出黑色
func fadeout_black():
	pass

## 淡出白色
func fadeout_white():
	pass

## 淡入
func fadein(time:float = 1):
	var tween = get_tree().create_tween()
	tween.tween_property(color_rect,"modulate:a",0,time)
	tween.tween_callback(complete)

## 结束回调
func complete():
	fade_finished.emit()

