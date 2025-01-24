extends CanvasLayer
class_name ColorScreen

const WHITE = Color.WHITE
const BLACK = Color.BLACK

@export var color_rect:ColorRect

signal  fade_finished

func set_color(color:Color,with_fade:bool = false,time:float = 1):
	if !with_fade:
		color_rect.color = color
	else:
		var tween = get_tree().create_tween()
		var new_color = Color(color_rect.color,0)
		color_rect.color = new_color
		tween.tween_property(color_rect,"color",color,time)
		tween.tween_callback(complete)

func fadein(time:float = 1):
	var tween = get_tree().create_tween()
	var new_color = Color(color_rect.color,0)
	tween.tween_property(color_rect,"modulate",new_color,time)
	tween.tween_callback(clear)

func complete():
	fade_finished.emit()
	pass

## 清除
func clear():
	fade_finished.emit()
	self.get_parent().remove_child(self)
	self.queue_free()
	pass
