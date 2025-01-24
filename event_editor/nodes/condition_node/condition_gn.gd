@tool
extends BaseGN
class_name ConditionGN

## 组件引用
var script_te:TextEdit:
	get:return get_node("VBoxContainer/HSplitContainer/TextEdit")

func from_data(data:BaseEventNode) -> BaseGN:
	if data is ConditionData:
		script_te.text = data.script_cmd
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return ConditionData.new(BaseEventNode.ConditionNode,self.position_offset,script_te.text)
