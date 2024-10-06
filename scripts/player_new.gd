@tool
extends "res://scripts/game_object.gd"
class_name Player_v1

var interact_with:Event #可交互对象

# EXPORT

# ONREADY
@onready var tip: Sprite2D = $Sprite2D
@onready var cam:Camera2D = $Camera2D



func _ready() -> void:
	super._ready()
	_init_cam_limit()
	pos_changed.connect(_has_interact_event)
	event_clashed.connect(_has_event_clashed)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	dir_input = Vector2i(Input.get_vector("left","right","up","down").round())
	if dir_input.x !=0: dir_input.y=0
	if !GameManager.is_normal_state : dir_input = Vector2i.ZERO #当不是正常游戏状态时，使输入永远为0 
	move_to(dir_input)	

# 重写父类方法
func move_event_pos(event:Node2D):
	super.move_event_pos(event)
	tip.hide()
	_init_cam_limit()

# 配置摄像机设置
func _init_cam_limit():
	var map_config = map.get_parent() as MapConfig
	if !map_config:
		print_debug("配置摄像机限制失败，未设置map_config")
		return
	cam.limit_left = map_config.left_limit
	cam.limit_right = map_config.right_limit
	cam.limit_top = map_config.top_limit
	cam.limit_bottom = map_config.bottom_limit

# 交互 - 角色移动后会触发信号，目标方向存在可交互事件
func _has_interact_event():
	var event = _get_event_font() # 判断前方是否有可交互事件
	print("可互动的event",event)
	if event && event.trigger_type == Event.TriggerType.None无: event = null
	_set_interact_with(event)

# 设置可交互对象
func _set_interact_with(event:Event = null):
	interact_with = event
	if interact_with == null:
		tip.hide()
	else:
		tip.show()

# 获得前方的可交互对象
func _get_event_font() -> Event:
	# 获得所有事件
	var events = get_tree().get_nodes_in_group("events") 
	var target_pos = cell_pos + dir
	for event in events:
		if event is Event: #首先判断event是否为Event类型
			if event.cell_pos == target_pos:
				return event
	return null		# 什么都没找到，返回空

func _input(event: InputEvent) -> void:
	if !GameManager.is_normal_state: return 
	if !interact_with: return
	if event.is_action_pressed("submit"):
		#var with = interact_with
		_insteract(interact_with)
		
		
func _insteract(with:Event):
	_set_interact_with(null) # 先设置可交互对象为空，避免重复交互
	with.interact()
	await with.event_finish # 等待交互结束
	#判断是否还有交互目标
	_has_interact_event()

# 判断碰撞的单位触发类型是Touch
func _has_event_clashed(event:Event) -> void:
	#print("触发的事件是:",event)
	if !event: return
	# TODO 这里还要做满足条件的event才会被触发
	if event.trigger_type == Event.TriggerType.Touch触碰:
		_insteract(event)
