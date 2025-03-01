extends EventCondition
class_name ECItem

## 判断玩家的背包里是否拥有该道具

#@export  var type:EventConditionType = EventConditionType.Item
## 设置道具id
@export var item_id:StringName

## 该参数的true还是false 
@export var value:bool

## 包含隐藏道具
@export_custom(PROPERTY_USAGE_STORAGE,"包含隐藏道具") var is_all:bool = false

## 重写父类的事件
func _get_result() -> bool:
	## 判断玩家背包中的道具 
	print("当前判断结果：",GameManager.game_player.has_item(item_id,is_all) == value)
	return GameManager.game_player.has_item(item_id,is_all) == value
