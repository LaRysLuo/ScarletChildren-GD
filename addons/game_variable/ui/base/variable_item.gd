@tool
extends PanelContainer
class_name VariableItem

## 名称标签
var name_label:Label:
	get: return get_node("MarginContainer/HBoxContainer/HBoxContainer/VariableLabel")

## 类型标签
var type_label:Label:
	get: return get_node("MarginContainer/HBoxContainer/HBoxContainer/VariableType")

## 数字输入	
var value_int_input:SpinBox:
	get: return get_node("MarginContainer/HBoxContainer/ValueInt")

## 字符串输入
var value_string_input:LineEdit:
	get: return get_node("MarginContainer/HBoxContainer/ValueString2")

## 布尔输入
var value_bool_input:CheckBox:
	get: return get_node("MarginContainer/HBoxContainer/ValueBool")

var variable_type_name_dict:Dictionary = {}

func _init_variable_type_name_dict():
	variable_type_name_dict = {
		VariableCore.VariableType.INT: { 
			"name": "int",
			"input": value_int_input,
			"set":func(val): value_int_input.value = val
		},
		VariableCore.VariableType.STRING:{
			"name":"string",
			"input":value_string_input,
			"set":func(val):value_string_input.text = val
		},
		VariableCore.VariableType.BOOL:{
			"name":"bool",
			"input":value_bool_input,
			"set":func(val):value_bool_input.button_pressed = val
		},
		#VariableCore.VariableType.FLOAT:{
			#"name":"float"
		#},
	}

func _ready() -> void:
	_init_variable_type_name_dict()

func refresh(key_name:String,type:VariableCore.VariableType,value):
	name_label.text = key_name
	print("key_name",key_name)
	print("config=",_get_config(type))
	type_label.text = _get_config(type).name
	_refresh_input_display(type,value)

func _get_config(type:VariableCore.VariableType):
	return variable_type_name_dict.get(type)

func _refresh_input_display(type:int,val):
	_hide_all_input()
	_get_config(type).input.show()
	_get_config(type).set.call(val)

func _hide_all_input():
	value_int_input.hide()
	value_string_input.hide()
	value_bool_input.hide()
	
