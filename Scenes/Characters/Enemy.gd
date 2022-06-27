extends KinematicBody2D

var max_hp
var current_hp
var state
var type
var health_bar

func _ready():
#	max_hp = 500
#	current_hp = 500
#	state = "Idle"
#	position = Vector2(200,200)
	var percentage_hp = int((float(current_hp) / max_hp) * 100)
	health_bar = percentage_hp
	if state == "Idle":
		pass
	elif state == "Dead":
		OnDeath()


func MoveEnemy(new_position):
	position = new_position


func Health(health):
	if health != current_hp:
		current_hp = health
		HeathBarUpdate()
		if current_hp <= 0:
			OnDeath()
		else:
			print("attack to ", name)


func HeathBarUpdate():
	var percentage_hp = int((float(current_hp) / max_hp) * 100)
	health_bar = percentage_hp
	print("Health Bar: ", health_bar, "%")
	

func OnDeath():
	modulate = Color("#555555")
	z_index = -1
	yield(get_tree().create_timer(0.2), "timeout")
	$CollisionShape2D.set_deferred("disabled", true)
