@tool
extends "res://scripts/game_object.gd"
class_name PlayerV1

var interact_with:Event #可交互对象

# EXPORT
@export var stamina:float = 1:
	set(val):
		stamina = val
		on_stamina_changed.emit(stamina,running_mode != -1)
@export var running_mode:int = 0 # 0 不启动，1 启动,-1 体力耗尽
@export var count_time:float = 0
@export var RECOVER_TIME:float:
	get(): return 1.0
@export var MAX_COUNT:float:
	get(): return 0.1

# ONREADY
@onready var tip: Sprite2D = $Attach/Sprite2D
@onready var cam:Camera2D = $Camera2D
#@onready var attach:CanvasLayer = $Attach

#const FLASH_LIGHT_RES = preload("res://component/flash_light/flash_light.tscn")

## SIGNAL

signal  on_interact_changed(event:Event,state:int) ## 当身前可交互状态变更
signal on_stamina_changed(val:float,is_normal:bool) ## 耐力条变更


## INFO 闲置动画24.10.26添加
## 根据设定得闲置时间，玩家在该时间内为进行移动输入，就会触发闲置动画
const IDLE_TRIGGER_TIME:float = 1 ## 闲置动画触发时间单位秒
var idle_timer:Timer ## 闲置动画计时器

func _ready() -> void:
	super._ready()
	_init_cam_limit()
	start_pos_changed.connect(_has_interact_event.bind(0))
	pos_changed.connect(_has_interact_event.bind(1))
	event_clashed.connect(_has_event_clashed)
	
	GameManager.on_event_trigger_start.connect(_event_trigger_start)
	GameManager.on_event_trigger_end.connect(_event_trigger_end)
	
	restart_idle_timer()
	#show_flash_light()
	
func _init_player() -> void:
	call_deferred("_has_interact_event")
	# 重新载入地图事件
	

func _is_moving() -> bool:
	return get_parent().name == "GameManager"

func _process(delta: float) -> void:
	# 编辑器模式返回
	if Engine.is_editor_hint(): return
	# 不可见时返回
	if !is_visible_in_tree():return
	if _is_moving(): return
	if !map_base: return
	# 跑步处理
	_running_process(delta)
	
	# 输入处理
	dir_input = Vector2i(Input.get_vector("left","right","up","down").round())
	if dir_input.x !=0: dir_input.y=0
	if !GameManager.is_normal_state : dir_input = Vector2i.ZERO #当不是正常游戏状态时，使输入永远为0 
	if dir_input.x !=0 || dir_input.y != 0:
		restart_idle_timer() ## 因为输入了，所以清空限制动画计算时间
	move_to(dir_input)	

## 跑步处理
func _running_process(delta:float):
	if running_mode == 0 && self.stamina == 1: return
	count_time += delta
	if count_time >= MAX_COUNT:
		# 将计时归0
		count_time = 0
		# 消耗模式
		if running_mode == 1:
			# 消耗耐力奔跑
			self.stamina -= 0.05
			if self.stamina <= 0:
				# 进入疲劳模式
				_exhausted()
		# 普通恢复模式
		elif running_mode == 0 && self.stamina < 1.0:
			self.stamina += 0.05
			if self.stamina > 1:
				self.stamina = 1
		# 强制恢复模式
		else:
			self.stamina += 0.1
			if self.stamina >= 1:
				_recover_run()
				self.stamina = 1
				# 恢复奔跑
				

func restart_idle_timer():
	if !idle_timer: 
		idle_timer = Timer.new()
		idle_timer.timeout.connect(play_idle_animation)
		add_child(idle_timer)
	idle_timer.stop()
	idle_timer.wait_time = IDLE_TRIGGER_TIME
	idle_timer.one_shot = true
	idle_timer.start()
	#print("重新开始计时闲置动画")

func play_idle_animation():
	#print("闲置动画触发了")
	if dir == Vector2i.DOWN: playerAnim.play("idle_ext")
	pass


func set_pos(coord:Vector2i):
	_init_cam_limit()
	cam.position_smoothing_enabled = false
	super.set_pos(coord)
	get_tree().create_timer(0.1).timeout.connect(func():
		cam.position_smoothing_enabled = true)
	tip.hide()
	


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

