@tool
extends BaseGN
class_name FadeoutGN

var spin_box:SpinBox:
	get():return get_node("VBoxContainer/HSplitContainer/SpinBox")

func from_data(data:BaseEventNode) -> BaseGN:
	if data is FadeoutData:
		spin_box.value = data.time
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return FadeoutData.new(BaseEventNode.Fadeout,self.position_offset,spin_box.value)
