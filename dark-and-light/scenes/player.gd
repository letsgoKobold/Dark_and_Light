extends CharacterBody2D

@onready var sprite_black = $Black_Character
@onready var sprite_white = $White_Character

@onready var speed_timer = $SpeedTimer
@onready var jump_timer = $JumpTimer
@onready var label_timer = $LabelTimer

@onready var label_tutorial = $TutorialLabels

const SPEED = 450.0
const RUNNING_SPEED = 600.0
const JUMP_VELOCITY = -800.0
const MAXLAYERNUM = 32
var speed = 450.0
var running_speed = 600.0
var jump_velocity = -800.0
var cframes = 8

func _ready() -> void:
	add_to_group("player")
	collision_layer = 3
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(5, true)

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
	else:
		cframes = 8

	if Input.is_action_just_pressed("jump") and (is_on_floor() or cframes > 0):
		AudioManager.play_one_shot("Jump")
		velocity.y = jump_velocity
	
	if Input.is_action_pressed("sprint"):
		is_running = true
	else:
		is_running = false
	
	var direction := Input.get_axis("walk_left", "walk_right")
	if direction:
		if is_running:
			velocity.x = direction * running_speed
		else:
			velocity.x = direction * speed
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
		set_collision_mask_value(4, false)
		set_collision_mask_value(5, true)
		AudioManager.set_global_parameter("Color", 0)
	elif get_collision_mask_value(5):
		set_collision_mask_value(5, false)
		set_collision_mask_value(4, true)
		AudioManager.set_global_parameter("Color", 1)


func do_effect(effect, value, time_value):
	match effect:
		0: #speed
			speed_timer.wait_time = time_value
			speed_timer.start()
			if speed == SPEED:
				speed += float(value)
				running_speed += (float(value) * 1.5)
		1: #jump boost
			jump_timer.wait_time = time_value
			jump_timer.start()
			if jump_velocity == JUMP_VELOCITY:
				jump_velocity -= float(value)
		2: #show text
			label_timer.wait_time = 10.0
			label_timer.start()
			label_tutorial.text = value
			label_tutorial.show()

func _on_speed_timer_timeout() -> void:
	speed = SPEED
	running_speed = RUNNING_SPEED

func _on_jump_timer_timeout() -> void:
	jump_velocity = JUMP_VELOCITY

func _on_label_timer_timeout() -> void:
	label_tutorial.hide()
