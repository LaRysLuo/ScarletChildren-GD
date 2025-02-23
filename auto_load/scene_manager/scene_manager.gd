extends Node2D
# class_name SceneManagerV2

## 属性


# var map_scene:Dictionary = {
# 	"lobby1f":"",
# 	"corridor"
# }

var scenes: Dictionary = {
	"scene_main_menu": "res://entities/scenes/ui_scene/main_menu/main_menu.tscn",
	"scene_item_list": "res://entities/scenes/ui_scene/scene_item/neo_item_list.tscn",
	"scene_reading_mode": "res://component/scene_file_read/scene_file_read.tscn",
	"scene_star_fish": "res://scenes/ui_scene/scene_jigsaw/scene_jigsaw.tscn",
	"scene_gameover": "res://scenes/ui_scene/scene_gameover/game_over.tscn",
	"scene_demo01": "res://scenes/ui_scene/scene_test/scene_test.tscn",
}

@export var current_map:Node2D 
@export var scene_list = []
var current_map_path:String 
var current_map_name:String

## 这里需要player
var m_player:PlayerV1

var m_state:int


## 信号
signal reading_mode_close
signal on_map_available
signal on_scene_changed

signal on_player_move_pre #玩家移动前
signal on_player_moved_after #玩家移动后
signal move_finished #玩家移动后
signal on_enter_map_scene #进入地图场景
signal on_enter_ui_scene #进入UI场景

signal on_scene_change_start 
signal on_scene_change_end




## 回调
var effect_fadein: Callable # 带一个参数：时间
var effect_fadeout: Callable # 带一个参数：时间
var time_call:Callable # 获得游戏时间


func _ready() -> void:
	if !get_tree(): return
	current_map = get_tree().current_scene
	_check_current_scene_is_map()


## 信号回调函数
func set_player(player:PlayerV1):
	self.m_player = player
	_init_map_scene()

# func update_game_state(_state:int,_is_buszing:bool):


## 设置特效
func set_effect(fadein:Callable, fadeout:Callable):
	self.effect_fadein = fadein
	self.effect_fadeout = fadeout

## 当场景载入时
func _on_scene_loaded():
	pass


# 跳转到下一个场景
func goto(path, with_fade: bool = true) -> Node:
	var scene
	if path is String:
		var full_path = scenes[path]
		if !full_path:
			printerr("该场景路径没配置")
			return
		scene = load(full_path)
	if path is PackedScene: scene = path
	if with_fade:
		if !effect_fadeout:
			push_error("SceneManager未配置effect_efadeout")
		await effect_fadeout.call(0.1)
		# await  GameManager.fadeout_black(0.2)  # 淡出为黑色

	var loaded_scene = await scene.instantiate()
	get_parent().add_sibling(loaded_scene)
	# SaveManager.add_sibling(loaded_scene)
	get_tree().current_scene = loaded_scene
	await  get_tree().create_timer(0.3).timeout
	if with_fade:
		if !effect_fadein:
			push_error("SceneManager未配置effect_efadein")
		await effect_fadein.call(0.1) ## GameManager.fadein(0.5)
	#print("Player",get_tree().current_scene)
	on_scene_change_end.emit(1)
	on_scene_changed.emit(get_tree().current_scene)
	return get_tree().current_scene

# 带缓存进入下一个场景（用于UI场景切换）
func navigate_to(scene):
	#print("场景管理器准备跳转",scene_name)
	on_scene_change_start.emit()
	var current_scene = get_tree().current_scene
	print("当前场景为",current_scene)
	current_scene.hide()
	scene_list.push_back(current_scene)
	print("当前场景队列中存在场景数：",scene_list)
	var loaded_scene := await goto(scene)
	on_enter_ui_scene.emit(loaded_scene)
	if loaded_scene.has_method("set_manager"):
		loaded_scene.set_manager(self)
	return loaded_scene

## 场景移动：地图间的移动
func move(path: String, coord: Vector2i = Vector2i.ZERO, with_fade: bool = true, move_player: bool = false):
	var spi_list: PackedStringArray = path.get_file().get_basename().split('_')	
	var scene_name = spi_list[-1]	
	## 淡出画面
	if with_fade: pass
	on_player_move_pre.emit(scene_name)
	## 脱离玩家角色
	if m_player:
		m_player.map.remove_child(m_player)
		add_child(m_player)
	await get_tree().create_timer(0.1).timeout
	var err = get_tree().change_scene_to_file(path) # 跳转到新场景
	if err != 0:
		printerr("跳转新场景失败")
		return
	## 等待场景转换完成
	await get_tree().tree_changed
	
	self.current_map_path = path
	
	if m_player:
		var obj_maps: TileMapLayer = get_tree().current_scene.get_node("Maps/Objects")
		remove_child(m_player)
		obj_maps.add_child(m_player)
		m_player.map = obj_maps
	#await get_tree().create_timer(0.2).timeout
	
	## 切换到目标点
	if m_player and move_player: await m_player.set_pos(coord)
	on_player_moved_after.emit(coord)
	await get_tree().create_timer(0.1).timeout
	## 淡入画面
	if with_fade: pass

	## 发送移动结束的信号
	move_finished.emit(coord)
	on_enter_map_scene.emit()
	_init_map_scene()
	# on_scene_changed.emit(get_tree().current_scene)
	_init_map()


# 回退到上一个场景（用于UI场景切换）
func backto(callback = null): 
	# 进入忙碌状态
	on_scene_change_start.emit()
	await  effect_fadeout.call(0.3)
	var lasted = get_tree().current_scene
	get_tree().root.remove_child(lasted)
	if scene_list.size() > 0 :
		var last_scene = scene_list.pop_back()
		print("正在激活场景：",last_scene)
		print("当前场景队列中存在场景数：",scene_list)
		
		get_tree().current_scene = last_scene
		last_scene.show()
		await  effect_fadein.call(0.1)
		
		#await  get_tree().create_timer(0.1).timeout
		if scene_list.is_empty(): 
			var obj_map:TileMapLayer =	m_player.get_parent() as TileMapLayer
			obj_map.enabled = true
			m_player._init_player()
			if callback && callback is Signal: callback.emit()
			reading_mode_close.emit()
			on_map_available.emit()
			on_scene_changed.emit(get_tree().current_scene)
	# 恢复到正常状态0 或者 UI模式1		
	on_scene_change_end.emit(0)
	lasted.queue_free()

#region 内部函数
## 检查当前地图是否为地图场景
func _check_current_scene_is_map():
	var map_config = current_map.get_child(0)
	if map_config.name == "Maps":
		on_enter_map_scene.emit()

## 初始化地图场景
func _init_map_scene():
	_init_map()
	_init_ui()

## 初始化地图场景的地图
func _init_map():
	self.current_map = get_tree().current_scene
	self.current_map_name = current_map.name
	var map_config = current_map.get_child(0)
	if map_config.has_method("_init_map"):
		map_config._init_map()
		

## 初始化地图场景UI
func _init_ui():
	var ui = current_map.get_child(2)
	if ui.has_method("_init_ui"):
		ui._init_ui(m_player)

#endregion
