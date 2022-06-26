extends KinematicBody2D

var mouse = false
const key_speed = 200
const max_speed = 300
var speed = 0
var acceleration = 900
var destination = Vector2.ZERO
var movement = Vector2.ZERO
var animation_vector = Vector2.ZERO
var motion
var player_state
var moving = false
var attacking = false

var icespear = preload("res://Scenes/Skill/IceSpear.tscn")

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

func _ready():
	position = Vector2(100,100)
	if not Game.skip_auth:
		set_physics_process(false)


func _unhandled_input(event):
	if event.is_action_pressed('Mouse_Move'):
		mouse = true
		moving = true
		destination = get_global_mouse_position()
	elif event.is_action_pressed('Mouse_Attack'):
		mouse = true
		moving = false
		attacking = true
		Attack()

func _physics_process(delta):
	motion = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		mouse = false
		motion += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		mouse = false
		motion += Vector2(1, 0)
	if Input.is_action_pressed("ui_up"):
		mouse = false
		motion += Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		mouse = false
		motion += Vector2(0, 1)

	MovementLoop(delta)
	if get_tree().get_network_connected_peers():
		DefinePlayerState()


func MovementLoop(delta):
	if mouse:
		if not moving or attacking:
			speed = 0
		else:
			speed += acceleration * delta
			if speed > max_speed:
				speed = max_speed
			movement = position.direction_to(destination) * speed
			if position.distance_to(destination) > 10:
				movement = move_and_slide(movement)
				animation_vector = movement.normalized()
				animation_tree.set('parameters/Walk/blend_position', animation_vector)
				animation_tree.set('parameters/Idle/blend_position', animation_vector)
#				animation_mode.travel("Walk")
			else:
				mouse = false
				moving = false
#				animation_mode.travel("Idle")
	else:
		move_and_slide(motion * key_speed)


func DefinePlayerState():
	player_state = {"T": Game.client_clock, "P": global_position, "A": animation_vector}
	Game.SendPlayerState(player_state)


func Attack():
	animation_vector = position.direction_to(get_global_mouse_position()).normalized()
	animation_tree.set('parameters/Cast/blend_position', animation_vector)
	animation_tree.set('parameters/Idle/blend_position', animation_vector)
	Game.SendAttack(position, animation_vector)
	$TurnAxis.rotation = get_angle_to(get_global_mouse_position())
	var icespear_instance = icespear.instance()
	icespear_instance.impulse_rotation = get_angle_to(get_global_mouse_position())
	icespear_instance.position = $TurnAxis/Position2D.global_position
	icespear_instance.direction = $TurnAxis/Position2D.global_position.direction_to(get_global_mouse_position())
#	animation_mode.travel("Cast")
	yield(get_tree().create_timer(0.2), "timeout")
	get_parent().add_child(icespear_instance)
	yield(get_tree().create_timer(0.2), "timeout")
	attacking = false
