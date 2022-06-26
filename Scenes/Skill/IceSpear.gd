extends RigidBody2D

onready var animation_tree = $AnimationTree

var projectile_speed = 600
var life_time = 3
var direction
var impulse_rotation
var damage setget SetDamage
var original = true


func _ready():
	Game.FetchAction("skill_damage", "Ice Spear", get_instance_id())
	animation_tree.set('parameters/blend_position', direction)
	apply_impulse(Vector2.ZERO, Vector2(projectile_speed, 0).rotated(impulse_rotation))
	SelfDestruct()


func ReturnAction(action_name, value_name, return_value):
	print("receiving " + str(return_value) + " from server")
	SetDamage(return_value)


func SetDamage(s_damage):
	damage = s_damage


func SelfDestruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()


func _on_IceSpear_body_entered(body):
	if body.is_in_group("Enemies") and original:
		body.OnHit(damage)
	self.hide()
