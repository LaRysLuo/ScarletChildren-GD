@tool
extends BaseGN
class_name StartGN

func to_data(edit) -> BaseEventNode:
	return BaseEventNode.new(BaseEventNode.Start,self.position_offset)
