@tool
extends BaseGN
class_name FadeinGN

var spin_box:SpinBox:
	get():return get_node("VBoxContainer/HSplitContainer/SpinBox")

func from_data(data:BaseEventNode) -> BaseGN:
	if data is FadeinData:
		spin_box.value = data.time
		print("spin_box=",spin_box.value)
	return self
		

func to_data(edit:GraphEdit) -> BaseEventNode:
	return FadeinData.new(BaseEventNode.Fadein,self.position_offset,spin_box.value)
