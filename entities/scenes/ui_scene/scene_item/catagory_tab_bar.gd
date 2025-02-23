extends PanelContainer
class_name CatagoryTabBar

var tab_res:PackedScene = preload("res://scenes/ui_scene/scene_item/component/tab/tab.tscn") as PackedScene

var catagory_trans:Control:
	get():return get_node("CatagoryGroup")

## 信号
signal on_changed(index:int)
signal on_submit(index:int)
signal on_active
# 回退
signal on_cancel

## 分类的配置
var catagory_group:Array
var last_index:int = -1
var select_index:int = 0:
	set(val):
		last_index = select_index
		select_index = val
		focus(select_index)
		
		
var isActive:bool = false

func _input(event: InputEvent) -> void:
	if !isActive:return 
	if event.is_action_pressed("left") && select_index > 0:
		get_window().set_input_as_handled()
		select_index -= 1
	if event.is_action_pressed("right") && select_index < get_children_size() -1:
		get_window().set_input_as_handled()
		select_index += 1
	if event.is_action_pressed("submit"):
		get_window().set_input_as_handled()
		catagory_confirm()
	if event.is_action_pressed("cancel"):
		get_window().set_input_as_handled()
		catagory_cancel()
	
## 取消
func catagory_cancel():
	on_cancel.emit()
	
## 确认
func catagory_confirm():
	on_submit.emit(select_index)
	
func active():
	self.isActive = true
	focus(select_index)
	on_active.emit()
	
func deactive():
	self.isActive = false
	#unfocus_all()

func set_info(catagory_group:Array) -> void:
	self.catagory_group = catagory_group
	_init_catagory_bar()
	

## 初始化分类标签栏
func _init_catagory_bar():
	for catagory  in catagory_group:
		var tab = tab_res.instantiate()
		if tab is Tab:
			tab.set_info(catagory.type_name)	
			catagory_trans.add_child(tab)
func get_children_size() -> int:
	return get_catagory_children().size()

func get_catagory_children():
	return 	catagory_trans.get_children()

## 聚焦某个元素
func focus(index:int):
	var catagory_tabs =	get_catagory_children()
	if catagory_tabs.is_empty():return
	var last_tab = catagory_tabs[last_index]
	if last_tab && last_tab is Tab:
		last_tab.unfocus()
	var tab = catagory_tabs[index]
	if tab && tab is Tab:
		tab.focus()
		on_changed.emit(select_index)

## 取消全部聚焦
func unfocus_all():
	var children = get_catagory_children().filter(func(item:Tab):return item.is_focus())
	for child:Tab in children:
		child.unfocus()
