extends BaseEventNode
class_name CinemaData

## 演出场景的路径
@export var cinema_scene_path:String

func _init(node_type:int = 0,pos:Vector2 = Vector2.ZERO,cinema_scene_path="") -> void:
	self.node_type = node_type
	self.pos = pos
	self.cinema_scene_path = cinema_scene_path

## 重写执行方法
func _execute(event):
	## 获取演出场景
	var cinema = load(cinema_scene_path) as PackedScene
	## 跳转到演出场景
	var cinema_node = await SceneManager.navigate_to(cinema)
	if cinema_node is CinemaScene:
		print("正在运行剧场模式，等待结束")
		await  cinema_node.on_complete
		print("剧场模式结束")
	## 继续执行下一个节点
	
