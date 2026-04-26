extends CharacterBody2D

@onready var sprite_black = $Black_Character
@onready var sprite_white = $White_Character

const SPEED = 450.0
const RUNNING_SPEED = 600.0
const JUMP_VELOCITY = -800.0
const WALL_JUMP_VELOCITY = 400.0
const MAXLAYERNUM = 32
var wall_jump_lock = 0.0
var cframes = 8

func _ready() -> void:
	collision_layer = 3
	change_collision_layer(5)
	print("hey")

func _physics_process(delta: float) -> void:
	var is_running = false
	
	# Timer for the wall jump lock
	wall_jump_lock -= delta

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
		

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or cframes > 0:
			velocity.y = JUMP_VELOCITY
	
		# Wall jump
		elif is_on_wall():
			wallJump()
		
	
	if Input.is_action_pressed("sprint"):
		is_running = true
	else:
		is_running = false
	
	var direction := Input.get_axis("walk_left", "walk_right")
	if wall_jump_lock > 0:
		pass # keep the momentum during wall jump
	elif direction:
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
	if get_collision_mask_value(4):
		change_collision_layer(5)
	elif get_collision_mask_value(5):
		change_collision_layer(4)
func change_collision_layer(layerNum: int):
	collision_mask = 0
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(layerNum, true)
	
func die():
	print("death")
	get_tree().reload_current_scene()
	
func wallJump():
	var wall_normal = get_wall_normal()
	velocity.x = wall_normal.x * WALL_JUMP_VELOCITY
	velocity.y = JUMP_VELOCITY
	
	# locks Sideways movement during wall jump
	wall_jump_lock = 0.2
	cframes = 0
