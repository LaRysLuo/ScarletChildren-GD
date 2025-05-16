@tool
extends Control
class_name LbuttonV2


## 图标
@export var icon:Texture2D:
    set(val):
        if icon!= val:
            icon = val
            call_deferred("_refresh")

## 文本
@export var text:String:
    set(val):
        if text!= val:
            text = val
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
@export var selected_color:Color:
    get: return Color(255,87,176,0.5)

## 默认颜色
var default_color:Color:
    get: return Color.WHITE

## 禁用颜色
var disable_color:Color:
    get: return Color.DIM_GRAY



## 刷新
func _refresh():
    if icon != null : icon_tr.texture = icon
    text_label.text = text

    if disable: background_tr.modulate = disable_color
    else: background_tr.modulate = default_color


## 初始化
func _ready() -> void:
    if Engine.is_editor_hint():
        return
    _refresh()
    # 判断是否合法


## 聚焦
func focus(): 
    background_tr.self_modulate = selected_color

## 失焦
func unfocus(): 
    background_tr.self_modulate = default_color