@tool
extends BaseGN
class_name FadeinGN

func to_data(edit:GraphEdit) -> BaseEventNode:
	return FadeinData.new(BaseEventNode.Fadein,self.position_offset)
