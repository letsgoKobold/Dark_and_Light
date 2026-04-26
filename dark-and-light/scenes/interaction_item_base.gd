extends Area2D

enum effects{
	SPEED,
	JUMP_BOOST,
	TEXT_LABEL
}

@export var effect: effects = effects.SPEED
@export var effect_value = "placeholder" 
@export var time_value: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	body.do_effect(effect, effect_value, time_value)
