extends BaseEventNode
class_name TransportData

## 场景坐标
@export var target_map_path:String

## 是否移动角色
@export var is_move_character:bool

## 目标点坐标
@export var target_coord:Vector2i

## 是否淡入淡出
@export var is_fade:bool

func  _init(_cmd:int = BaseEventNode.Transport,_pos:Vector2 = Vector2.ZERO,_target_map_path = null,_is_character_move:bool = false,_target_coord = null,_is_fade:bool=true) -> void:
	print("_target_map_path",_target_map_path)
	if !_target_map_path || !_target_map_path is String:
		printerr("_target_map_path类型错误")
		return
	self.node_type = _cmd
	self.pos = _pos
	self.target_map_path = _target_map_path
	self.is_move_character = _is_character_move
	if _is_character_move:
		self.target_coord = _target_coord
	self.is_fade = _is_fade

func _execute(_ent:Event,_args):
	## TODO 场景移动的逻辑
	# 场景移动前要把触发事件保护起来
	if _ent:
		_ent.hide()
		_ent.get_parent().remove_child(_ent)
		GameManager.add_child(_ent)
	SceneManager.move(target_map_path,target_coord,is_fade,is_move_character) #传送到目标场合
	await SceneManager.move_finished #等待移动结束
	## 将ent移出
	if _ent && _ent is Event:
		_ent.event_finish.connect(func():
			GameManager.remove_child(_ent)
			_ent.show()
		)
	
	
