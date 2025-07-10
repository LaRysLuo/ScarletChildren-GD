extends MapConfig
class_name Maps



var chunk_scene:PackedScene = preload("res://scenes/maps/0序章/迷途森林/prefabs/chunk.tscn")
var chunk_size:int = 800
var chunk_dict:Dictionary
var chunk_grid:Node2D:
	get: return get_node("Chunks")

var need_extend_map:bool = false # 需要扩展地图
var first_extended_map:bool = false # 是否已经扩展过地图
var last_chunk_pos:Vector2i
var last_chunk_pos_queue:Array[Vector2i]

var current_chunk_pos:
	get:
		var chunk_pos = get_chunk_coords(GameManager.player.position)
		if last_chunk_pos != chunk_pos && !last_chunk_pos_queue.has(chunk_pos):
			last_chunk_pos_queue.push_back(last_chunk_pos)
			if last_chunk_pos_queue.size() >=2 : last_chunk_pos_queue.pop_front()
			chunk_changed.emit(last_chunk_pos,chunk_pos,chunk_size)
			last_chunk_pos = chunk_pos # 表示现在移动到了新场景
			need_extend_map = true
		return chunk_pos

signal chunk_changed(from:Vector2i,to:Vector2i,chunk_size:int)
signal chunk_init(chunk:MapChunk,target_pos:Vector2i,chunk_size:int)

func _ready() -> void:
	if !GameManager.player: await GameManager.on_player_loaded
	
	GameManager.player.pos_changed.connect(func():
		print("当前chunk坐标",get_chunk_coords(GameManager.player.position))
	)
	init_origin_chunk()
	super._ready()
	

func _process(_delta: float) -> void:
	if !need_extend_map: return
	map_extend()


## 初始化默认的场景块
func init_origin_chunk():
	var chunk0:MapChunk = chunk_grid.get_child(0)
	chunk_dict[Vector2i(0,0)] = chunk0
	# var chunk1:MapChunk = chunk_grid.get_child(1)
	# chunk_dict[Vector2i(0,-1)] = chunk1
	# init_camera_limit()

## 重写获取通行层
func _get_movable() -> TileMapLayer:
	# print("chunk_pos",chunk_pos)
	var chunk:MapChunk = chunk_dict.get(current_chunk_pos,null)
	return chunk.get_movable()


## 初始化摄像头位置
func init_camera_limit():
	var min_chunk_x = current_chunk_pos.x - 1
	var max_chunk_x = current_chunk_pos.x + 1
	var min_chunk_y = current_chunk_pos.y - 1
	var max_chunk_y = current_chunk_pos.y + 1

	var left:int   = min_chunk_x * chunk_size
	var right:int  = (max_chunk_x + 1) * chunk_size
	var top:int    = min_chunk_y * chunk_size
	var bottom:int = (max_chunk_y + 1) * chunk_size

	GameManager.player.set_cam_limit(left,right,top,bottom)

## 在以玩家为中心的chunk图块周围生成4个图块,并将过远的图块缓存掉
func map_extend():
	need_extend_map = false
	if !first_extended_map: map_extend_first()
	else: 
		if current_chunk_pos == Vector2i.ZERO: return
		map_extend_normal()
		init_camera_limit()
	pass

func map_extend_normal():
	clear_farest_chunk() # 清除距离远的地图块
	for coord in [Vector2i.LEFT,Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i(1,1),Vector2i(1,-1),Vector2i(-1,1),Vector2i(-1,-1)]:
		var target_pos  = current_chunk_pos + coord
		if chunk_dict.has(target_pos): continue
		spawn_chunk(target_pos)

## 第一次扩展地图
func map_extend_first():
	first_extended_map = true
	for coord in [Vector2i.UP]:
		spawn_chunk(current_chunk_pos + coord)
	   

func spawn_chunk(target_pos:Vector2i):
	# var target_pos = current_chunk_pos + coord
	var chunk = chunk_scene.instantiate()
	chunk.position = target_pos * chunk_size
	chunk_dict[target_pos] = chunk
	chunk_grid.add_child(chunk)
	chunk_init.emit(chunk,target_pos,chunk_size) ## 新的地图初始化了

## 清除距离远的chunk
func clear_farest_chunk():
	var chunks_to_remove = []
	for chunk_key in chunk_dict.keys():
		var delta = current_chunk_pos - chunk_key  # Vector2i
		var distance = abs(delta.x) + abs(delta.y)
		if distance >= 2:
			chunks_to_remove.append(chunk_key)
	
	for key in chunks_to_remove:
		if chunk_dict.has(key):
			chunk_dict[key].queue_free()
			chunk_dict.erase(key)



func get_chunk_coords(pos: Vector2):
	return Vector2i(floor(pos.x / chunk_size), floor(pos.y / chunk_size))
