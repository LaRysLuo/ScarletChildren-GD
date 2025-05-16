#这是一个场景管理器

extends CanvasLayer

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var color_rect:ColorRect = $ColorRect
@onready var cg_rect:TextureRect = $CGRect
@export var scene_list = []
const scene_file_root = "res://scenes/"


var expression:Expression = Expression.new()
var is_running:bool = false

## 信号

signal reading_mode_close
signal on_map_available

var tool_scenes:Dictionary = {
	"scene_main_menu":"res://scenes/ui_scene/scene_main/main_menu.tscn",
	"scene_item_list":"res://scenes/ui_scene/scene_item/neo_item_list.tscn",
	"scene_reading_mode":"res://component/scene_file_read/scene_file_read.tscn",
	"scene_star_fish":"res://scenes/ui_scene/scene_jigsaw/scene_jigsaw.tscn",
	"scene_gameover":"res://scenes/ui_scene/scene_gameover/game_over.tscn",
	"scene_demo01":"res://scenes/ui_scene/scene_test/scene_test.tscn",
}


var current_map:String 
var current_map_name:String: 
	get: 
		if get_tree() && get_tree().current_scene:
			return  get_tree().current_scene.name
		return ""



#场景切换的时候，如果原场景是Main场景，则记录玩家的位置
var playerPos: Vector2

var first_scene = "Main"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	cg_rect.hide()
	color_rect.hide()
	
## 开始解谜
# SceneManager.to_starfish()
func to_starfish():
	var star_fish:SceneJigsaw = await navigate_to("scene_star_fish")
	var is_finished = GameManager.game_player.has_item("202c_2_星鱼拼图完成",true)
	if is_finished: star_fish.set_complete()
	else: star_fish.on_succuss.connect(func(): 
		GameManager.game_player.gain_item("202c_2_星鱼拼图完成",false)
	)
	await  star_fish.on_finish
	
func is_ui_visible() -> bool:
	return !scene_list.is_empty()
	

# 跳转到下一个场景
func goto(path,with_fade:bool = true):
	var scene
	if path is String:
		var full_path = tool_scenes[path]
		if !full_path:
			printerr("该场景路径没配置")
			return
		scene = load(full_path)
	if path is PackedScene: scene = path
	self.show()
	if with_fade:	await  GameManager.fadeout_black(0.2) 
	# var root = get_tree().root
	var loaded_scene =  scene.instantiate()
	#root.add_child(loaded_scene)
	SaveManager.add_sibling(loaded_scene)
	get_tree().current_scene = loaded_scene

	#await  get_tree().change_scene_to_file(full_path)

	if with_fade: await  GameManager.fadein(0.5)
	#print("Player",get_tree().current_scene)
	self.hide()
	return get_tree().current_scene


signal on_player_move_pre #玩家移动前
signal on_player_moved 
signal move_finished #玩家移动后


	


## 场景移动：地图间的移动
func move(path:String,coord:Vector2i = Vector2i.ZERO,with_fade:bool = true,move_player:bool = false):
	Larik.print_title("函数名：玩家移动/move")
	
	var spi_list:PackedStringArray  =	path.get_file().get_basename().split('_')
	var scene_name = spi_list[-1]
	Larik.print_content("scene_name:%s" % scene_name)
	
	## 淡出画面
	is_running = true
	if with_fade:
		self.show()
		Larik.print_content("画面淡出")
		anim.play("fade_out")
		await  anim.animation_finished
	on_player_move_pre.emit(scene_name)
	## 脱离玩家角色
	if GameManager.player:
		GameManager.player.map.remove_child(GameManager.player)	
		GameManager.add_child(GameManager.player)
	await get_tree().create_timer(0.1).timeout
	var err =	get_tree().change_scene_to_file(path) #跳转到新场景
	if err != 0:
		printerr("跳转新场景失败")
		return	
	## 等待场景转换完成
	await  get_tree().tree_changed
	self.current_map = path
	self.current_map_name = get_tree().current_scene.name
	if GameManager.player:
		var obj_maps:TileMapLayer = get_tree().current_scene.get_node("Maps/Objects")
		GameManager.remove_child(GameManager.player)
		obj_maps.add_child(GameManager.player)
		GameManager.player.map = obj_maps
	#await get_tree().create_timer(0.2).timeout
	
	## 切换到目标点
	print("角色移动的目标点coord=",coord)
	if GameManager.player and move_player: await  GameManager.player.set_pos(coord)
	on_player_moved.emit(coord)
	await get_tree().create_timer(0.1).timeout
	## 淡入画面
	if with_fade:
		Larik.print_content("画面淡入")
		anim.play("fade_in")
		await anim.animation_finished
		#self.hide()
	
	## 发送移动结束的信号
	is_running = false

	move_finished.emit(coord)
	Larik.print_title("函数名：玩家移动/move 运行结束")
	

