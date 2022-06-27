extends Node

onready var UI = $UI

func _on_UI_create_button_pressed():
	Gateway.ConnectToServer(UI.username.text, UI.password.text, true)


func _on_UI_login_button_pressed():
	Gateway.ConnectToServer(UI.username.text, UI.password.text, false)


func _on_UI_stats_button_pressed():
	Game.FetchAction("get_data", "Player Stats")


func ReturnAction(action_name, value_name, return_value):
	print("receiving " + str(return_value) + " from server")
	match action_name:
		"get_data":
			match value_name:
				"Player Stats":
					Game.player_stats = return_value
		_:
			return

func Attack(damage):
	randomize()
	var enemies = get_node("/root/Main/Map/YSort/Enemies")
	if enemies.get_child_count() > 0:
		var enemy = enemies.get_child(randi() % enemies.get_child_count())
		enemy.OnHit(damage)
