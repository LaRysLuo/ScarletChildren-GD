extends Node
class_name Camera

## 摄像头控制器

static  var gm:GameManager:
	get: return GameManager


## 相机移动
static func camera_move(offset:Vector2,time:float):
	var camera: Camera2D = get_main_camera()
	if !camera:
		print_debug("没有找到camera")
		return
	
	var tween: Tween = gm.get_tree().create_tween()
	# var camera_pos = Vector2(0, camera.offset.y - 200)
	tween.tween_property(camera, "offset", offset, time)
	await tween.finished

## 重置摄像机
static  func reset_camera(with_tween: bool = true):
	var cam = get_main_camera()
	if !cam:
		print_debug("没有找到camera")
		return
	if with_tween:
		var tween: Tween =  gm.get_tree().create_tween()
		tween.tween_property(cam, "offset", Vector2.ZERO, 0.8)
		await tween.finished
	else: cam.offset = Vector2.ZERO

## 获得主摄像机
static  func get_main_camera() -> Camera2D:
	if !gm.player: return null
	return gm.player.cam
	#var scene = get_tree().current_scene
	#if scene:
		#return scene.get_node_or_null("Camera2D")
	#return null
