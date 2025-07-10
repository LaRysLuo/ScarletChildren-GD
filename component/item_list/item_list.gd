extends SelectableScene
class_name ItemListV2

"""
##单列表LIST
# 将数据赋予该组件，然后进行一次性渲染

操作说明：
1. 需要设置ListItemScene

"""
# const ITEM_RES = preload("res://component/lbutton_v2/lbutton_v2.tscn")



# ================================



## 列表中渲染用的单元项
## [br]该场景必须继承于ListItemBase
## [br]
@export var list_item_scene:PackedScene


## 一次性渲染的行数
@export var col_count: int = 5



## 列表数据:根据该数据来生成列表内容
## [br] 参数类型 [Dictionary]
@export var list_data: Array[Dictionary] = []

## 当前第一个元素的索引
var current_index: int = 0


# =================================
# 信号
# =================================

signal on_item_confirm(symbol:String)

# =============================

## 列表的父类
var item_grid: Control:
	get: return get_node("VBoxContainer")

var item_entity_children:Array[Node]:
	get: return item_grid.get_children()

# ===============================

### 赋值列表数据源 
## [br] [param:data] [Array] 列表数据
## [br] [code]
## set_data([{
##       "name":"道具1",
##       "icon": null,
##       "symbol":
## }])
## [/code]
func set_data(data: Array):
	list_data.clear()
	list_data.append_array(data)

func show_window():
	await _render_list() # 渲染列表
	select(0)

# ================================
# 重写父类函数
# ================================

func _ready() -> void:
	if not _check_valid(): return
	super._ready()
	set_handler("ok",_handle_confirm)
	on_select_changed.connect(_handle_select)

## 重写回调，当光标触及顶部时，重新渲染列表
func _cursor_reached_top():
	if current_index <= 0: return
	current_index -= 1
	await _render_list()
	select(0)

## 重写回调，当光标触及底部时，重新渲染列表
func _cursor_reached_bottom():
	if current_index + col_count > list_data.size() - 1:
		return
	current_index += 1
	await _render_list()
	select(_list.size() - 1)


# ================================
# 内部函数
# ================================

## 检查
func _check_valid() -> bool:
	if not list_item_scene:
		push_error("ItemListV2没有配置ListItemScene")
		return false
	return true


## 渲染列表内容
func _render_list():
	if list_data.is_empty(): 
		_render_empty()
		return
	await _clear_list()
	var new_list = list_data.slice(current_index, current_index + col_count)
	if new_list.is_empty():return
	for data:Dictionary in new_list:
		var item:ListItemBase = list_item_scene.instantiate()
		item.set_data(data)
		item_grid.add_child(item)
		_list.append(data.get("symbol"))
	
func _render_empty():
	if !_list.is_empty():return
	var item:ListItemBase = list_item_scene.instantiate()
	item.set_data({})
	item_grid.add_child(item)
	_list.append("")

## 清空列表
func _clear_list():
	_list.clear()
	for ent in item_grid.get_children():
		item_grid.remove_child(ent)
		ent.queue_free()
	await get_tree().process_frame
	
func _handle_confirm():
	var symbol:String = _list[self._select_index]
	on_item_confirm.emit(symbol)

func _handle_select(index:int,last:int,_symbol:String):
	var selected = item_entity_children[index]
	selected.focus()
	if last != -1:
		var lasted = item_entity_children[last]
		lasted.unfocus()
