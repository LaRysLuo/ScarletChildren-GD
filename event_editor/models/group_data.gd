extends BaseEventNode
class_name GroupData

@export var event_res:EventsRes

func _init(cmd:int = BaseEventNode.Scripts,pos:Vector2 = Vector2.ZERO,event_res:EventsRes = null) -> void:
	self.node_type = cmd
	self.pos = pos
	self.event_res = event_res

func _execute(event,args):
	pass
	#if event is Door1:
		#await  event.play_anim(anim_name)
