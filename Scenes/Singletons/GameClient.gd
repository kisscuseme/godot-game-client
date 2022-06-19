extends GameClientMethods

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909

func _ready():
	pass
#	ConnectToServer()

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().network_peer = network
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to connect")


func _OnConnectionSucceeded():
	print("Successfully connected")

