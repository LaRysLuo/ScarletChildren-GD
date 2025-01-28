extends Node2D
class_name SaveManage

## SaveData 存档文件

# 
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			save_data()

## 保存数据
func save_data():
	var save_file = SaveData.new()
	
	## 存储位置
	var current_map = SceneManager.current_map
	var current_pos = GameManager.player.cell_pos
	var game_time = GameManager.game_time.current_time
	## 存储道具
	var data_items = GameManager.data_player.items
	
	save_file.save_player(current_map,current_pos,game_time,data_items)

	ResourceSaver.save(save_file,"user://save.tres")


##  载入数据
func load_data():
	print("正在读取存档")
	var loadedData:SaveData = ResourceLoader.load("user://save.tres") as SaveData
	if loadedData:
		print("读取到存档")
		GameManager.set_screen_color(ColorScreen.BLACK)
		await get_tree().create_timer(0.1).timeout
		
		## 玩家场景与位置
		var current_scene = loadedData.current_map
		var current_pos = loadedData.current_pos
		
		## 游戏时间
		if loadedData.game_time:GameManager.game_time.current_time = loadedData.game_time
		
		## 道具
		if loadedData.items: GameManager.data_player.make_item_by_loaddata(loadedData.items) 
		
		## 将场景移动到
		await  SceneManager.move(current_scene,current_pos,false,true)
		await  GameManager.fadein()
		
