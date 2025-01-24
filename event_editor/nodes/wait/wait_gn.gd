@tool
extends BaseGN
class_name WaitGN

var spinBox:SpinBox:
	get(): return get_node("VBoxContainer/HSplitContainer3/SpinBox")

func from_data(data) -> BaseGN:
	if data is WaitData:
		self.spinBox.value = data.time
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return WaitData.new(BaseEventNode.Wait,self.position_offset,spinBox.value)
