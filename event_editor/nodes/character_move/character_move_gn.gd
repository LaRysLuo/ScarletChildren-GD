@tool
extends BaseGN
class_name CharacterMoveGN

const character_selection_window_pre = preload("res://event_editor/component/character_selection_window/window_character_selection.tscn")

## 移动类型
var move_type:OptionButton:
	get():return get_node("VBoxContainer/HSplitContainer/OptionButton")

## 目标角色
var target_character:OptionButton:
	get():return get_node("VBoxContainer/HSplitContainer2/HBoxContainer/Label")

var selected_character:Dictionary = {}

## 选择按钮
var character_selcted_btn:Button:
	get():return get_node("VBoxContainer/HSplitContainer2/HBoxContainer/Button")

var speed_factor_spinbox:SpinBox:
	get():return get_node("VBoxContainer/HSplitContainer5/SpinBox")

## 步数
var step_count:SpinBox:
	get():return get_node("VBoxContainer/HSplitContainer3/SpinBox")
	
var wait_finished:CheckBox:
	get():return get_node("VBoxContainer/HSplitContainer4/CheckBox")

#var characters:
	#get(): return get_characters()


func _enter_tree() -> void:
	character_selcted_btn.button_down.connect(show_character_selected_window)	
	
func _exit_tree() -> void:
	character_selcted_btn.button_down.disconnect(show_character_selected_window)	
	
var character_selected_window:Popup 
func show_character_selected_window():
	character_selected_window = Popup.new()
	character_selected_window.transient = true

	character_selected_window.title = "选择事件"
	#character_selected_window.close_requested.connect(func(): 
		#get_tree().root.remove_child(character_selected_window)
		#character_selected_window.queue_free()
	#)
	#print("character_selection_window_pre",character_selection_window_pre)
	var child = character_selection_window_pre.instantiate()
	child.on_selection_complete.connect(func(item):
		selected_character = item
		_refresh_selected()
		#call_deferred("close_popup")
		var timer = get_tree().create_timer(0.1)
		timer.timeout.connect(close_popup)
	
		#get_tree().root.remove_child(character_selected_window)
		#character_selected_window.queue_free()
	)
	character_selected_window.size = Vector2(300,300)
	#character_selected_window = Vector2(300, 200)
	get_tree().root.add_child(character_selected_window)
	character_selected_window.add_child(child)
	
	character_selected_window.popup_centered()  # 弹窗居中显示
	#character_selected_window.show()

func close_popup():
	character_selected_window.hide()

func _refresh_selected():
	target_character.text = selected_character['label']

	
## 回显参数
#func set_value(move_type:int,target_character,step_count:int,wait_finished:bool):


func from_data(data:BaseEventNode):
	if(!data):return
	if data is CharacterMoveData:
		self.move_type.selected = data.move_type
		self.selected_character = data.target_char
		self.step_count.value = data.step_count
		self.speed_factor_spinbox.value = data.speed_factor
		self.wait_finished.button_pressed = data.wait_finished
		_refresh_selected()
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return CharacterMoveData.new(BaseEventNode.CharacterMove,self.position_offset,move_type.selected,selected_character,step_count.value,speed_factor_spinbox.value,wait_finished.button_pressed)
