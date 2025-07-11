@tool
extends CharacterBase
class_name Event



@export var event_name:String

## 是否无视碰撞
var ingore_collsion:bool = false
var is_running := false

var need_reload:bool = false

var maps:MapConfig:
	get:return find_parent("Maps")

var handler:EventPageHandler:
	get:return  maps.get_parent().get_node("EventPages") if maps else null

## 自动获取EventPage
var page:EventPage:
	get:return handler.try_get_event_page(ori_cell_pos) if handler else null

var game_items:GameItems:
	get: return GameManager.game_items

var game_variable:GameVariable:
	get:return GameManager.game_variable	

## 信号
signal  event_finish # 事件交互结束


## 引用组件
var animated_sprite:AnimatedSprite2D:
	get(): return get_node("AnimatedSprite2D2")

## 事件NPC的实现：方案1，在Event_Res上增加一个行走图的选择
## 当事件被激活时，使该行走图人物被渲染出来显示。
## 事件的tres要是一个可控制的角色

## 事件NPC的实现：方案2，每个NPC都制作一个独特的预制体，放入到场景内
## 并根据EventConfig联系两个元素

#func _enter_tree() -> void:
	#_show_editor_coord_hint()

func _ready() -> void:
	if Engine.is_editor_hint():return
	game_items.on_bag_item_changed.connect(_refresh_event_state)
	game_variable.variable_changed.connect(_refresh_event_state)
	#_refresh_event_state()
	_load_event_config()

	
## 载入事件config
func _load_event_config():
	if !page : 
		_refresh_event_visible(false)
		return
	if page.content: self.ingore_collsion = !page.content.is_collsion

	# 根据Page来初始化
	# if page.instance_character(self): return

	# 刷新精灵图
	_refresh_sprite_frame(page.frame_index,page)
	# 刷新可视化
	_init_event_visible(page)
	
## 刷新精灵图
func _refresh_sprite_frame(frame_index:int,config:EventPage = null):
	if !config: 
		animated_sprite.animation = "default"
		animated_sprite.frame = frame_index
		return
	## 如果有config
	## 1. 更新动画朝向
	var animation_name = get_dir_animation_name(config.dir)
	if animated_sprite && animated_sprite.sprite_frames && animated_sprite.sprite_frames.has_animation(animation_name) : 
		animated_sprite.animation =  animation_name
	## 2. 更新动画帧数
	animated_sprite.frame = frame_index

func get_dir_animation_name(_dir:int) :
	match _dir:
		0: return "idle_down"
		1: return "idle_left"
		2:return "idle_right"
		3: return "idle_up"
	return null

## 初始化事件可视化
func _init_event_visible(config:EventPage):
	var is_show:bool = config.is_show && self.activable(config)
	_refresh_event_visible(is_show)
	if config.event_visible_changed.is_connected(_refresh_event_visible.bind(config)):
		print("TEST 该信号已被此事件连接")
		config.event_visible_changed.disconnect(_refresh_event_visible.bind(config))
	config.event_visible_changed.connect(_refresh_event_visible.bind(config))
	print("[Event]初始化事件可视化")

## 刷新事件可视化状态
func _refresh_event_visible(is_show:bool):
	# print("TEST 事件（%s,%s)可视化状态为=%s" % [config.pos.x,config.pos.y,is_show] )
	print("[Event]事件的可视度变化了")
	self.visible = is_show

## 连接信号使用，当或许的条件变化时，刷新事件
func _refresh_event_state():
	## 需要等待场景
	if SceneManager.is_ui_visible():
		await  SceneManager.on_map_available
	_load_event_config()


## 交互函数
func interact():
	var _page = handler.try_get_event_page(ori_cell_pos)
	if !_page: return
	if !_page.content || !_page.content.tree:
		printerr("当前事件%s未配置语句" % _page.content.title) 
		event_finish.emit()
		return
	GameManager.set_game_state_buszing()
	await _parse_event_config(_page.content)
	GameManager.set_game_state_normal()

## 解析事件资源
func _parse_event_config(event):
	if is_running: return
	print("开始执行事件")
	## WARNING 事件处理主逻辑
	## 如果需要添加新的节点逻辑，请去对应继承BaseEventNode的子类去重写_execute
	is_running = true
	## 当事件拥有one_shot限制时,将执行过1次写入字典
	if event.one_shot:
		var event_id:String = event.resource_path
		GameManager.game_variable.set_switch(event_id,true)
		self.need_reload = true
		
	await GameManager.trigger_event_res(event,self)
	is_running = false
	print("事件执行结束")
	if need_reload: 
		_load_event_config()
		need_reload = false
	event_finish.emit()

## 判断是否激活
func activable(event:EventPage) -> bool:
	if event and event.content:
		## INFO 增加可视化的条件判断
		return one_shot_valid(event) && _condition_valid(event) && event.enable
	return true

func _find_around_enemy(coord:Vector2i) -> ChasingEnemy:
	print("检查周围是否有敌人")
	for check_dir in DIRS:
		var check_pos = coord + check_dir
		var event:CharacterBase =	get_event(check_pos)
		if event && event is ChasingEnemy && event.chasing_enable:
			return event
	return null

## 是否可交互
func interactable() -> bool:
	## 因为追逐战的关系，添加一项，周围有enemy时，无法交互
	if _find_around_enemy(cell_pos):
		return false
	# var page = handler.try_get_event_page(ori_cell_pos)
	# var event = get_event_config()
	if page and page.content:
		# print("可交互事件状态为：",activable(event))
		return activable(page) && (page.content.trigger_type == Events_Res.TriggerType.Interact交互 or page.content.trigger_type == Events_Res.TriggerType.Touch触碰)
	return false
	
func touchable() -> bool:
	if _find_around_enemy(cell_pos):
		print("有敌人在附近，不能使用")
		return false
	# var event = get_event_config()
	if page and page.content:
		return activable(page) && page.content.trigger_type == Events_Res.TriggerType.Touch触碰
	return false

func can_auto_trigger() -> bool:
	if page and page.content:
		print("该事件坐标（%s,%s）是否可自动运行%s" % [cell_pos.x,cell_pos.y,one_shot_valid(page) && page.content.trigger_type == Events_Res.TriggerType.Auto自动触发])
		#var event_id = event.event_res.resource_path
		### 如果事件仅限执行一次，并且已执行过，则返回false
		return  one_shot_valid(page) &&  page.enable && page.content.trigger_type == Events_Res.TriggerType.Auto自动触发
	return false

## 是否仅限一次
func one_shot_valid(event:EventPage) -> bool:
	var event_id = event.content.resource_path
	if	event.content.one_shot && GameManager.game_variable.get_event_switch(event_id):
		return false
	return true

## 是否满足事件条件
func _condition_valid(event:EventPage) -> bool:
	## 当有事件条件时，返回该条件的判定结果
	return event.get_condition_result()
	#return true

## 准备弃用
func get_event_config(ingore_condition:bool = false) -> EventConfig:
	## 从MapConfig中找到该事件坐标的EventConfig
	var _map_config:MapConfig = GameManager.get_map_config()
	if !_map_config: return null
	var event_config:EventConfig =	_map_config.get_event(ori_cell_pos,ingore_condition)
	print("该事件坐标为:(%s,%s)" % [ori_cell_pos.x,ori_cell_pos.y])
	if !event_config:
		printerr("该事件原坐标%s没有配置Event_RES" % ori_cell_pos )
	return event_config