#region 玩家交互
# 交互 - 角色移动后会触发信号，目标方向存在可交互事件
func _has_interact_event(state:int = 1):
	if !GameManager.is_normal_state:return
	var event = _get_event_font() # 判断前方是否有可交互事件
	print("存在可触发的event=",event)
	if event: 
		print("该事件是否可触发", event.interactable())
	if event && event.interactable() && !is_action: 
		_set_interact_with(event,state)
		#print("检查到有X事件")
	else: _set_interact_with(null,state)

# 设置可交互对象
func _set_interact_with(event:Event = null,state:int = 0):
	interact_with = event
	#print("交互时机：",state)
	if state== 0 && interact_with == null && tip.visible:
		on_interact_changed.emit(event,0)
		tip.hide()
		return
	if state==1 && interact_with:
		tip.show()
		on_interact_changed.emit(event,1)

# 获得前方的可交互对象
func _get_event_font() -> Event:
	# 获得所有事件
	var events = get_tree().get_nodes_in_group("events")
	var target_pos = cell_pos + dir
	for event in events:
		if event is Event: #首先判断event是否为Event类型
			# WARNING 这里对于开销来说可能不是很合适，最好能放在别的地方一次性调用，比如场景调用时
			# 暂时停用
			#event._load_event_config()
			if event.cell_pos == target_pos:
				return event
	return null		# 什么都没找到，返回空

var input_triggerd := false

func _input(event: InputEvent) -> void:
	if !GameManager.is_normal_state: return 
	if !is_visible_in_tree():return
	if event.is_action_pressed("submit") && interact_with :	_insteract(interact_with)
	## 打開主菜單
	if event.is_action_pressed("cancel") && !input_triggerd:
		self.input_triggerd = true
		tip.hide()
		var shot:Image = get_viewport().get_texture().get_image()
		var mainMenu:MainMenu =	await	SceneManager.navigate_to("scene_main_menu")
		mainMenu.set_mapshot(ImageTexture.create_from_image(shot))
	## 加速跑
	if event.is_action_pressed("R1") && running_mode == 0: _start_run()
	if event.is_action_released("R1") && running_mode == 1:_end_run()
	
	if event.is_released():
		self.input_triggerd = false

		
var is_action:bool = false

func _insteract(with:Event):
	#is_action = true
	# INFO
	# 这里注释掉的原因是，使用镜子存档时，会同时让镜子上的影像也消失。
	# 但为了顺利让交互提示隐藏，单独使用tip.hide()来隐藏交互提示
	#_set_interact_with(null) # 先设置可交互对象为空，避免重复交互
	# 将隐藏tip移动到_event_trigger_start
	#tip.hide()
	# 停止奔跑
	_end_run()
	with.interact()
	await with.event_finish # 等待交互结束
	#is_action = false
	#判断是否还有交互目标
	# INFO 该部分功能移动到_event_trigger_end
	# 重新检查是否有交互目标

## 加速奔跑
func _start_run():
	running_mode = 1
	self.move_speed_factor = 2

func _exhausted():
	running_mode = -1
	self.move_speed_factor = 0.5
	
func _recover_run():
	running_mode = 0
	self.move_speed_factor = 1

## 停止奔跑
func _end_run():
	running_mode = 0
	self.move_speed_factor = 1

func _event_trigger_start():
	tip.hide()
	
func _event_trigger_end():
	call_deferred("_has_interact_event",1)
	#_has_interact_event(1)

# 判断碰撞的单位触发类型是Touch
func _has_event_clashed(event:Event) -> void:
	print("触发的事件是:",event)
	if !event: return
	# TODO 这里还要做满足条件的event才会被触发
	if event && event.touchable() && !event.ingore_collsion: _insteract(event)
#endregion

## 设置相机跟随
func set_camera_follow(_is_follow:bool):
	pass

## 设置相机放大或者缩小
func set_camera_zoom(zoom_arg:Vector2i = Vector2i.ONE):
	cam.zoom = zoom_arg
