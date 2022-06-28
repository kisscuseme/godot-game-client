extends GameClientMethods

var network = NetworkedMultiplayerENet.new()
var ip = GlobalData.server_info["GAME_SERVER_1"]["IP"]
var port = GlobalData.server_info["GAME_SERVER_1"]["PORT"]

onready var UI = $UI

func _ready():
	if skip_auth:
		ConnectToServer()


func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00


func _OnConnectionFailed():
	print("Failed to connect")


func _OnConnectionSucceeded():
	print("Successfully connected")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)
	$Map.Clean()
	for i in $UI.get_child_count():
		if i != 0:
			$UI.get_child(i).visible = false


func ConnectToServer():
	network.create_client(ip, port)
	get_tree().network_peer = network
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _on_UI_create_button_pressed():
	Gateway.ConnectToServer(UI.username.text, UI.password.text, true)


func _on_UI_login_button_pressed():
	Gateway.ConnectToServer(UI.username.text, UI.password.text, false)


func _on_UI_stats_button_pressed():
	FetchAction("get_data", "Player Stats")


func Attack(damage):
	randomize()
	var enemies = $Map/YSort/Enemies
	if enemies.get_child_count() > 0:
		var enemy = enemies.get_child(randi() % enemies.get_child_count())
		enemy.OnHit(damage)
