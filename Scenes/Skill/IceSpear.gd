extends RigidBody2D

onready var animation_tree = $AnimationTree

var projectile_speed = 600
var life_time = 3
var direction
var impulse_rotation


func _ready():
	$CollisionShape2D.rotation = impulse_rotation
	animation_tree.set('parameters/blend_position', direction)
	apply_impulse(Vector2.ZERO, Vector2(projectile_speed, 0).rotated(impulse_rotation))
	SelfDestruct()


func SelfDestruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()


func _on_IceSpear_body_entered(body):
	$CollisionShape2D.set_deferred("disabled", true)
	self.hide()
