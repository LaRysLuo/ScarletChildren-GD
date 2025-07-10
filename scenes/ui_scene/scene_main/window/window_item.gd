extends InputableScene
class_name WindowItem

const MAX_ITEM_COUNT = 6
const item_inner_pre:PackedScene = preload("res://scenes/ui_scene/scene_main/window/component/item_inner.tscn")


@onready var item_grid: Control = $InnerWindowBgMargin/InnerWindowBg/HBoxContainer/ItemGridMargin/VBoxContainer/ItemGrid
@onready var arrow: Control = $InnerWindowBgMargin/InnerWindowBg/HBoxContainer/ItemGridMargin/VBoxContainer/Arrow
@onready var arrow2: Control = $InnerWindowBgMargin/InnerWindowBg/HBoxContainer/ItemGridMargin/VBoxContainer/Arrow2
@onready var detail_label:Label = $InnerWindowBgMargin/InnerWindowBg/HBoxContainer/MarginContainer/Label

## 道具临时列表
var item_list:Array
var item_inner_list:Array[ItemInner]

var _last_index:int = -1
var _select_index:int = -1
var _display_range:Array[int] = [0,MAX_ITEM_COUNT-1]


## SIGNAL
signal on_select_changed # 选择变化了
signal on_submit(idx:int) # 选择提交了
signal on_cancel


func _ready() -> void:
	set_handler("cancel",_on_cancel)
	self.hide()
	pass

## 初始化窗口
func set_items(items:Array) -> void:
	print("item",items)
	self.item_list = items

## 显示
func show_and_active(): 
	await _render_item_list()
	if self._select_index == -1: select(0) # 选择第一个选项
	else: select(self._select_index) 
	self.show()

## 冻结
func hide_and_clear():
	_page_reset()
	_last_index = -1
	self.hide()
	pass


## 刷新道具列表
# 将所有的列表都更新出来
func _render_item_list(): 
	_clear_item_list()
	var index = 0
	for item in item_list:
		await  _render_item_inner(item,index)
		index += 1


## 刷新道具
func _render_item_inner(item:Dictionary,index:int):
	var item_name:String = item.get("name")
	
	var icon_path = item.get("icon")
	var item_icon:Texture2D = load(icon_path) if icon_path else null
	
	var item_inner:ItemInner = item_inner_pre.instantiate()
	item_inner_list.append(item_inner)
	item_inner.lb_select_changed.connect(_on_select_changed)
	item_inner.lb_submit.connect(_on_submit)
	# item_inner.lb_cancel.connect(_on_cancel)
	item_grid.add_child(item_inner)
	if index >= MAX_ITEM_COUNT: item_inner.hide()
	item_inner.call_deferred("set_info",item_name,item_icon)
	
	await  item_inner.on_inited

## 清除列表
func _clear_item_list():
	for item in item_inner_list:
		item.lb_select_changed.disconnect(_on_select_changed)
		item.lb_submit.disconnect(_on_submit)
		item.lb_cancel.disconnect(_on_cancel)
		item.queue_free()
	item_inner_list.clear()

## 选择
func select(index:int):
	if item_inner_list.is_empty(): 
		_show_arrow()
		_clear_detail()
		return
	

	on_select_changed.emit()
	print("选择的idx=",index)
	## 如果判断当前index不在范围内,
	## 整体页面向上移动
	if index <  _display_range[0]:_page_back(index)

	if index > _display_range[1]: _page_next(index)

	_show_arrow()
	if index != self._select_index: self._last_index = self._select_index # 0
	self._select_index = index # 1
	item_inner_list[self._select_index].focus()
	if self._last_index != -1:
		item_inner_list[self._last_index].unfocus()
	_show_detail()

## 显示箭头
func _show_arrow():
	if _display_range[1] <  item_inner_list.size() - 1:
		arrow.self_modulate = Color(1, 1, 1, 1)
	else: 
		arrow.self_modulate = Color(1,1,1,0)

	if 	_display_range[0] > 0:
		arrow2.self_modulate = Color(1, 1, 1, 1)
	else: 
		arrow2.self_modulate = Color(1,1,1,0)

## 显示物品详情
func _show_detail():
	detail_label.text =	item_list[self._select_index].get("desc") 

func _clear_detail():
	detail_label.text = ""

## 使用道具
func _use_item():
	pass

## 页面向上移
func _page_next(index: int): #8
	while _display_range[1] < index: #5 < 8  # 6 <8  # 7 < 8 # 8 < 8
		print("向下滚动")
		item_inner_list[_display_range[0]].hide() 
		_display_range[0] += 1
		_display_range[1] += 1
		item_inner_list[_display_range[1]].show()

## 页面向上移
func _page_back(index:int):
	print("向上滚动")
	while _display_range[0] > index:
		item_inner_list[_display_range[1]].hide()
		_display_range[0] -= 1
		_display_range[1] -= 1
		item_inner_list[_display_range[0]].show()

## 页面重置
func _page_reset():
	_display_range[0] = 0
	_display_range[1] = MAX_ITEM_COUNT -1

## 回调函数
func _on_select_changed(index:int):
	if !visible: return

	var current := self._select_index
	match  index:
		0: 
			#向下移动光标
			if self._select_index < item_list.size() -1: current+=1
		3:
			#向上移动	光标
			if self._select_index > 0: current-=1
	select(current)

## 回调函数：提交
func _on_submit():
	on_submit.emit(self._select_index)
	_use_item()

## 回调函数：取消
func _on_cancel(): 
	on_cancel.emit()
