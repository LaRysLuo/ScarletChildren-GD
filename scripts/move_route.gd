extends Object
class_name  MoveRoute

# 移动方向
var dir:Vector2i
# 移动目标 
var target:Vector2i

func _init(dir:Vector2i,target:Vector2i) -> void:
	self.dir = dir
	self.target = target
