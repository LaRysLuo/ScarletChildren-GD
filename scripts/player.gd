@tool
extends CharacterBody2D
class_name Player


const SPEED = 200.0
var dir = Vector2.DOWN # 面朝方向
var interactableNode:Interactable

@onready var label: Label = $Label
@onready var playerAnim = $AnimatedSprite2D2
@export var sprite : Texture2D:
	set(new):
		sprite = new
		if Engine.is_editor_hint():
			print("图片被更换，刷新一下")
			init_animation()
@export_range(0,10) var h : int
@export_range(0,10) var v : int

func _ready() -> void:
	if not Engine.is_editor_hint():
		init_animation()

func init_animation():
		if not Engine.is_editor_hint():
			playerAnim.sprite_frames = null
		var animation = init_character_animation()
		playerAnim.sprite_frames = animation

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() && GameManager.game_state == GameManager.GameState.Normal:
		var direction := Input.get_vector("left","right","up","down")
		if direction:
			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
		# 处理动画
		execute_animation(direction)
		move_and_slide()

func init_character_animation() -> SpriteFrames:
	#裁剪Texture
	var sprite_size = Vector2(32,48)
	var anim_list = []
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	for y in range(v):
		var str
		match  y:
			0: str = "move_down"
			1: str = "move_left"
			2: str = "move_right"
			3: str = "move_up"	
		frames.add_animation(str)
		frames.set_animation_loop(str,true)	
		var frame0 := get_tex(0,y,sprite_size)
		frames.add_frame(str,frame0)
		var frame1 := get_tex(1,y,sprite_size)
		
		frames.add_frame(str,frame1)
		var frame2 := get_tex(2,y,sprite_size)
		frames.add_frame(str,frame2)
		var frame4 := get_tex(1,y,sprite_size)
		frames.add_frame(str,frame4)
	for y in range(v):
		var str
		match  y:
			0: str = "idle_down"
			1: str = "idle_left"
			2: str = "idle_right"
			3: str = "idle_up"	
		frames.add_animation(str)
		frames.set_animation_loop(str,true)	
		var frame1 := get_tex(1,y,sprite_size)
		frames.add_frame(str,frame1)
	return frames
	
func get_tex(x:int,y:int,sprite_size:Vector2) -> AtlasTexture:
	var frame = AtlasTexture.new()
	frame.atlas = sprite
	frame.region = Rect2(Vector2(x,y) * sprite_size,sprite_size)
	return frame

func execute_animation(direction:Vector2):
	# 处理面朝方向
	if direction:
		dir = direction
		if direction == Vector2.DOWN:
			playerAnim.play("move_down")
		if direction == Vector2.LEFT:
			playerAnim.play("move_left")
		if direction == Vector2.RIGHT:
			playerAnim.play("move_right")
		if direction == Vector2.UP:
			playerAnim.play("move_up")
	else:
		match dir:
			Vector2.DOWN:	playerAnim.play("idle_down")
			Vector2.LEFT: playerAnim.play("idle_left")
			Vector2.RIGHT:playerAnim.play("idle_right")
			Vector2.UP: playerAnim.play("idle_up")

func show_tip(interact_name:String,_interactableNode:Interactable):
	label.text = interact_name
	label.show()
	interactableNode = _interactableNode
func hide_tip():
	interactableNode = null #清空可交互对象
	label.hide()

func _input(event: InputEvent) -> void:
	if GameManager.game_state != GameManager.GameState.Normal: return 
	if event.is_action_pressed("submit"):
		interact()

# 检测到玩家点击交互按键
func interact():
	#判断现在是否有可交互物体
	
	if interactableNode:
		interactableNode.interact()
	pass
