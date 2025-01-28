@tool
extends Node2D
class_name Lights

## 光照系统是否启动
@export var _enable:bool = true
const ORIGIN_COLOR = Color("#323232")
var ORIGIN_ENERGY:float
## 黑暗强度
@export_range(0,1) var dark_strength:float = 1:
	set(val):
		dark_strength = val
		refresh()

## 基础光照强度
@export_range(0,1) var base_light_strength:float = 1:
	set(val):
		base_light_strength = val
		refresh()

# 引用组件
var _dark_cm:CanvasModulate:
	get():return get_node("CanvasModulate")
	
var _point_light:PointLight2D:
	get():return get_node("PointLight2D")

func _ready() -> void:
	ORIGIN_ENERGY = _point_light.energy

## 启动光照
func enable():
	_enable = true
	
## 关闭光照
func disable():
	_enable = false

## 刷新光照系统的效果
func refresh():
	var new_color = Color(ORIGIN_COLOR, ORIGIN_COLOR.a * dark_strength)
	_dark_cm.color = new_color
	_point_light.energy = ORIGIN_ENERGY * base_light_strength
	pass
