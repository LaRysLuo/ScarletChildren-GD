@tool
extends "res://scripts/game_object.gd"
class_name Event



@export var event_name:String

## 是否无视碰撞
var ingore_collsion:bool = false
var is_running := false

var need_reload:bool = false


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
	GameManager.data_player.on_player_item_changed.connect(_refresh_event_state)
	#_refresh_event_state()
	_load_event_config()

#func _exit_tree() -> void:
	#var config:EventConfig = get_event_config(true)
	#if !config: return 
	#config.event_visible_changed.disconnect(_refresh_event_visible)

## 显示编辑器坐标提示
#func _show_editor_coord_hint():
	
	#if !coord_hint_label: return
	
	#coord_hint_label.hide()
	#if !Engine.is_editor_hint():return
	#coord_hint_label.text = "%s,%s" % [cell_pos.x,cell_pos.y]
	#
	##coord_hint_label.show()
	#print("更新编辑器=",coord_hint_label.visible)
	
## 载入事件config
func _load_event_config():
	var config:EventConfig = get_event_config(true)
	if !config: return 
	if config.event_res: self.ingore_collsion = !config.event_res.is_collsion
	# 刷新精灵图
	_refresh_sprite_frame(config.frame_index,config)
	# 刷新可视化
	_init_event_visible(config)
	

## 刷新精灵图
func _refresh_sprite_frame(frame_index:int,config:EventConfig):
	if !config.need_refresh: return
	config.need_refresh = false
	animated_sprite.frame = frame_index
	pass

## 初始化事件可视化
func _init_event_visible(config:EventConfig):
	var is_show:bool = config.is_show && self.activable(config)
	_refresh_event_visible(is_show,config)
	if config.event_visible_changed.is_connected(_refresh_event_visible.bind(config)):
		print("TEST 该信号已被此事件连接")
		config.event_visible_changed.disconnect(_refresh_event_visible.bind(config))
	config.event_visible_changed.connect(_refresh_event_visible.bind(config))

## 刷新事件可视化状态
func _refresh_event_visible(is_show:bool,config:EventConfig):
	#print("TEST 事件（%s,%s)可视化状态为=%s" % [config.pos.x,config.pos.y,is_show] )
	self.visible = is_show && activable(config)

## 连接信号使用，当或许的条件变化时，刷新事件
func _refresh_event_state(item_name:StringName = "",state:int = 0):
	## 需要等待场景
	var config = get_event_config()
	print("test条件变化了%s,%s" % [self.name,config])
	if config && !activable(config): 
		config.is_show = activable(config)
		print("test条件变化了%s,%s" % [self.name,config.frame_index])
	# 更新 动画帧
		_refresh_sprite_frame(config.frame_index,config)
	#print("test当前透明度",self.visible)

## 交互函数
func interact():
	var event_config = get_event_config()
	if !event_config.event_res || !event_config.event_res.tree:
		printerr("当前事件%s未配置语句" %event_config.event_res.title) 
		event_finish.emit()
		return
	GameManager.set_game_state_buszing()
	await _parse_event_config(event_config.event_res)
	GameManager.set_game_state_normal()

## 解析事件资源
func _parse_event_config(event_res):
	if is_running: return
	print("开始执行事件")
	## WARNING 事件处理主逻辑
	## 如果需要添加新的节点逻辑，请去对应继承BaseEventNode的子类去重写_execute
	is_running = true
	## 当事件拥有one_shot限制时,将执行过1次写入字典
	if event_res.one_shot:
		var event_id:String = event_res.resource_path
		GameManager.data_variable.set_switch(event_id,true)
		self.need_reload = true
		
	await GameManager.trigger_event_res(event_res,self)
	is_running = false
	print("事件执行结束")
	if need_reload: 
		_load_event_config()
		need_reload = false
	event_finish.emit()

## 判断是否激活
func activable(event:EventConfig) -> bool:
	if event and event.event_res:
		## INFO 增加可视化的条件判断
		return one_shot_valid(event) && _condition_valid(event) && visible
	return true

## 是否可交互
func interactable() -> bool:
	var event = get_event_config()
	if event and event.event_res:
		print("可交互事件状态为：",activable(event))
		return activable(event) && event.event_res.trigger_type == Events_Res.TriggerType.Interact交互
	return false
	
func touchable() -> bool:
	var event = get_event_config()
	if event and event.event_res:
		return activable(event) && event.event_res.trigger_type == Events_Res.TriggerType.Touch触碰
	return false

