extends GameClientData
class_name GameClientMethods

onready var main = get_node("/root/Main")
onready var map = main.get_node("Map")
onready var player = map.get_node("YSort/Player")
onready var enemies = map.get_node("YSort/Enemies")
onready var other_players = map.get_node("YSort/OtherPlayers")

func FetchAction(action_name, value_name, requester = null):
	rpc_id(1, "FetchAction", action_name, value_name, requester)


remote func ReturnAction(action_name, value_name, return_value, requester = null):
	if requester:
		instance_from_id(requester).ReturnAction(action_name, value_name, return_value)
	else:
		main.ReturnAction(action_name, value_name, return_value)


remote func FetchToken():
	rpc_id(1, "ReturnToken", token)


remote func ReturnTokenVerificationResults(result):
	if result == true:
		print("Successful token verification")
		player.set_physics_process(true)
	else:
		print("Login failed, please try again")


func SendPlayerState(player_state):
#	print(player_state)
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)


remote func ReceiveWorldState(world_state):
	map.UpdateWorldState(world_state)
#	print("Worldstate: ", world_state["T"], " && client_clock: ", client_clock)


remote func SpawnNewPlayer(player_id, spawn_position):
	map.SpawnNewPlayer(player_id, spawn_position)


remote func DespawnPlayer(player_id):
	map.DespawnPlayer(player_id)


func SendAttack(position, animation_vector, a_rotation, a_position, a_direction):
	rpc_id(1, "Attack", position, animation_vector, client_clock, a_rotation, a_position, a_direction)


remote func ReceiveAttack(position, animation_vector, spawn_time, player_id):
	if player_id == get_tree().get_network_unique_id():
		pass
	else:
		other_players.get_node(str(player_id)).attack_dict[spawn_time] = {"Position": position, "AnimationVector": animation_vector}


remote func DespawnEnemy(enemy_id):
	map.DespawnEnemy(enemy_id)


remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency


func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())


remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
#		print("New Latency ", latency)
#		print("Delta Latency ", delta_latency)
		latency_array.clear()
