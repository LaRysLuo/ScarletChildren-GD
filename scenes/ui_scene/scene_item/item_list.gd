extends PanelContainer
class_name ItemListEx

## 组件资源
var lbtn_res:PackedScene = preload("res://scenes/l_button.tscn")

## 自身引用
var grid:Control:
	get(): return get_node("VBoxContainer/MarginContainer/VBoxContainer/ItemGrid")
	
var craft_mode_hint:Control:
	get(): return get_node("VBoxContainer/MarginContainer/VBoxContainer/CraftModeHint")

## 属性

# 组合模式
var craft_mode:bool = false ## 组合选择模式
var craft_list:Array[Item] ## 组合列表

var is_active:bool = false
var last_index:int = -1
var select_index:int = 0:
	set(val):
		last_index = select_index
		select_index = val

var game_items:GameItems:
	get():return GameManager.game_items
var item_list:Array[Item]

var current_item:Item:
	get(): return item_list[select_index]


## 信号
signal on_cancel
# signal on_use_item(event_res:Events_Res)
signal on_submit(item:Item)
signal on_changed(item_id:int)


## 获得列表
func get_list():
	return grid.get_children()
	
func _ready() -> void:
	craft_mode_hint.hide()

func set_info(list:Array[Item]):
	self.item_list = list
	refresh()

## 刷新组件
func refresh(ingore_clear_data:bool = false):
	clear_item_list(ingore_clear_data)
	#self.data_player = data_player
	## 根据数据刷新整个页面
	for item in self.item_list:
		var lbtn = lbtn_res.instantiate()
		if lbtn is LButton:
			lbtn.text = item.item_name
			lbtn.lb_select_changed.connect(on_select)
			lbtn.lb_submit.connect(_use_item)
			## 刷新按钮的状态
			if lbtn is LButton: lbtn.disabled = !usable(item)
			grid.add_child(lbtn)
	

## 清空列表
func clear_item_list(ingore_clear_data):
	for lbtn:LButton in	 grid.get_children():
		lbtn.lb_select_changed.disconnect(on_select)
		lbtn.lb_submit.disconnect(_use_item)
		grid.remove_child(lbtn)
		lbtn.queue_free()
	if ingore_clear_data:return	
	self.select_index = 0
	self.last_index = -1


## 是否可使用
func usable(item:Item):
	if !craft_list.is_empty() && !craft_list.has(item):return true
	if craft_list.has(item):return false
	if !game_items.usable(item): return false
	return true

# 玩家按下选择后
func on_select(event:int):
	if !is_active: return
	var list :Array[Node] = grid.get_children()
	var num:int = grid.columns
	print("num=",num)
	match  event:
		0: 
			#向下移动光标
			if num > 0 && select_index + num < list.size() : select_index += num
		1:
			# 向左移动
			if select_index > 0: select_index-=1
		2:
			#往右向横行移动 0%2  < 2
			if select_index < list.size() -1: select_index+=1
		3:
			#向上移动	光标
			if num > 0 && select_index - num >= 0: select_index -=num		
	update_btn()

## 更新按钮
func update_btn():
	unfocus_all()
	focus(select_index)


func _input(event: InputEvent) -> void:
	if !is_active: return
	if event.is_action_pressed("cancel"): 
		get_window().set_input_as_handled()
		if !craft_list.is_empty():
			_cancel_craft_item()
			return
		on_cancel.emit()
	## 组合
	if event.is_action_pressed("craft"):
		get_window().set_input_as_handled()
		_start_craft_item()

## 激活组件
func active():
	is_active = true
	focus(select_index)
	
## 冻结组件
func deactive():
	is_active = false
	on_changed.emit(-1)
	unfocus_all()

## 聚焦
func focus(index:int,ingore_se:bool = false):
	var item =  get_list()[index]
	if item && item is LButton:
		item.focus(ingore_se)
		on_changed.emit(select_index)
		
## 取消全部聚焦
func unfocus_all():
	var children = get_list().filter(func(item:LButton):return item.is_focus)
	for child:LButton in children:
		child.unfocus()
	
## 使用道具
func _use_item():

	## 1. 使用道具
	if craft_list.is_empty():
		on_submit.emit(current_item)
		#if event_res: on_use_item.emit(event_res)
	else:
	## 2. 组合选择道具
		## 2.1 将当前选择的物品加入组合列表
		if !craft_list.has(current_item):
			craft_list.append(current_item)
			_end_craft_item()
		else: 
			printerr("不能组合同一个物品")
			AudioManager.play_buzzle()
			#_cancel_craft_item()

## 组合道具
func _start_craft_item():
	if !craft_list.is_empty():return
	craft_list.append(current_item)
	print("开始组合模式")
	craft_mode_hint.show()
	refresh(true)
	focus(select_index)
	

func _cancel_craft_item():
	craft_list.clear()
	craft_mode_hint.hide()
	refresh(true)
	focus(select_index,true)
	pass

## 完成组合道具
func _end_craft_item():
	if craft_list.is_empty(): return
	var key:Array[String]
	for item in craft_list:
		key.append(item.item_id)
	
	if game_items.craft_enabled(key):
		## 移出对应元素
		AudioManager.play_se("button03a")
		game_items.make_craft_call(key)
		print("物品组合了")
	else:
		AudioManager.play_buzzle()
		print("没有事情发生")
	_cancel_craft_item()
