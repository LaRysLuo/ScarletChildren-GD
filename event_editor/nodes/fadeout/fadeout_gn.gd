@tool
extends BaseGN
class_name FadeoutGN

func to_data(edit:GraphEdit) -> BaseEventNode:
	return FadeoutData.new(BaseEventNode.Fadeout,self.position_offset)
