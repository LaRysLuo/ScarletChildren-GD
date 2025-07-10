@tool
extends HBoxContainer
class_name MenuBox

var variable_name_input:LineEdit:
	get: return get_node("MarginContainer/HSplitContainer/MenuInner/VariableName/LineEdit")
	
var variable_type_input:OptionButton:
	get:return get_node("MarginContainer/HSplitContainer/MenuInner/VariableType/OptionButton")

var value_string_input:LineEdit:
	get:return get_node("MarginContainer/HSplitContainer/MenuInner/VariableValue/ValueString2")

var value_bool_input:CheckBox:
	get:return get_node("MarginContainer/HSplitContainer/MenuInner/VariableValue/ValueBool")

var value_int_input:SpinBox:
	get:return get_node("MarginContainer/HSplitContainer/MenuInner/VariableValue/ValueInt")

var add_btn:Button:
	get: return get_node("MarginContainer/HSplitContainer/Button")

## 信号
signal on_variable_added(key:String,type:int,value)

func _ready() -> void:
	init_type_input()
	add_btn.pressed.connect(_add_variable)

func _get_value_input(idx:int):
	match variable_type_input.get_item_id(idx):
		VariableCore.VariableType.INT: return value_int_input
		VariableCore.VariableType.STRING:return value_string_input
		VariableCore.VariableType.BOOL: return value_bool_input
	return null

func _get_value(idx:int):
	match variable_type_input.get_item_id(idx):
		VariableCore.VariableType.INT: return value_int_input.value
		VariableCore.VariableType.STRING:return value_string_input.text
		VariableCore.VariableType.BOOL: return value_bool_input.button_pressed
## 初始化类型输入
func init_type_input(): 
	var keys = VariableCore.VariableType.keys()
	variable_type_input.clear()
	for key in keys: 
		print("当前的value=",VariableCore.VariableType.get(key))
		variable_type_input.add_item(key,VariableCore.VariableType.get(key))
	variable_type_input.item_selected.connect(_refresh_value_input)
	_refresh_value_input(0)

func _refresh_value_input(idx:int):
	#var id =  variable_type_input.get_item_id(idx)
	_hide_all_value_input()
	#print("现在选择的=",id)
	_get_value_input(idx).show()
	
func _hide_all_value_input():
	value_string_input.hide()
	value_bool_input.hide()
	value_int_input.hide()

func _add_variable():
	var variable_name = variable_name_input.text
	print("variable_name=",variable_name)
	var type_selected = variable_type_input.get_item_id(variable_type_input.selected)
	print("type_selected=",type_selected)
	var value = _get_value(variable_type_input.selected)
	print("value=",value)
	#var _data = VariableData.new(variable_name,type_selected,value)
	on_variable_added.emit(variable_name,type_selected,value)
