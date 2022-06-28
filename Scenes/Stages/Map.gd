extends Node

var player_spawn = preload("res://Scenes/Characters/PlayerTemplate.tscn")
var enemy_spawn = preload("res://Scenes/Characters/Enemy.tscn")
var last_world_state = 0

var world_state_buffer = []
const interpolation_offset = 100

onready var game_server = get_node("/root/GameServer")
onready var other_players = $YSort/OtherPlayers
onready var enemies = $YSort/Enemies


func SpawnNewEnemy(enemy_id, enemy_dict):
	var new_enemy = enemy_spawn.instance()
	new_enemy.position = enemy_dict["EnemyLocation"]
	new_enemy.max_hp = enemy_dict["EnemyMaxHealth"]
	new_enemy.current_hp = enemy_dict["EnemyHealth"]
	new_enemy.type = enemy_dict["EnemyType"]
	new_enemy.state = enemy_dict["EnemyState"]
	new_enemy.name = str(enemy_id)
	enemies.add_child(new_enemy, true)


func DespawnEnemy(enemy_id):
	yield(get_tree().create_timer(0.2), "timeout")
	if enemies.has_node(str(enemy_id)):
		enemies.get_node(str(enemy_id)).queue_free()


func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not other_players.has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			other_players.add_child(new_player, true)


func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	if other_players.has_node(str(player_id)):
		other_players.get_node(str(player_id)).queue_free()


func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)


func _physics_process(_delta):
	var render_time = game_server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if other_players.has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					var animation_vector = world_state_buffer[2][player]["A"]
					other_players.get_node(str(player)).MovePlayer(new_position, animation_vector)
				else:
					print("spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
			for enemy in world_state_buffer[2]["Enemies"].keys():
				if not world_state_buffer[1]["Enemies"].has(enemy):
					continue
				if enemies.has_node(str(enemy)):
					var new_position = lerp(world_state_buffer[1]["Enemies"][enemy]["EnemyLocation"], world_state_buffer[2]["Enemies"][enemy]["EnemyLocation"], interpolation_factor)
					enemies.get_node(str(enemy)).MoveEnemy(new_position)
					enemies.get_node(str(enemy)).Health(world_state_buffer[1]["Enemies"][enemy]["EnemyHealth"])
				else:
					print("spawning enemy ", enemy)
					SpawnNewEnemy(enemy, world_state_buffer[2]["Enemies"][enemy])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"] - 1.00)
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if other_players.has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					var animation_vector = world_state_buffer[1][player]["A"]
					other_players.get_node(str(player)).MovePlayer(new_position, animation_vector)


func Clean():
	for i in other_players.get_child_count():
		if not world_state_buffer[2].keys().has(other_players.get_child(i).name):
			other_players.get_child(i).queue_free()
	for i in enemies.get_child_count():
		if not world_state_buffer[2]["Enemies"].keys().has(int(enemies.get_child(i).name)):
			enemies.get_child(i).queue_free()

