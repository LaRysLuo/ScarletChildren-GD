extends Event
class_name ChasingEnemy



## 追逐战敌人
# INFO 敌人会自动接近玩家位置 -> COMPLETE
# 通过自动寻路算法 计算P点和T点的位置
# 获取路径后，前进一步
# INFO 跨场景追逐
# 追逐战事件启动 
# 会跨场景追逐的场景列表
# 逃出范围的话，关闭

# 启动追逐战
@export var chasing_enable:bool = false
# 追逐场景
@export var chasing_scene_list:Array[String] = []

@export var point_interval: float = 1.0 

@export var speed:float #移动频率

@export var across_delay_time:float = 1 # 跨场景时的延迟出现时间

@export var level:int = 0 # 难度

# 跨场景暂停
@export var across_pause:bool = false

# 获得玩家位置
@onready var player:PlayerV1 = GameManager.game_player.player
@onready var a_star:AStar2D = AStar2D.new()

func _ready() -> void:
	if chasing_enable: update_astar_points() # 这里频繁调用,暂时禁用
	
	#start_chasing()

func _process(_delta: float) -> void:
	#if !GameManager.is_normal_state:return
	if !is_moving && chasing_enable && !across_pause: _chasing()

## 开启追逐战
func start_chasing():
	print("追逐战1开始")
	#await SceneManager.move_finished
	AudioManager.play_monster_laughing()
	## 应用暗角效果
	SFXVignette.get_sfx().apply_vignette(0.5)
	player.pos_changed.connect(_update_path)
	await  GameManager.wait(across_delay_time)
	chasing_enable = true
	if !chasing_scene_list.is_empty(): 
		SceneManager.on_player_move_pre.connect(_across_scene)
		SceneManager.on_player_moved.connect(_across_restart)


#func _exit_tree() -> void:
	#pass

## 完成追逐战
func complete_chasing():
	AudioManager.play_damage4()
	print("抓到你了！！！")
	GameManager.set_game_state_buszing()
	end_chasing()
	
	## 判断当前场景是否为目标场景
	print("当前场景为=",SceneManager.current_map)
	if  SceneManager.get_tree().current_scene.name == "蔷薇馆·中厅":
		SceneManager.navigate_to("scene_demo01")
	else:
		SceneManager.navigate_to("scene_gameover")
	
## 停止追逐战
func end_chasing():
	if !chasing_scene_list.is_empty(): 
		SceneManager.on_player_move_pre.disconnect(_across_scene)
		SceneManager.on_player_moved.disconnect(_across_restart)
	chasing_enable = false
	player.pos_changed.disconnect(_update_path)
	SFXVignette.get_sfx().clear_effect()
	
	

# 寻路路径
var path:Array[Vector2i]
var current_idx:int = 0


## 追逐敌人
func _chasing():
	print("正在处理追逐")
	# 获得自身位置
	var p:Vector2i = self.cell_pos
	# 获得玩家当前位置
	var t:Vector2i = player.cell_pos
	var d = t.distance_to(p)
	if d <= 1:
		_attack(t)
		return
	if !path.is_empty():

		var target = path[current_idx]
		if current_idx < path.size() - 1:
			current_idx += 1
		var event = get_event(target)
		if event:
			across_pause = true
			return
		move(target)

## 抓住
func _attack(target:Vector2i):
	across_pause = true
	 ## 面向方向
	var d = target - self.cell_pos
	face_to(d)
	print("门门门 - 准备攻击",)
	await  GameManager.wait(0.05)
	if player.cell_pos == target && GameManager.is_normal_state:
		complete_chasing()
		return
	across_pause = false

## 连接信号的回调函数
# 当玩家角色移动后，更新寻路路径
# 优化性能
func _update_path():
	print("更新寻路路径")
	current_idx = 0
	path = _find_path(self.cell_pos,player.cell_pos)

## 连接信号的回调函数 - 跨场景
# 要把该角色移动到合适位置
func _across_scene(target_scene:String):
	## 判断目标场景是否在跨场景的范围内
	if target_scene in chasing_scene_list:
		across_pause = true
		self.map.remove_child(self)	# 把该追逐怪脱离出来
		GameManager.add_child(self)
		await GameManager.wait(0.2)
		self.modulate.a = 0
		#self.set_pos(Vector2i.ZERO)
		

	## 如果已在场景外了，结束追逐战
	else:
		end_chasing()
		pass

## 重新开始寻路
# 将玩家到新场景移动后才会触发该回调
# 每次换场景后，怪物会加速，提高怪物的移动速度
func _across_restart(coord:Vector2i):
	if !across_pause:return
	self.level += 1
	self.move_speed_factor = 1.0 + self.level * 0.1
	var obj_map = GameManager.game_player.player.map
	self.reparent(obj_map,true)
	self.map = obj_map
	await GameManager.wait(0.1)
	self.set_pos(coord)
	self.modulate.a = 1

	### 移动到对应位置
	await GameManager.wait(across_delay_time)

	## 播放开关门效果
	var result:Dictionary = _find_around_door(coord)
	if !result: return
	var _dir = result["_dir"]
	var door:Door1 = result["door"]
	# 1. 门打开
	await  door.open_door()
	# 2. 角色走出来
	var check_pos:Vector2i = coord
	for n in 2:
		check_pos += _dir
		move_to_by_route(MoveRoute.new(_dir,check_pos))
	await pos_changed
	# 3. 门关闭
	door.close_door()
	if self.cell_pos == player.cell_pos:
		complete_chasing()
		return
	update_astar_points()
	## 关闭暂停
	across_pause = false
	


var dirs = [
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
]

## 寻找周围的门
func _find_around_door(coord:Vector2i) -> Dictionary:
	for check_dir in dirs:
		var check_pos = coord + check_dir
		var event:CharacterBase =	get_event(check_pos)
		if event && event is Door1:
			return {"door": event, "dir": check_dir}
	return {}

var movable_list
## 更新a星的点
func update_astar_points(width:int = 24,height:int = 19):
	for x in width:
		for y in height:
			var pos_id = a_star.get_available_point_id()
			a_star.add_point(pos_id,Vector2i(x,y))
	movable_list = _get_movable_point()
	for id1 in movable_list:
		var pos1 = a_star.get_point_position(id1)
		for id2 in movable_list:
			if id1 == id2:continue
			var pos2 = a_star.get_point_position(id2)
			var d = pos2.distance_to(pos1)
			if d == 1: a_star.connect_points(id1,id2,false)

func _get_movable_point() -> Array:
	var list = []
	for id in a_star.get_point_ids():
		var pos:Vector2i = a_star.get_point_position(id)
		if _movable(pos,true): list.append(id)
	return list

func _find_path(p:Vector2i,t:Vector2i) -> Array[Vector2i]:
	if !_movable(t,true):
		push_warning("目标点不可达！")
		return []
	#update_astar_points(p,t)
	# var start_id = a_star.get_closest_point(p)
	# var start = a_star.get_point_position(start_id) 
	# var connnections = a_star.get_point_connections(a_star.get_closest_point(p))
	# var end = a_star.get_point_position(a_star.get_closest_point(t))
	var temp_path = a_star.get_point_path(
		a_star.get_closest_point(p),
		a_star.get_closest_point(t)
	)
	var optimized_path:Array[Vector2i]
	for point:Vector2i in temp_path:
		if point != p:
		#if optimized_path[-1].distance_to(point) > point_interval * 0.5:
			optimized_path.append(point)
	return optimized_path
