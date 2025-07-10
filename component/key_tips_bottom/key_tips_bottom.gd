@tool
extends Control
class_name KeyTipsBottom


enum keyType{
	key_a,
	key_b,
	key_x,
	key_y,
	key_arrow,
	key_lf,
	key_rt
}

#const key_a = "a"
#const key_b = "b"
#const key_x = "x"
#const key_y = "y"


var btn_config:Array[KeyTipsConfig] = []

#@export  var btn_config_readony:Array[KeyTipsConfig]:
	#get():return btn_config

@export var a_btn:KeyTipsConfig:
	set(val):
		# print("1111",val.key_name if val else "") 
		if a_btn:
			a_btn.on_value_changed.disconnect(refresh)
		a_btn = val
		if a_btn:
			a_btn.connect("on_value_changed",refresh.bind(keyType.key_a,a_btn))
			refresh(keyType.key_a,a_btn)
#
@export var b_btn:KeyTipsConfig:
	set(val):
		if b_btn: b_btn.on_value_changed.disconnect(refresh)
		b_btn = val
		if b_btn:
			b_btn.connect("on_value_changed",refresh.bind(keyType.key_b,b_btn))
			refresh(keyType.key_b,b_btn)
#
@export var x_btn:KeyTipsConfig:
	set(val):
		if x_btn: x_btn.on_value_changed.disconnect(refresh)
		x_btn = val
		if x_btn: 
			x_btn.connect("on_value_changed",refresh.bind(keyType.key_x,x_btn))
			refresh(keyType.key_x,x_btn)
#
@export var y_btn:KeyTipsConfig:
	set(val):
		if y_btn: y_btn.on_value_changed.disconnect(refresh)
		y_btn = val
		if y_btn: 
			y_btn.connect("on_value_changed",refresh.bind(keyType.key_y,y_btn))
			refresh(keyType.key_y,y_btn)

@export var arrow_btn:KeyTipsConfig:
	set(val):
		if arrow_btn: arrow_btn.on_value_changed.disconnect(refresh)
		arrow_btn = val
		if arrow_btn: 
			arrow_btn.connect("on_value_changed",refresh.bind(keyType.key_arrow,arrow_btn)) 
			refresh(keyType.key_arrow,arrow_btn)


func _enter_tree() -> void:
	const config_name = ["A键配置","B键配置","X键配置","Y键配置","左右键配置"]
	print("btn_config=",btn_config)
	if btn_config.is_empty():
		btn_config.append(a_btn)
		btn_config.append(b_btn)
		btn_config.append(x_btn)
		btn_config.append(y_btn)
		btn_config.append(arrow_btn)

	var index = 0
	for config:KeyTipsConfig in btn_config:
		if config:
			config.resource_name = config_name[index]
			refresh(index,config)
		index+=1
#
#func _exit_tree() -> void:
	#var index = 0
	#for config:KeyTipsConfig in btn_config:
		#config.disconnect("on_value_changed",refresh.bind(index,config))

## 引用组件
var a_btn_trans:Control:
	get():return get_node("Key")
var a_btn_labl:Label:
	get():return get_node("Key/Label")
var b_btn_trans:Control:
	get():return get_node("Key2")
var b_btn_labl:Label:
	get():return get_node("Key2/Label")	
var x_btn_trans:Control:
	get():return get_node("Key3")
var x_btn_labl:Label:
	get():return get_node("Key3/Label")
var y_btn_trans:Control:
	get():return get_node("Key4")
var y_btn_labl:Label:
	get():return get_node("Key4/Label")
var arrow_btn_trans:Control:
	get():return get_node("Key5")
var arrow_btn_labl:Label:
	get():return get_node("Key5/Label")

var lf_arrow_trans:Control:
	get():return get_node("Key5/TextureRect")

var rt_arrow_trans:Control:
	get():return get_node("Key5/TextureRect2")

	
## INFO 对外函数 
func set_btns_info(info:Dictionary):
	var btn_value:KeyTipsConfig = info.get("a_btn")
	if btn_value:
		print("netwww",btn_value.key_name) 
		a_btn = btn_value
	var btn_value2:KeyTipsConfig = info.get("b_btn")
	if btn_value2: b_btn = btn_value2
	var btn_value3:KeyTipsConfig = info.get("x_btn")
	if btn_value3: x_btn = btn_value3
	var btn_value4:KeyTipsConfig = info.get("y_btn")
	if btn_value4: y_btn = btn_value4
	var btn_value5:KeyTipsConfig = info.get("arrow_btn")
	if btn_value5: arrow_btn = btn_value5

## 刷新按键
func refresh(key_type:keyType,config:KeyTipsConfig):	
	print("刷新中=",config)
	if !config:return
	var trigger_key:Control = get_key_label(key_type)
	trigger_key.text = config.key_name
	trigger_key.get_parent().visible = config.is_show


func get_key_grid(key_type:keyType) -> Control:
	var trigger_key:Control
	match key_type:
		keyType.key_a: trigger_key = a_btn_trans
		keyType.key_b: trigger_key = b_btn_trans
		keyType.key_x: trigger_key = x_btn_trans
		keyType.key_y: trigger_key = y_btn_trans
		keyType.key_arrow:trigger_key = arrow_btn_trans
		keyType.key_lf:trigger_key = lf_arrow_trans
		keyType.key_rt:trigger_key = rt_arrow_trans
	return trigger_key
	
## 获得键
func get_key_label(key_type:keyType) -> Control:
	var trigger_key:Control
	match key_type:
		keyType.key_a: trigger_key = a_btn_labl
		keyType.key_b: trigger_key = b_btn_labl
		keyType.key_x: trigger_key = x_btn_labl
		keyType.key_y: trigger_key = y_btn_labl
		keyType.key_arrow: trigger_key = arrow_btn_labl
	return trigger_key
	
func get_key_config(key_type:keyType) -> KeyTipsConfig:
	var trigger_key:KeyTipsConfig
	match key_type:
		keyType.key_a: trigger_key = a_btn
		keyType.key_b: trigger_key = b_btn
		keyType.key_x: trigger_key = x_btn
		keyType.key_y: trigger_key = y_btn
		keyType.key_arrow: trigger_key = arrow_btn
	return trigger_key

## 显示key
func show_key(_key_type:keyType):
	get_key_config(keyType).is_show = true

## 隐藏key
func hide_key(_key_type:keyType):
	get_key_config(keyType).is_show = false

## 设置key可用
func enable_key(key_type:keyType):
	get_key_grid(key_type).modulate.a = 1

## 设置key不可用
func disable_key(key_type:keyType):
	get_key_grid(key_type).modulate.a = 0.4
