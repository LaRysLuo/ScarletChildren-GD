extends CanvasLayer

var data_player:DataPlayer:
	get():return GameManager.data_player

var itemList:Array[Item]:
	get(): return data_player.get_shown_items

@onready var catagory_label = $VBoxContainer/HBoxContainer/Label
@onready var helpBox = $VBoxContainer/HBoxContainer/Label2
@onready var grid:GridContainer = $VBoxContainer/VBoxContainer/GridContainer
@onready var prefab:PackedScene = ResourceLoader.load("res://scenes/l_button.tscn")
@onready var craft_mode_hint:Control = $VBoxContainer/VBoxContainer/CraftModeHint


## 组合列表
var recipes:Dictionary = {
	## 在没有相纸的相机上组装永久相纸
	## 失去永久相纸
	## 失去没有相纸的相机
	## 获得装有永久相纸的相机
	["02i_0_老式拍立得","03i_0_永久相纸"]: func(_craft_list): 
		data_player.remove_item(_craft_list[1])
		data_player.update_item(_craft_list[0],"02i_1_老式拍立得"),
	## 在没有相纸的相机上组装一次性相纸
	## 失去没有相纸的相机
	## 失去一次性相纸
	## 获得装有一次性相纸的相机
	["02i_0_老式拍立得","04i_一次性相纸"]:func(_craft_list):
		data_player.remove_item(_craft_list[1])
		data_player.update_item(_craft_list[0],"02i_2_老式拍立得"),
	## 在有永久相纸的相机上组装一次性相纸
	## 	失去一次性相纸
	## 失去装有永久相纸的相机
	## 获得永久相纸
	## 获得装有一次性相纸的相机
	["02i_1_老式拍立得","04i_一次性相纸"]:func(_craft_list):
		data_player.remove_item(_craft_list[1])
		data_player.update_item(_craft_list[0],"02i_2_老式拍立得")
		data_player.gain_item_array(["03i_0_永久相纸"]),
	["02i_2_老式拍立得","03i_0_永久相纸"]:func(_craft_list):
		data_player.remove_item(_craft_list[1])
		data_player.update_item(_craft_list[0],"02i_1_老式拍立得")
		data_player.gain_item_array(["04i_一次性相纸"]),

}


var index:int = 0 :
	set(new):
		last = index
		index = new
		
var current_item:Item:
	get():  return itemList[index] if !itemList.is_empty() else null
var last:int = -1
var btnlist = [] #按钮列表
var craft_mode:bool = false ## 组合选择模式
var craft_list:Array[Item] ## 组合列表

func _ready() -> void:
	craft_mode_hint.hide()
	call_deferred("refresh")
	pass # Replace with function body.

## 刷新道具栏
func refresh():
	print("刷新道具栏")
	## 清除grid下的元素
	var children = grid.get_children()
	if !children.is_empty():
		#var current_selected:LButton = grid.get_child(index)
		#current_selected.unfocus()
		for itemx in children:
			grid.remove_child(itemx)
			itemx.queue_free()
	for item:Item in itemList:
		var btn = prefab.instantiate()
		grid.add_child(btn)
		btn.name = item.item_name
		btn.text = item.item_name
		
		btn.connect("lb_focus_entered",func():
			catagory_label.text = "线索" if item.item_catagory == 2 else "道具"
			helpBox.text = item.item_desc
		)
		btn.connect("lb_select_changed",on_select)
		btn.connect("lb_submit",_use_item)
	
		## 刷新按钮的状态
		if btn is LButton:
			btn.disabled = !usable(item)
			#print("显示道具%s的可用状态为%s" % [item.item_name,usable(item)])
	var item_btn:LButton = grid.get_child(index)
	if item_btn: item_btn.focus(true)
	print("item:",item_btn)

# 玩家按下选择后
func on_select(event:int):
	var list :Array[Node] = grid.get_children()
	var num:int = grid.columns
	print("num=",num)
	match  event:
		0: 
			#向下移动光标
			if num > 0 && index + num < list.size() : index += num
		1:
			# 向左移动
			if index > 0: index-=1
		2:
			#往右向横行移动 0%2  < 2
			if index < list.size() -1: index+=1
		3:
			#向上移动	光标
			if num > 0 && index - num >= 0: index -=num		
	update_btn()

func update_btn():
	var list :Array[Node] = grid.get_children()
	if last > -1 : 
		var last_btn = list[last] as LButton
		last_btn.unfocus()
	var btn = list[index] as LButton
	btn.focus()

## 是否可使用
func usable(item:Item)->bool:
	if !craft_list.is_empty() && !craft_list.has(item):return true
	if craft_list.has(item):return false
	#print("可用的:%s,craft_list为%s" % [item.item_name,item.use_event])
	if !data_player.get_use_callback(item): return false
	return true

func _input(event: InputEvent) -> void:
	if !visible:return
	if event.is_action_pressed("cancel"): 
		get_window().set_input_as_handled()
		if !craft_list.is_empty():
			_cancel_craft_item()
			return
		SceneManager.backto()
	## 按下确定键,
	#if event.is_action_pressed("submit"):
		#get_window().set_input_as_handled()
		#print("正在使用道具")
		#_use_item()
		#return
	## 组合
	if event.is_action_pressed("craft"):
		get_window().set_input_as_handled()
		_start_craft_item()
		
## 使用道具
func _use_item():
	if !usable(current_item):
		AudioManager.play_se("blip03")
		print("使用道具失败，不满足使用条件")
		return
	## 1. 使用道具
	if craft_list.is_empty():
		print("使用道具%s了" % itemList[index].item_name)
		var event_res = data_player.get_use_callback(current_item)
		# var current = current_item
		if event_res:
			## 1.关掉道具窗口
			await  SceneManager.backall()
			## 2.触发物品效果
			#use_event.call(current)
			GameManager.trigger_event_res(event_res)
	else:
	## 2. 组合选择道具
		## 2.1 将当前选择的物品加入组合列表
		if !craft_list.has(current_item):
			craft_list.append(current_item)
			_end_craft_item()
		else: 
			printerr("不能组合同一个物品")
			_cancel_craft_item()
		## 2.2 组合效果

## 组合道具
func _start_craft_item():
	if !craft_list.is_empty():return
	craft_list.append(current_item)
	print("开始组合模式")
	craft_mode_hint.show()
	refresh()
	

func _cancel_craft_item():
	craft_list.clear()
	craft_mode_hint.hide()
	refresh()
	pass

## 完成组合道具
func _end_craft_item():
	if craft_list.is_empty(): return
	var key:Array[String]
	for item in craft_list:
		key.append(item.item_id)
	
	if recipes.has(key):
		## 移出对应元素
		AudioManager.play_se("button03a")
		recipes.get(key).call(craft_list)
		print("物品组合了")
	else:
		AudioManager.play_se("blip03")
		print("没有事情发生")
	_cancel_craft_item()
