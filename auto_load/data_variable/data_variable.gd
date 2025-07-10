extends Resource
class_name DataVariable

## 游戏里的变量

## 公共变量的配置 
var global_variable_config:Array[Dictionary] = [
	
	{
		"id":"e00_has_seen_rose_intro",
		"type":TYPE_BOOL,
		"note":"蔷薇馆前开场事件",
	},
	{
		"id":"e00_heard_scarlet_mansion_story",
		"type":TYPE_BOOL,
		"note":"听完了蔷薇传说的故事"
	}
]

func has_variable(name:String) -> Dictionary:
	var filters = global_variable_config.filter(func(item): return item.id == name)
	if filters.is_empty(): return {}
	return filters.front()
