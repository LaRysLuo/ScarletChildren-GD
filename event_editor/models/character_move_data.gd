extends BaseEventNode
class_name CharacterMoveData

@export var move_type:int
@export var target_char:Dictionary
@export var step_count:int
@export var speed_factor:float
@export var wait_finished:bool


func  _init(_cmd:int = BaseEventNode.CharacterMove,_pos:Vector2 = Vector2.ZERO,_move_type:int =-1,_target_char:Dictionary = {},_step_count:int = -1,_speed_factor:float = 1,_wait_finished:bool = false) -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.move_type = _move_type
	self.target_char = _target_char
	self.step_count = _step_count
	self.speed_factor = _speed_factor
	self.wait_finished = _wait_finished


## 重写父类虚方法
func _execute(_ent,_agrs):
	## TODO 角色移动在游戏中的实现
	print_rich("- 正在执行《角色行走》")
	# 从当前场景中找到对应角色名的事件	
	var event = _get_event(_ent)
	if !event:
		print_debug("输入了不存在的事件名称")
		return
	#print("event=",event)
	var last_route =  event.find_last_route()
	var target =  event.cell_pos #获得当前位置
	if last_route: target = last_route.target
	var move_dir:Vector2i #移动方向
	var type = _get_type()
	if type is Vector2i:
		move_dir = type
		print("现在是按方向行走 %s - %d",[type,Vector2i.LEFT])
	elif type == 0: 
		move_dir = event.dir
	elif  type == 1: #前后退
		move_dir = event.dir
	else: 
		print_debug("输入的type参数错误")
		return
	print("当前的面朝方向 %s - %d",[type,Vector2i.LEFT])
	## 开始移动
	#GameManager.set_game_state_buszing()
	if step_count > 0:
		## 调整角色的移动速度值
		event.speed_factor = speed_factor
		event.move_speed_factor = speed_factor
		for n in step_count:
			target = move_dir + target
			event.move_to_by_route(MoveRoute.new(move_dir,target))
			if !event.pos_changed.is_connected(_reset_spd_factor.bind(event)):
				event.pos_changed.connect(_reset_spd_factor.bind(event))
			
		if wait_finished: await event.pos_changed # 等待全部移动完成
		
		
	else: event.face_to(move_dir)

func _reset_spd_factor(event:CharacterBase):
	event._reset_speed_factor()
	event.pos_changed.disconnect(_reset_spd_factor.bind(event))
	pass

func _get_type():
	var result = null
	match move_type:
		0: result = 0
		1: result = 1
		2: result = Vector2i.DOWN
		3: result = Vector2i.LEFT
		4: result = Vector2i.RIGHT
		5: result = Vector2i.UP
	return result

## 获得EVENT
func _get_event(ent:Event) -> CharacterBase:
	#var tilemaplayer:TileMapLayer = ent.get_parent()
	if !target_char: return null
	
	var value = target_char['coord']
	var label = target_char['label']
	print("label=",label)
	if typeof(value) == TYPE_STRING: 
		if value == "this": return ent ## 当目标角色是0时，表示事件自己
		if value ==  "player": return GameManager.player as CharacterBase ## 当目标角色是1时，表示玩家
	if typeof(value) == TYPE_VECTOR2I:
		var group = GameManager.get_tree().get_nodes_in_group("events")
		var filters = group.filter(func(item:Event):return item.event_name == label)
		if filters.is_empty():return null
		return filters[0]
	return null
	#var events = get_tree().get_nodes_in_group("events")
	#var result = events.filter(func(event:Event):return event.event_name == name)
	#return result