func can_auto_trigger() -> bool:
	var event = get_event_config()
	
	if event and event.event_res:
		print("该事件坐标（%s,%s）是否可自动运行%s",[cell_pos.x,cell_pos.y,one_shot_valid(event) && event.event_res.trigger_type == Events_Res.TriggerType.Auto自动触发])
		#var event_id = event.event_res.resource_path
		### 如果事件仅限执行一次，并且已执行过，则返回false
		return  one_shot_valid(event) && event.event_res.trigger_type == Events_Res.TriggerType.Auto自动触发
	return false

## 是否仅限一次
func one_shot_valid(event:EventConfig) -> bool:
	var event_id = event.event_res.resource_path
	if	event.event_res.one_shot && GameManager.data_variable.get_event_switch(event_id):
		return false
	return true

## 是否满足事件条件
func _condition_valid(event:EventConfig) -> bool:
	## 当有事件条件时，返回该条件的判定结果
	return event.get_condition_result()
	#return true

func get_event_config(ingore_condition:bool = false) -> EventConfig:
	## 从MapConfig中找到该事件坐标的EventConfig
	var map_config:MapConfig = GameManager.get_map_config()
	if !map_config: return null
	var event_config:EventConfig =	map_config.get_event(ori_cell_pos,ingore_condition)
	if !event_config:
		printerr("该事件原坐标%s没有配置Event_RES" % ori_cell_pos )
	return event_config

## WARNING 已弃用，迁移到对应的NODE（DATA）里
## 参数1 显示文本
## 方式 1等待按键/2
func show_message(text:String,wait_type:int,wait_time:float):
	pass

func _get_event_by_name(name:String) -> CharacterBase:
	if name == "this": return self # 如果输入的是this的话，则返回本身
	if name == "player": return GameManager.player as CharacterBase
	var events = get_tree().get_nodes_in_group("events")
	var result = events.filter(func(event:Event):return event.event_name == name)
	return result

# 场景传送： 要传送的场景以及他的场景编号
# 参数1 目标场景的名称
# 参数2 目标事件
# 参数3（可选） 是否要显示淡出淡入
func teleport(args:String):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.is_empty(): 
		print_debug("参数为空，MESSAGE语句必须要传入一个参数")
		return
	if arglist.size() < 2:
		print_debug("参数错误，场景移动方法必须是两个参数")
		return

	# 场景移动前要把该事件保护起来
	self.get_parent().remove_child(self)
	GameManager.add_child(self)

	var scene_name = arglist[0] #目标场景名称
	var target_event_id = int(arglist[1]) #目标事件名称
	var with_fade:bool = true
	if arglist.size() == 3: with_fade = string_to_bool(arglist[2])
	
	#SceneManager.move(scene_name,target_event_id,with_fade) #传送到目标场合
	await SceneManager.move_finished #等待移动结束

func string_to_bool(str:String):
	if str == "true": return true
	elif str == "false": return false
	print_debug("输入的参数{%s}无法转换" %str)

# 画面淡出
func fadeout():
	print("淡出画面")
	await SceneManager.fadeout()

# 画面淡入
func fadein():
	print("淡入画面")
	await  SceneManager.fadein()

# 等待n秒，参数为等待时间
func wait(args:String):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.is_empty(): 
		print_debug("参数为空，MESSAGE语句必须要传入一个参数")
		return
	var time_value = int(arglist[0])	
	var timer = get_tree().create_timer(time_value)
	await timer.timeout

# 角色前进一步,共2个参数，
# 参数1是控制的角色，
# 参数2是前进的步数
# 参数3（可选）是否要等待移动完成
func character_move(args:String,type):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.size() < 2: 
		print_debug("参数为空，MESSAGE语句必须要传至少2个参数")
		return
	# 从当前场景中找到对应角色名的事件	
	var event_name = arglist[0]
	var event = _get_event_by_name(event_name)
	if !event:
		print_debug("输入了不存在的事件名称")
		return
	var count:int = int(arglist[1]) # 将字符串转为整型
	var last_route =  event.find_last_route()
	
	var target =  event.cell_pos #获得当前位置
	if last_route: target = last_route.target
	var move_dir:Vector2i #移动方向
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
	var wait_finish = true
	if arglist.size() ==3 : wait_finish = string_to_bool(arglist[2]) 
	for n in count:
		target = move_dir + target
		event.move_to_by_route(MoveRoute.new(move_dir,target))
	if wait_finish: await event.pos_changed # 等待全部移动完成

# 面朝方向
# 参数1 目标事件
func face_dir(args:String,dir:Vector2i):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.size() < 1: 
		print_debug("参数错误，MESSAGE语句必须要传至少1个参数")
		return
	# 从当前场景中找到对应角色名的事件	
	var event_name = arglist[0]
	var event = _get_event_by_name(event_name)
	if !event:
		print_debug("输入了不存在的事件名称")
		return
	event.face_to(dir)
