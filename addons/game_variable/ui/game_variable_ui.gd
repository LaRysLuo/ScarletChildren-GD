@tool
extends Control

var variable_core:VariableCore
var variable_item_res = preload("res://addons/game_variable/ui/base/variable_item.tscn")


var menu_box:MenuBox:
	get: return get_node("VBoxContainer/MenuBox")

var list_grid:VBoxContainer:
	get: return get_node("VBoxContainer/List")
	
var save_btn:Button:
	get: return get_node("VBoxContainer/MenuBox/MarginContainer2/Button")

func _ready() -> void:
	_init_variable_core()
	_init_menu_box()
	_init_save_btn()
	call_deferred("refresh_list")
	
func _init_variable_core():
	variable_core = VariableCore.new()

func _init_menu_box():
	menu_box.on_variable_added.connect(add_variable)

func _init_save_btn():
	save_btn.pressed.connect(save)

## 清空渲染列表
func _clear_list():
	for item in list_grid.get_children():
		list_grid.remove_child(item)
		item.queue_free()

## 渲染列表
func refresh_list():
	print("[VariableUI]正在渲染列表")
	_clear_list()
	var list = variable_core.list()
	print("list=",list)
	if list.is_empty(): return
	for data:VariableData in list.values():
		print("data=",data.initial_value)
		var item:VariableItem = variable_item_res.instantiate()
		list_grid.add_child(item)
		item.call_deferred("refresh",data.key,data.type,data.get_value()) 

## 添加新的变量
func add_variable(_key:String,_type:int,_value:Variant):
	
	variable_core.add(_key,_type,_value)
	refresh_list()

## 存档数据
func save(): 
	print("[VariableUI]正在保存数据")
	variable_core.save()
