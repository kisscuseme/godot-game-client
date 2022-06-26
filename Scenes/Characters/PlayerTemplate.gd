extends KinematicBody2D

var icespear = preload("res://Scenes/Skill/IceSpear.tscn")
var attack_dict = {}
var state = "Idle"

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")


func _physics_process(delta):
	if not attack_dict == {}:
		Attack()


func MovePlayer(new_position, animation_vector):
	if not state == "Attack":
		animation_tree.set('parameters/Walk/blend_position', animation_vector)
		animation_tree.set('parameters/Idle/blend_position', animation_vector)
		if position == new_position:
			state = "Idle"
#			animation_mode.travel("Idle")
		else:
			state = "Walk"
#			animation_mode.travel("Walk")
			position = new_position


func Attack():
	for attack in attack_dict.keys():
		if attack <= Game.client_clock and attack_dict.has(attack):
			state = "Attack"
			animation_tree.set('parameters/Cast/blend_position', attack_dict[attack]["AnimationVector"])
#			animation_mode.travel("Cast")
			position = attack_dict[attack]["Position"]
			$TurnAxis.rotation = get_angle_to(position + attack_dict[attack]["AnimationVector"])
			var icespear_instance = icespear.instance()
			icespear_instance.impulse_rotation = get_angle_to(position + attack_dict[attack]["AnimationVector"])
			icespear_instance.position = $TurnAxis/Position2D.global_position
			icespear_instance.direction = attack_dict[attack]["AnimationVector"]
			icespear_instance.original = false
			attack_dict.erase(attack)
			yield(get_tree().create_timer(0.2), "timeout")
			get_parent().add_child(icespear_instance)
			yield(get_tree().create_timer(0.2), "timeout")
			state = "Idle"
