extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "192.168.0.19"
var port = 1910
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

var username
var password
var new_account = false

func _process(_delta):
	if self.custom_multiplayer == null:
		return
	if not self.custom_multiplayer.has_network_peer():
		return
	self.custom_multiplayer.poll()
	
func ConnectToServer(_username, _password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.use_dtls = true
	network.dtls_verify = false #Set to true when using signed certificate
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	self.custom_multiplayer = gateway_api
	self.custom_multiplayer.root_node = self
	self.custom_multiplayer.network_peer = network
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to connect to login server")
	print("Pop-up server offline or something")

func _OnConnectionSucceeded():
	print("Successfully connected to gateway")
	if new_account:
		RequestCreateAccount()
	else:
		RequestLogin()

func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""
	
remote func ReturnLoginRequest(results, token):
	print("results received")
	if results == true:
		Game.token = token
		Game.ConnectToServer()
	else:
		print("Please provide correct username and password")
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""

remote func ReturnCreateAccountRequest(results, message):
	print("results received")
	if results == true:
		print("Account created, please proceed with logging in")
	else:
		if message == 1:
			print("Couldn't create account, please try again")
		elif message == 2:
			print("The username already exist, please use a different username")
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
