@tool
extends Node2D
class_name CharacterBase

var tween:Tween
@export var dir:Vector2i = Vector2i.DOWN: # 面朝方向
	set(val):
		dir = val
		dir_changed.emit(dir)
var dir_input = Vector2i.ZERO #输入方向
var is_moving:bool = false # 是否正在移动
var cell_list:Array[MoveRoute] #移动的队列
const MOVE_SPEED = 3.0
@export var speed_factor:float = 1.0
@export var move_speed_factor:float = 1.0

## 角色主精灵图
@export var sprite : Texture2D:
	set(new):
		if not Engine.is_editor_hint(): return
		sprite = new
		init_animation()



@export_range(0,10) var h : int = 3
@export_range(0,10) var v : int = 4

## 待机精灵图
@export var idle_ext : Texture2D = null

# 事件层
@onready var map:TileMapLayer = get_parent()
@onready var ori_cell_pos:Vector2i = map.local_to_map(position)
@onready var cell_pos:Vector2i = map.local_to_map(position)
@onready var playerAnim:AnimatedSprite2D = $AnimatedSprite2D2

const DIRS = [ Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP]


# 通行层
var map_base: TileMapLayer:
	get(): return get_node("../../Movable") # 暂时这么使用，应该要放在GamePlay的配置中

# 信号
# 有可交互事件存在
signal start_pos_changed
signal pos_changed
signal event_clashed #碰触到可交互的事件
signal dir_changed #当方向变了的话

func _init() -> void:
	
	pass

func _ready() -> void:
	execute_animation()
	
	pass


## 可被子类继承
func _get_map_config() -> MapConfig:
	return get_parent().get_parent() as MapConfig

func move_to(dir:Vector2i):
	# 计算出目标点的
	dir_input = dir
	var cell:Vector2i = cell_pos + dir
	var route := MoveRoute.new(dir,cell)
	
	# 存入移动队列
	if  !(tween && tween.is_running()) && cell_pos != cell && cell_list.is_empty(): # 判断目标是否已经移动队列里了
		cell_list.push_back(route) # 把目标点放入移动队列中
		_next()

## 移动角色
# 目标点
func move(target_pos:Vector2i):
	var dir:Vector2i = target_pos - cell_pos
	var route = MoveRoute.new(dir,target_pos)
	move_to_by_route(route)

func move_to_by_route(route:MoveRoute):
	cell_list.push_back(route) # 把目标点放入移动队列中
	if !(tween && tween.is_running()): # 判断目标是否已经移动队列里了
		_next()

## 设置位置	
func set_pos(coord:Vector2i):
	self.cell_pos = coord
	print("新的pos是=",coord)
	self.position =  self.map.map_to_local(coord)
	print("新的position是=",position)
	#call_deferred("_pos_changed")



func move_event_pos(event:Node2D):
	var map = event.get_parent()
	map.add_child(self)
	self.map = map
	self.global_position = event.global_position
	self.cell_pos =  self.map.local_to_map(position)
	self.map_base = get_node("../../Movable")
	pass

# 移动到目标点
func  move_to_target(route:MoveRoute):
	is_moving = true
	# 设定面朝方向
	self.dir = route.dir
	var move_target
	# 判断可行性
	if !_movable(route.target): 
		move_target = cell_pos
	else: move_target = route.target
	# 移动到目标点
	cell_pos = move_target
	start_pos_changed.emit()
	if tween: tween.kill()
	tween = create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#var move_speed_factor = 0.5 ## 表示移动速度为原来的50%
	var time:float = 1 / (MOVE_SPEED * move_speed_factor)
	#print("移动时间为",time)
	tween.tween_property(self,"position",map.map_to_local(move_target),time)
	tween.finished.connect(_next)
	
# TODO 需要判断这个目标点是否可移动
func _movable(pos:Vector2i,ingore_event_collsion:bool = false) -> bool:
	if !map_base:
		print_debug("没有正确配置通行层")
		return false
	## 如果是敌人，检查目标点有没有玩家
	if !ingore_event_collsion:
		if is_in_group("enemy") && pos_has_player(pos) :
			print("怎么了，我为什么不能动")
			return false
	var cell_data = map_base.get_cell_tile_data(pos)
	if !(cell_data && cell_data.get_custom_data("movable")): # 如果不可移动则返回
		return false
	var event:Event = get_event(pos)
	if event:
		## 如果移动目标点有敌人，无法移动
		#if event != self && event.is_in_group("enemy"):
			#return false
		## 如果目标点是door
		#if self.is_in_group("player") && event._find_around_enemy(pos) &&  !event.touchable():
			#return false
		var map_config:MapConfig = get_parent().get_parent()
		var event_config:EventConfig = map_config.get_event(pos)
		if !event_config && !event is  Door1: return true		
		var event_res:EventsRes = null
		if event_config: 
			event_res = event_config.event_res
		if !ingore_event_collsion:
			# 如果event是碰撞体才返回
			if event && event.visible && !event.ingore_collsion:  
				# 判断事件是否会不会触发
				event_clashed.emit(event)
				return false
	return true

func pos_has_player(coord:Vector2i) -> bool:
	if GameManager.player.cell_pos == coord:
		return true
	return false	
	
# 寻找事件元素
func get_event(cell:Vector2i) -> CharacterBase:
	var events := get_tree().get_nodes_in_group("events")
	for event:CharacterBase in events:
		if event.cell_pos == cell && event.visible: return event
	return null

func find_last_route() -> MoveRoute:
	if cell_list.is_empty(): return null
	var route =  cell_list[cell_list.size() -1]
	return route

