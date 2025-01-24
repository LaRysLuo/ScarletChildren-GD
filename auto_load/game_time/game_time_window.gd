extends Node
class_name GameTimer

@export var label:Label

func _ready() -> void:
	GameManager.game_time.on_time_changed.connect(refresh)
	refresh(GameManager.game_time.current_time)
## 刷新
func refresh(time):
	var hours = int(time / 3600)
	var minutes = int((time % 3600) / 60)
	var secs = time % 60
	label.text = "%s时%s分%s秒" % [str(hours),str(minutes),str(secs)] 
