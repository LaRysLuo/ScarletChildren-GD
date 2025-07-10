extends Control
class_name ListItemBase

"""
List的抽象基类，请继承该类使用
"""

func _ready():
	if self.get_class() == "ListItemBase":
		push_error("ListItemBase is an abstract class and should not be added to the scene.")
		self.queue_free()

func set_data(_data:Dictionary): assert(false,"必须实现set_data")

func focus(): assert(false,"必须实现set_data")

func unfocus(): assert(false,"必须实现set_data")