extends Node

func _unhandled_input(event):
	if event.is_action_pressed("ui_right"):
		print("attempting to login with correct info")
		Gateway.ConnectToServer("test2", "12121212", false)
	if event.is_action_pressed("ui_left"):
		print("attempting to login with incorrect info")
		Gateway.ConnectToServer("test2", "123", false)

	if event.is_action_pressed("ui_up"):
		Game.FetchAction("skill_damage", "Ice Spear", get_instance_id())
	if event.is_action_pressed("ui_down"):
		Game.FetchAction("get_data", "Player Stats")
		
	if event.is_action_pressed("ui_page_up"):
		Gateway.ConnectToServer("test2", "12121212", true)

func ReturnAction(action_name, value_name, return_value):
	print("receiving " + str(return_value) + " from server")
	match action_name:
		"skill_damage":
			match value_name:
				"Ice Spear":
					Game.ice_spear_damage = return_value
				_:
					return
		"get_data":
			match value_name:
				"Player Stats":
					Game.player_stats = return_value
		_:
			return
