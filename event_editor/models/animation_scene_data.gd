extends BaseEventNode
class_name AnimationSceneData

## 演出场景的相对路径
@export var animation_scene_path:String

func _init(_node_type:int = 0,_pos:Vector2 = Vector2.ZERO,_animation_scene_path="") -> void:
	self.node_type = _node_type
	self.pos = _pos
	self.animation_scene_path = _animation_scene_path

## 重写执行方法
func _execute(_event,_agrs):
	## 获取演出场景
	var scene = load(animation_scene_path) as PackedScene
	## 跳转到演出场景
	var scene_node = await SceneManager.navigate_to(scene)
	if not scene_node is AnimationScene:
		push_error("[AnimationSceneData]跳转到场景不是AnimationScene")
		return
	print("[AnimationSceneData]正在运行动画场景，等待结束")
	await  scene_node.finished
	# GameManager.set_game_state_buszing()
	print("[AnimationSceneData]动画场景已结束")
	## 继续执行下一个节点
