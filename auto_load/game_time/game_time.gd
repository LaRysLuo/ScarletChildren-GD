extends Node
class_name GameTime

## 游戏时间
@export var current_time:int

var timer:Timer

signal on_time_changed(current_time:int)



## 初始化
func _ready() -> void:
	timer = Timer.new()
	timer.timeout.connect(timeout)
	add_child(timer)
	timer.start(1)
		
## 超时了
func timeout():
	current_time += 1
	on_time_changed.emit(current_time)
	pass
	
