@tool
extends BaseGN
class_name ItemlinkGN

var text_edit:TextEdit:
	get(): return get_node("HSplitContainer/TextEdit")

func from_data(data:BaseEventNode) -> BaseGN:
	if data is ItemlinkData:
		text_edit.text = data.item_id
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return ItemlinkData.new(BaseEventNode.Itemlink,self.position_offset,text_edit.text)
