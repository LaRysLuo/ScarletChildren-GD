@tool
extends BaseGN
class_name InnerSceneGN

var input_label:LineEdit:
	get:return get_node("VBoxContainer/HSplitContainer3/LineEdit")




func from_data(data:BaseEventNode) -> BaseGN:
	if data is PasswordInputData:
		input_label.text = data.password
	return self

func to_data(_edit:GraphEdit) -> BaseEventNode:
	return PasswordInputData.new(BaseEventNode.PasswordInput,self.position_offset,input_label.text)
	
