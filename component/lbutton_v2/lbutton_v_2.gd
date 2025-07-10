@tool
extends ListItemBase
class_name LbuttonV2

"""
该组件需要在指定场景中使用，请勿单独使用
"""

## 图标
@export var icon:Texture2D:
	set(val):
		if icon!= val:
			icon = val
			if !Engine.is_editor_hint():
				return
			call_deferred("_refresh")

## 文本
@export var text:String:
	set(val):
		if text!= val:
			text = val
			if !Engine.is_editor_hint():
				return
			call_deferred("_refresh")

## 符号 
@export var symbol:String

## 禁用状态
@export var disable:bool:
	set(val):
		disable = val
		call_deferred("_refresh")


#================================================================

## 背景
var background_tr:TextureRect:
	get: return get_node("Background")

## 图标
var icon_tr:TextureRect:
	get: return get_node("Background/MarginContainer/HBoxContainer/Icon")

## 文本
var text_label:Label:
	get: return get_node("Background/MarginContainer/HBoxContainer/Text")


## 选择颜色
@export var selected_color:Color = Color.WHITE

## 默认颜色
var default_color:Color:
	get: return Color(255,87,176,0.5)

## 禁用颜色
var disable_color:Color:
	get: return Color.DIM_GRAY



## 刷新
func _refresh():
	if icon != null : 
		icon_tr.texture = icon
	else:
		icon_tr.hide()
	text_label.text = text

	if disable: background_tr.self_modulate = disable_color
	else: background_tr.self_modulate = default_color
	print("<%s>按钮组件初始化完成" % self.name)


## 初始化
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_refresh()
	# 判断是否合法

## 设置数据
func set_data(_data:Dictionary): 
	self.icon = _data.get("icon",null)
	self.text = _data.get("name","")
	self.symbol = _data.get("symbol","")

## 聚焦
func focus(): 
	background_tr.self_modulate = selected_color

## 失焦
func unfocus(): 
	background_tr.self_modulate = default_color
