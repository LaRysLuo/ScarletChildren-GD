extends Node2D

@export var enable:bool = true

## 每秒
func _process(delta: float) -> void:
	if !enable:return
	self.move_local_y(delta*1.3)	
	
	
