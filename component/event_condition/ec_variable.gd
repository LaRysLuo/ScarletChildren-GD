extends EventCondition
class_name ECVariable

## 判断该故事是否已执行

#@export  var type:EventConditionType = EventConditionType.Item
## 设置道具id
@export var variable_name:String

## 该参数的true还是false 
@export var value:bool


## 重写父类的事件:想要最终变化效果生效需要<Event>订阅<GameVariable>的variable_changed信号
func _get_result() -> bool:
	## 判断玩家是否拥有该变量 
	return GameManager.game_variable.has(variable_name,value)
