extends CharacterBody2D 

const SPEED = 1000

enum State { IDLE, PURSUE }
var current_state = State.IDLE

@export var player: Node 
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D 
@onready var update_timer := $UpdateTimer as Timer

func _ready() -> void: 
	update_timer.start()
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()

		State.PURSUE:
			if nav_agent.is_navigation_finished():
				velocity = Vector2.ZERO
			else:
				var next_point = nav_agent.get_next_path_position()
				var dir = (next_point - global_position).normalized()
				velocity = velocity.lerp(dir * SPEED, 0.1)
				move_and_slide()




func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == player:
		current_state = State.PURSUE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		current_state = State.IDLE





func _on_update_timer_timeout() -> void:
	if player and current_state == State.PURSUE:
		nav_agent.set_target_position(player.global_position)


func _on_area_2d_body_entered(body: Node2D) -> void:
		if body.name == "Player":
			body.take_damage(1)



var health = 1

func take_damage(amount: int = 1) -> void:
	queue_free()  # instantly delete enemy
