extends StaticBody2D
class_name Teleport

@onready var sprite = $DoorSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

# 被交互时
func interact():
	print("被交互了！")
	sprite.play("default") #门打开了
	self.set_collision_layer_value(1,false) #关闭门的碰撞体积


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("玩家进入了x区域")
	if body is Player:
		body.show_tip("西馆",self)


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("玩家离开了x区域")
	if body is Player:
		body.hide_tip()
