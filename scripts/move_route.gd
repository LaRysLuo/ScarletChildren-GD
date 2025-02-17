extends Object
class_name  MoveRoute

# 移动方向
var dir:Vector2i
# 移动目标 
var target:Vector2i

func _init(_dir:Vector2i,_target:Vector2i) -> void:
	self.dir = _dir
	self.target = _target
