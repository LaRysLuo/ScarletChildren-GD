extends BaseEventNode
class_name PasswordInputData

@export var password:String

var result:int = 1

var password_input_prefab = preload("res://scenes/ui_scene/scene_password/scene_password.tscn")

var ui_grid:Node:
	get:return SceneManager.get_tree().current_scene.get_node("UI")

func _init(_node_type:int = 0,_pos:Vector2 = Vector2.ZERO,_password="") -> void:
	self.node_type = _node_type
	self.pos = _pos
	self.password = _password

func next(_index:int = 0) -> BaseEventNode:
	return super.next(result)


## 重写执行方法
func _execute(_event,_agrs): 
	
	# ## 获取内联场景
	# ## 把内联场景显示在当前场景的UI里
	var input:ScenePassword = password_input_prefab.instantiate()
	input.set_password(password)
	ui_grid.add_child(input)
	input.on_select_changed.connect(AudioManager.play_cursor_move)
	# input.on_succuss.connect(AudioManager.play_cursor_move)
	input.on_fail.connect(AudioManager.play_buzzle)
	var input_value = await input.on_submit
	ui_grid.remove_child(input)
	input.queue_free()
	if input_value && input_value == password: result = 0
