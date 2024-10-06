#这是一个场景管理器

extends CanvasLayer

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var scene_list = []
@export var scene_file_root = "res://scenes/"

signal move_finished

#场景切换的时候，如果原场景是Main场景，则记录玩家的位置
var playerPos: Vector2

var first_scene = "Main"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


# 跳转到下一个场景
func goto(path,with_fade:bool = true):
	var full_path = scene_file_root + path + ".tscn"
	self.show()
	if with_fade: 
		anim.play("fade_out")
		await  anim.animation_finished
	await  get_tree().change_scene_to_file(full_path)
	

	
	if with_fade:
		anim.play("fade_in")
		await anim.animation_finished
	#print("Player",get_tree().current_scene)
	self.hide()
	
	pass

# 用于主角角色的场景移动
func move(path,event_name,with_fade:bool = true):
	var full_path = scene_file_root + 'maps/' + path + '.tscn'
	if with_fade:
		self.show()
		anim.play("fade_out")
		await  anim.animation_finished
	GameManager.player.map.remove_child(GameManager.player)	# 把玩家脱离出来
	get_tree().change_scene_to_file(full_path) #跳转到新场景
	await  get_tree().tree_changed
	var timer = get_tree().create_timer(0.1)
	await  timer.timeout
	print("当前场景为：",get_tree().current_scene.name)
	
	var event = find_event_by_name(event_name)

	if !event: 
		print_debug("场景移动失败，没有找到目标事件点")
		return
	
	# 设置玩家到该点上
	print_debug("event=",event)
	GameManager.player.move_event_pos(event)
	
	if with_fade:
		anim.play("fade_in")
		await anim.animation_finished
		self.hide()
	
	move_finished.emit()
	

func find_event_by_name(event_id:int) -> Event:
	# 找出对应的event
	var events = get_tree().get_nodes_in_group("events")
	#print("events的数量为",events.size())
	for event:Event in events:
		if !event.map: continue
		#print("event=",event.name)
		#print("event=",event.cell_pos)
		#print("event=",event.map.get_cell_alternative_tile(event.cell_pos))
		if event.map.get_cell_alternative_tile(event.cell_pos) == event_id:
			return event
	return null
# 带缓存进入下一个场景
func navigate_to(path):
	print("场景管理器准备跳转",path)
	var current_scene = get_tree().current_scene
	print("当前场景为",current_scene)
	get_tree().root.remove_child(current_scene)
	scene_list.push_back(current_scene)
	#var node = get_tree().current_scene.find_child("Player", true, false)
	print("当前场景队列中存在场景数：",scene_list)
	#playerPos = node.position
	
	goto(path)


# 回退到上一个场景
func backto():
	get_tree().unload_current_scene()
	if scene_list.size() > 0 :
		var last_scene = scene_list.pop_back()
		print("正在激活场景：",last_scene)
		print("当前场景队列中存在场景数：",scene_list)
		get_tree().root.add_child(last_scene)
		get_tree().current_scene = last_scene
		#get_tree().reload_current_scene()
		#var last_.scene = scene_list[scene_list.size() -1]
		#goto(last_scene)
		#reload_scene(last_scene)
		
func reload_scene(last_scene):
	if last_scene:
		get_tree().cur = last_scene
		get_tree().reload_current_scene()

# 画面淡出
func fadeout():
	self.show()
	anim.play("fade_out")
	await  anim.animation_finished
	#self.hide()
	
func  fadein():
	#self.show
	anim.play("fade_in")
	await  anim.animation_finished	
	self.hide()
