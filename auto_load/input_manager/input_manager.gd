extends Node

## 按键常量的定义

const KEY_LIST:Dictionary = {
	
}

const KEY_DOWN = 0
const KEY_LEFT = 1
const KEY_RIGHT = 2
const KEY_UP = 3
const KEY_A = 4
const KEY_B = 5
const KEY_X = 6
const KEY_Y = 7
const KEY_R1 = 8

## 属性
var input_trigger:= false #输入防抖

## 信号
signal on_action_pressed(key:int)

## INFO 功能说明
# 这里主要作用是手柄的防抖
func _input(event: InputEvent) -> void:
	if !input_trigger && event.is_pressed():
		# print("输入")
		var key:float = -1
		if event.is_action_pressed("down"): key = KEY_DOWN
		if event.is_action_pressed("left"): key =KEY_LEFT
		if event.is_action_pressed("right"): key = KEY_RIGHT
		if event.is_action_pressed("up"): key = KEY_UP
		if event.is_action_pressed("submit"): key = KEY_A
		if event.is_action_pressed("cancel"): key = KEY_B
		if event.is_action_pressed("craft"): key = KEY_X
		if event.is_action_pressed("y"): key = KEY_Y
		if event.is_action_pressed("R1"): key= KEY_R1
		if key == -1: return
		self.input_trigger = true
		on_action_pressed.emit(key)
	elif event.is_released() && input_trigger: self.input_trigger = false


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			Save.save_data(0)
