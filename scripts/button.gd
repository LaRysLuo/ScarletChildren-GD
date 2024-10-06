@tool
extends Control
class_name LButton

@export  var text:String = "测试样本":
	set(new):
		text = new
		if Engine.is_editor_hint():
			refresh()
		elif is_init: refresh()
@onready var label_text:Label = $Label
@onready var cursor:ColorRect = $ColorRect
@onready var anim:AnimationPlayer = $AnimationPlayer


var is_focus:bool = false #该按钮是否被激活
var is_init = false 

signal  lb_focus_entered 
signal  lb_focus_exited
signal  lb_select_changed


func _ready() -> void:
	is_init = true
	refresh()

func _input(event: InputEvent) -> void:
	if is_focus == false: return 

	if event.is_action_pressed("up"): #3
		print("检测到输入up")
		lb_select_changed.emit(3)
		get_window().set_input_as_handled()
		pass
	if event.is_action_pressed("down"):#0
		lb_select_changed.emit(0)
		get_window().set_input_as_handled()
		pass
	if event.is_action_pressed("left"):#1
		lb_select_changed.emit(1)
		get_window().set_input_as_handled()
		pass
	if event.is_action_pressed("right"):#2
		lb_select_changed.emit(2)
		get_window().set_input_as_handled()
		pass


func refresh():
	if !label_text: return
	print("text ",label_text)
	label_text.text = text
	unfocus()

	
func focus(none_se = false):
	cursor.show()
	if !none_se: AudioManager.play_se("Cursor1")
	anim.play("default")
	is_focus= true
	lb_focus_entered.emit()
	pass
	
func  unfocus():
	cursor.hide()
	anim.stop()	
	is_focus = false
	lb_focus_exited.emit()
