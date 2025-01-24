@tool
extends BaseGN
class_name PlayAnimGN

var anim_name_input:TextEdit:
	get:return get_node("VBoxContainer/HSplitContainer/TextEdit")

func from_data(data:BaseEventNode) -> BaseGN:
	if data is PlayAnimData:
		anim_name_input.text = data.anim_name
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	var anim_name:String = anim_name_input.text
	return PlayAnimData.new(BaseEventNode.PlayEventAnim,self.position_offset,anim_name)
