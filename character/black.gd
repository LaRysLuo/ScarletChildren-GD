extends Sprite2D
class_name Black

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var map:TileMapLayer = get_parent()
@onready var cell_pos:Vector2i = map.local_to_map(position)
var visiable:bool = true

func tile_hide():
	anim.play("hide")
	await anim.animation_finished
	visiable = false
	pass
	
func tile_show():
	anim.play("show")
	await anim.animation_finished
	visiable = true

func _ready() -> void:
	print("初始化完成")
