@tool
extends BaseGN
class_name ScriptGN

var script_te:TextEdit:
	get:return get_node("VBoxContainer/HSplitContainer/TextEdit")

func from_data(data:BaseEventNode) -> BaseGN:
	if data is ScriptData:
		script_te.text = data.script_cmd
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	var cmd:String = script_te.text
	return ScriptData.new(BaseEventNode.Scripts,self.position_offset,cmd)
