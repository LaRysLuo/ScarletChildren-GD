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

func  _init(cmd:int = BaseEventNode.Transport,pos:Vector2 = Vector2.ZERO,target_map_path = null,is_character_move:bool = false,target_coord = null,is_fade:bool=true) -> void:
	print("target_map_path",target_map_path)
	if !target_map_path || !target_map_path is String:
		printerr("target_map_path类型错误")
		return
	self.node_type = cmd
	self.pos = pos
	self.target_map_path = target_map_path
	self.is_move_character = is_character_move
	if is_character_move:
		self.target_coord = target_coord
	self.is_fade = is_fade

func _execute(ent:Event,args):
	## TODO 场景移动的逻辑
	# 场景移动前要把触发事件保护起来
	ent.hide()
	ent.get_parent().remove_child(ent)
	GameManager.add_child(ent)
	GameManager.scene_manager.move(target_map_path,target_coord,is_fade,is_move_character)
	# SceneManager.move(target_map_path,target_coord,is_fade,is_move_character) #传送到目标场合
	await GameManager.scene_manager.move_finished #等待移动结束
	## 将ent移出
	if ent is Event:
		ent.event_finish.connect(func():
			GameManager.remove_child(ent)
			ent.show()
		)
	
	
