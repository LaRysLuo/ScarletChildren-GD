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
var speed_factor:float = 1.0

## 角色主精灵图
@export var sprite : Texture2D:
	set(new):
		if not Engine.is_editor_hint(): return
		sprite = new
		print("图片被更换，刷新一下")
		init_animation()



@export_range(0,10) var h : int = 3
@export_range(0,10) var v : int = 4

## 待机精灵图
@export var idle_ext : Texture2D = null

@onready var map:TileMapLayer = get_parent()
@onready var cell_pos:Vector2i = map.local_to_map(position)
@onready var playerAnim:AnimatedSprite2D = $AnimatedSprite2D2
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


func move_to(dir:Vector2i):
	# 计算出目标点的
	dir_input = dir
	var cell:Vector2i = cell_pos + dir
	var route := MoveRoute.new(dir,cell)
	
	# 存入移动队列
	if  !(tween && tween.is_running()) && cell_pos != cell && cell_list.is_empty(): # 判断目标是否已经移动队列里了
		cell_list.push_back(route) # 把目标点放入移动队列中
		_next()

func move_to_by_route(route:MoveRoute):
	cell_list.push_back(route) # 把目标点放入移动队列中
	if !(tween && tween.is_running()): # 判断目标是否已经移动队列里了
		_next()
	
func set_pos(coord:Vector2i):
	var pos = self.map.map_to_local(coord)
	print("位置=",pos)

	self.position = pos
	self.cell_pos = coord

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
	if !_movable(route): move_target = cell_pos
	else: move_target = route.target
	# 移动到目标点
	cell_pos = move_target
	start_pos_changed.emit()
	if tween: tween.kill()
	tween = create_tween()
	#tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	#var speed_factor = 0.5 ## 表示移动速度为原来的50%
	var time:float = 1 / (MOVE_SPEED * speed_factor)
	#print("移动时间为",time)
	tween.tween_property(self,"position",map.map_to_local(move_target),time)
	tween.finished.connect(_next)
	
# TODO 需要判断这个目标点是否可移动
func _movable(route:MoveRoute) -> bool:
	if !map_base:
		print_debug("没有正确配置通行层")
		return false
	var cell_data = map_base.get_cell_tile_data(route.target)
	if !(cell_data && cell_data.get_custom_data("movable")): # 如果不可移动则返回
		return false
	var event:Event = _get_event(route.target)
	var map_config:MapConfig = get_parent().get_parent()
	var event_config:EventConfig = map_config.get_event(route.target)
	var event_res:Events_Res = null
	if event_config: event_res = event_config.event_res

	# 如果event是碰撞体才返回
	if event && event.visible && !event.ingore_collsion:  
		# 判断事件是否会不会触发
		event_clashed.emit(event)
		return false
	return true
	
# 寻找事件元素
func _get_event(cell:Vector2i):
	var events := get_tree().get_nodes_in_group("events")
	for event:CharacterBase in events:
		if event.cell_pos == cell: return event
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
		return #如果移动队列为空了，跳出移动
	var route = cell_list.pop_front()
	move_to_target(route)
	execute_animation(route.dir)

func face_to(dir:Vector2i):
	self.dir = dir
	execute_animation()

# 初始化动画
func init_animation():
		playerAnim = find_child("AnimatedSprite2D2")
		print("anim",playerAnim)
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
@onready var balloon_sprite: AnimatedSprite2D = $BalloonSprite

## 显示表情
func play_balloon(balloon_name:StringName):
	balloon_sprite.show()
	balloon_sprite.play(balloon_name)
	await  balloon_sprite.animation_finished
	balloon_sprite.animation = "default"
	print("动画结束")
#endregion
