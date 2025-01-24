@tool
extends BaseGN
class_name SubThreadGN

func from_data(data) -> BaseGN:
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return SubThreadData.new(BaseEventNode.SubThread,self.position_offset)