# 继续处理队列中的移动目标
func _next():
	#if tween && tween.is_running(): return
	if cell_list.is_empty() :
		#停止移动
		pos_changed.emit() #发出移动完成的信号
		if dir_input == Vector2i.ZERO:execute_animation()
		is_moving = false
		return #如果移动队列为空了，跳出移动
	var route = cell_list.pop_front()
	move_to_target(route)
	execute_animation(route.dir)

func _reset_speed_factor():
	self.speed_factor = 1
	self.move_speed_factor = 1

func face_to(dir:Vector2i):
	self.dir = dir
	execute_animation()

# 初始化动画
func init_animation():
		playerAnim = find_child("AnimatedSprite2D2")
		playerAnim.sprite_frames = null
		var animation = init_character_animation()
		playerAnim.sprite_frames = animation
		
func init_character_animation() -> SpriteFrames:
	#裁剪Texture
	var sprite_size = Vector2(32,48)
	var anim_list = []
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	for y in range(v):
		var str1
		match  y:
			0: str1 = "move_down"
			1: str1 = "move_left"
			2: str1 = "move_right"
			3: str1 = "move_up"	
		frames.add_animation(str1)
		frames.set_animation_loop(str1,true)	
		var frame0 := get_tex(0,y,sprite_size)
		frames.add_frame(str1,frame0)
		var frame1 := get_tex(1,y,sprite_size)
		
		frames.add_frame(str1,frame1)
		var frame2 := get_tex(2,y,sprite_size)
		frames.add_frame(str1,frame2)
		var frame4 := get_tex(1,y,sprite_size)
		frames.add_frame(str1,frame4)
	for y in range(v):
		var str2
		match  y:
			0: str2 = "idle_down"
			1: str2 = "idle_left"
			2: str2 = "idle_right"
			3: str2 = "idle_up"	
		frames.add_animation(str2)
		frames.set_animation_loop(str2,true)	
		var frame1 := get_tex(1,y,sprite_size)
		frames.add_frame(str2,frame1)
	
	if idle_ext:
		frames.add_animation("idle_ext")
		frames.set_animation_loop("idle_ext",true)
		var frame1 := get_tex(1,0,sprite_size)
		var frame2 := get_tex(2,0,sprite_size)
		var frame3 := get_tex(3,0,sprite_size)
		var frame4 := get_tex(4,0,sprite_size)
		frames.add_frame("idle_ext",frame4)
		frames.add_frame("idle_ext",frame1)
		frames.add_frame("idle_ext",frame2)
		frames.add_frame("idle_ext",frame3)
		frames.add_frame("idle_ext",frame4)
	return frames
	
func get_tex(x:int,y:int,sprite_size:Vector2) -> AtlasTexture:
	var frame = AtlasTexture.new()
	frame.atlas = sprite
	frame.region = Rect2(Vector2(x,y) * sprite_size,sprite_size)
	return frame

# 处理动画状态
func execute_animation(dir:Vector2i = Vector2i.ZERO):
	# 处理面朝方向
	if dir != Vector2i.ZERO || tween && tween.is_running():
		#printerr("播放动画中",speed_factor)
		if dir == Vector2i.DOWN:
			playerAnim.play("move_down",speed_factor)
		if dir == Vector2i.LEFT:
			playerAnim.play("move_left",speed_factor)
		if dir == Vector2i.RIGHT:
			playerAnim.play("move_right",speed_factor)
		if dir == Vector2i.UP:
			playerAnim.play("move_up",speed_factor)
	else:
		match self.dir:
			Vector2i.DOWN:	playerAnim.play("idle_down")
			Vector2i.LEFT: playerAnim.play("idle_left")
			Vector2i.RIGHT:playerAnim.play("idle_right")
			Vector2i.UP: playerAnim.play("idle_up")
#region 显示表情
var balloon_sprite: AnimatedSprite2D:
	get(): return get_node("Attach/BalloonSprite")

## 显示表情
func play_balloon(balloon_name:StringName):
	balloon_sprite.show()
	balloon_sprite.play(balloon_name)
	await  balloon_sprite.animation_finished
	balloon_sprite.animation = "default"
	print("动画结束")
#endregion

#region 特殊效果

var effect_tween:Tween
signal effect_finished

var glitch_shader = preload("res://shaders/sfx_glitch.gdshader")
## 显示故障效果
func show_glitch(time,dur_time:float = 0.3):
	## 判断是否传入正确的参数
	var show_time:float = 0
	if time && typeof(time) == TYPE_FLOAT:
		show_time = time
	print("TX111 : show_time=",show_time)
	var material:ShaderMaterial = playerAnim.material
	material.shader = glitch_shader
	## 显示故障效果
	effect_tween = get_tree().create_tween()
	effect_tween.set_loops(1)
	material.set_shader_parameter("glitch_enabled",0)
	effect_tween.tween_property(material,"shader_parameter/glitch_enabled",1,dur_time)
	## 等待tween结束
	await  effect_tween.finished
	print("准备倒计时=",show_time)
	## 如果有show_time时，等待一段事件后
	if show_time > 0: 
		print("开始倒计时")
		var timer:SceneTreeTimer =get_tree().create_timer(show_time)
		timer.timeout.connect(
			func():
				print("倒计时结束了")
				effect_tween = null
				effect_finished.emit()
		)
	await  effect_finished
	## 隐藏动画效果
	effect_tween = get_tree().create_tween()
	effect_tween.tween_property(material,"shader_parameter/glitch_enabled",0,dur_time)
	await  effect_tween.finished
	material.shader = null

func hide_glitch():
	if effect_tween:
		effect_tween.stop()
		effect_tween = null
	effect_finished.emit()
	
## 切换行走图
func change_texture(tex_path:String):
	var tex = load(tex_path)
	sprite = tex
	init_animation()


#endregion 
