@tool
extends BaseGN
class_name AudioPlayerGN

var type_ref:OptionButton:
	get: return get_node("VBoxContainer/HSplitContainer/OptionButton")

var line_edit_ref:SpinBox:
	get: return get_node("VBoxContainer/HSplitContainer3/LineEdit")

var wait_ref:CheckBox:
	get: return get_node("VBoxContainer/HSplitContainer4/CheckBox")

func from_data(data) -> BaseGN:
	if data is AudioPlayerData:
		self.type_ref.selected = type_ref.get_item_index(data.type)
		self.line_edit_ref.text = data.audio_code
		self.wait_ref.button_pressed = data.is_wait
	return self

func to_data(_edit:GraphEdit) -> BaseEventNode:
	# print("测试输出:",)
	var _selected = type_ref.get_item_id(type_ref.selected)
	return AudioPlayerData.new(
		BaseEventNode.AudioPlayer,
		self.position_offset,
		_selected,
		line_edit_ref.text,
		wait_ref.button_pressed
	)
