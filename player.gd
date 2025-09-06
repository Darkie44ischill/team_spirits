extends CharacterBody2D

const speed = 1000
const dash_speed = 3000

var dir: Vector2
var dashing = false
var can_dash = true
var attacking = false  # <-- NEW

@export var max_health := 5
var health := max_health

signal health_changed(new_health)

@onready var sprite = $Sprite2D
@onready var attack_sprite = $AttackSprite    # <-- AnimatedSprite2D with your attack sheet
@onready var attack_area = $AttackArea        # <-- Area2D with CollisionShape2D

func _ready() -> void:
	emit_signal("health_changed", health)
	attack_sprite.hide()
	attack_area.monitoring = false

func _physics_process(delta: float) -> void:
	# prevent movement while attacking
	if attacking:
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		$dash_timer.start()
		$dash_again_timer.start()
	
	var direction1 := Input.get_axis("left", "right")
	var direction2 := Input.get_axis("up", "down")
	
	if direction1 == 1:
		sprite.flip_h = false
	elif direction1 == -1:
		sprite.flip_h = true
	
	if direction1:
		if dashing:
			velocity.x = dash_speed * direction1
		else:
			velocity.x = speed * direction1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	if direction2:
		if dashing:
			velocity.y = dash_speed * direction2
		else:
			velocity.y = speed * direction2
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	# Attack input
	if Input.is_action_just_pressed("attack") and not attacking:
		start_attack()

	move_and_slide()

# ---- ATTACK SYSTEM ----
func start_attack() -> void:
	attacking = true
	sprite.hide()
	attack_sprite.show()
	attack_sprite.play("attack")
	attack_area.monitoring = true
	
	await attack_sprite.animation_finished
	
	attack_area.monitoring = false
	attack_sprite.hide()
	sprite.show()
	attacking = false

func _on_AttackArea_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(1)

# ---- HEALTH SYSTEM ----
func take_damage(amount: int = 1) -> void:
	health = max(health - amount, 0)
	emit_signal("health_changed", health)

func heal(amount: int = 1) -> void:
	health = min(health + amount, max_health)
	emit_signal("health_changed", health)

# ---- DASH TIMERS ----
func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_again_timer_timeout() -> void:
	can_dash = true
