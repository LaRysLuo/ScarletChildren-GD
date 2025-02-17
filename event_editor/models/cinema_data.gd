extends BaseEventNode
class_name CinemaData

## 演出场景的路径
@export var cinema_scene_path:String

func _init(_node_type:int = 0,_pos:Vector2 = Vector2.ZERO,_cinema_scene_path="") -> void:
	self.node_type = _node_type
	self.pos = _pos
	self.cinema_scene_path = _cinema_scene_path

## 重写执行方法
func _execute(_event,_agrs):
	## 获取演出场景
	var cinema = load(cinema_scene_path) as PackedScene
	## 跳转到演出场景
	var cinema_node = await SceneManager.navigate_to(cinema)
	if cinema_node is CinemaScene:
		print("正在运行剧场模式，等待结束")
		await  cinema_node.on_complete
		GameManager.set_game_state_buszing()
		print("剧场模式结束")
	## 继续执行下一个节点
