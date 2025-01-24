extends Sprite2D
class_name Lighting

@export var light_texture:Texture2D

var light_image:Image

var fog_image:Image
var fog_texture:ImageTexture


var player:Player_v1:
	get():return GameManager.player



func _ready() -> void:
	if !visible:return ## 如果透明度为false，不启动
	var base_sprite =  _get_sprite()
	var size = base_sprite.texture.get_size()
	
	fog_image = Image.create(size.x,size.y,false,Image.FORMAT_RGBA8)
	fog_image.fill(Color.WHITE)
	fog_texture = ImageTexture.create_from_image(fog_image)
	texture = fog_texture
	
	light_image = light_texture.get_image()
	position = base_sprite.position
	
	#player.start_pos_changed.connect(_update_fog)
	_update_fog()
	
func _process(delta: float) -> void:
	if !visible:return ## 如果透明度为false，不启动
	_update_fog()
	
	
func _update_fog():
	
	## 先擦除之前的迷雾
	fog_image.fill(Color.WHITE)
	var player_pos = player.global_position
	player_pos -=Vector2(light_image.get_size())/ 2
	fog_image.blend_rect(light_image,Rect2i(Vector2.ZERO,light_image.get_size()),player_pos)
	fog_texture.update(fog_image)


func _get_light_positions():
	return get_tree().get_nodes_in_group("light").map(
		func(light:Node2D):
			return light.get_global_transform_with_canvas().origin
	)

func _get_sprite() -> Sprite2D:
	return get_node("../0")