## 找出事件
func find_event_by_name(event_id:int) -> Event:
	# 找出对应的event
	var events = get_tree().get_nodes_in_group("events")
	if !events: return
	#print("events的数量为",events.size())
	for event:Event in events:
		if !event.map: continue
		if event.map.get_cell_alternative_tile(event.cell_pos) == event_id:
			return event
	return null




# 带缓存进入下一个场景（用于UI场景切换）
func navigate_to(scene):
	#print("场景管理器准备跳转",scene_name)
	var current_scene = get_tree().current_scene
	print("当前场景为",current_scene)
	#self.add_child(current_scene)
	#current_scene.reparent(self)
	current_scene.hide()
	#get_tree().root.remove_child(current_scene)
	scene_list.push_back(current_scene)
	#var node = get_tree().current_scene.find_child("Player", true, false)
	print("当前场景队列中存在场景数：",scene_list)
	#playerPos = node.position
	return await goto(scene)

# 回退到上一个场景（用于UI场景切换）
func backto(callback = null):
	await  GameManager.fadeout_black(0.1)
	var lasted = get_tree().current_scene
	get_tree().root.remove_child(lasted)
	if scene_list.size() > 0 :
		var last_scene = scene_list.pop_back()
		print("正在激活场景：",last_scene)
		print("当前场景队列中存在场景数：",scene_list)
		#last_scene.reparent(get_tree().root)
		#get_tree().root.add_child(last_scene)
		
		get_tree().current_scene = last_scene
		last_scene.show()
		await  GameManager.fadein(0.1)
		
		#await  get_tree().create_timer(0.1).timeout
		if scene_list.is_empty(): 
			var obj_map:TileMapLayer =	GameManager.player.get_parent() as TileMapLayer
			obj_map.enabled = true
			GameManager.player._init_player()
			if callback && callback is Signal: callback.emit()
			reading_mode_close.emit()
			on_map_available.emit()
			GameManager.clear_screen()
	lasted.queue_free()

# 退出所有UI场景
func backall():
	print("退出全部场景")
	await  GameManager.fadeout_black(0.1)
	# 清除掉旧场景
	var lasted = get_tree().current_scene
	get_tree().root.remove_child(lasted)
	#get_tree().unload_current_scene()
	if scene_list.size() > 0 :
		var last_scene = scene_list[0]
		get_tree().current_scene = last_scene
		last_scene.show()
		GameManager.player._init_player()
		#scene_list.clear()
	await  GameManager.fadein(0.1)
	## 将多余的场景清除掉
	print("当前场景队列中剩余的场景1：",scene_list)
	var other_scenes = scene_list.slice(1)
	for scene:Node in other_scenes:
		scene.queue_free()
	scene_list.clear()
	on_map_available.emit()
	print("当前场景队列中剩余的场景2：",scene_list)

func reload_scene(last_scene):
	if last_scene:
		get_tree().current_scene = last_scene
		get_tree().reload_current_scene()

# 画面淡出
func fadeout():
	self.show()
	anim.play("fade_out")
	await  anim.animation_finished
	#self.hide()
	
func fadein():
	anim.play("fade_in")
	await  anim.animation_finished	
	self.hide()

func show_color():
	color_rect.color = Color.WHITE
	self.show()
	pass


## 显示cg
func show_cg(file_path:String):
	#SceneManager.show_cg("1111")
	var cg_tex = load(file_path) as Texture2D
	cg_rect.texture = cg_tex
	cg_rect.show()
	self.show()

## 隐藏cg
func hide_cg():
	cg_rect.texture = null
	cg_rect.hide()
	self.hide()

## 执行脚本名 支持脚本的等待
func eval(code:String):
	var temp_script = GDScript.new()
	var full_code = "extends Node\n\nsignal code_finished\n\nfunc _ready():\n    " + code + "\n    code_finished.emit()\n    print('xxxxxz')"
	print("已开始运行")
	temp_script.source_code = full_code
	temp_script.reload()
	var instance = temp_script.new()
	await instance._ready()
	#print("已结束运行",full_code)
	#await instance.code_finished
	print("已结束运行")


	

func condition_eval(code:String):
	
	var inputs:Dictionary = {
		"player" =  GameManager.player,
		"interObj" = GameManager.player.interact_with,
	}

	var error = expression.parse(code,inputs.keys())
	if error !=OK:
		printerr("出现错误了")
		return
	var result = expression.execute(inputs.values(),self)
	if expression.has_execute_failed():
		print("执行出错了:",expression.get_error_text())
		return
	if  typeof(result) != TYPE_BOOL:
		print("返回的参数必须是布尔值")
		return
	return result
