extends CharacterBody2D

@onready var sprite_black = $Black_Character
@onready var sprite_white = $White_Character

const SPEED = 450.0
const RUNNING_SPEED = 600.0
const JUMP_VELOCITY = -800.0
const MAXLAYERNUM = 32
var cframes = 8

func _ready() -> void:
	collision_layer = 3
	change_collision_layer(5)
	print("hey")

func _physics_process(delta: float) -> void:
	var is_running = false
	

	if not is_on_floor():
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		elif !Input.is_action_pressed("jump"):
			velocity += get_gravity() * delta * 15
		else:
			velocity += get_gravity() * delta
		cframes -= 1
		print(cframes)
	else:
		cframes = 8

	if Input.is_action_just_pressed("jump") and (is_on_floor() or cframes > 0):
		AudioManager.play_one_shot("Jump")
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		is_running = true
	else:
		is_running = false
	
	var direction := Input.get_axis("walk_left", "walk_right")
	if direction:
		if is_running:
			velocity.x = direction * RUNNING_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("colour_switch"):
		switch_layer_collision()
		switch_sprites()
	
	move_and_slide()
	
	update_animation(direction, is_running)
	
	pass

func switch_sprites():
	if sprite_black.z_index == 1:
		sprite_black.z_index = 0
		sprite_white.z_index = 1
	else:
		sprite_black.z_index = 1
		sprite_white.z_index = 0
func update_animation(direction, is_running):
	if direction < 0:
		sprite_black.flip_h = true
		sprite_white.flip_h = true
	if direction > 0:
		sprite_black.flip_h = false
		sprite_white.flip_h = false
	if not is_on_floor():
		if velocity.y < 0:			
			sprite_black.play("jump")
			sprite_white.play("jump")
		else:
			sprite_black.play("fall")
			sprite_white.play("fall")
	else:
		if direction == 0:
			sprite_black.play("idle")
			sprite_white.play("idle")
		else:
			if is_running:
				sprite_black.play("run")
				sprite_white.play("run")
			else:	
				sprite_black.play("walk")
				sprite_white.play("walk")
		animation_sync()
func animation_sync():
	sprite_white.frame = sprite_black.frame
	sprite_white.frame_progress = sprite_black.frame_progress

func switch_layer_collision():
	AudioManager.play_one_shot("Switch")
	if get_collision_mask_value(4):
		AudioManager.set_global_parameter("Color", 0)
		change_collision_layer(5)
	elif get_collision_mask_value(5):
		AudioManager.set_global_parameter("Color", 1)
		change_collision_layer(4)
func change_collision_layer(layerNum: int):
	collision_mask = 0
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(layerNum, true)
