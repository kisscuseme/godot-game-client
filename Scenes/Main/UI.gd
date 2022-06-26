extends CanvasLayer

onready var username = $Username
onready var password = $Password
onready var login_button = $Login
onready var create_button = $Create

signal login_button_pressed
signal create_button_pressed
signal stats_button_pressed

func _ready():
	username.text = "test1"
	password.text = "1111111"


func _on_Login_pressed():
	emit_signal("login_button_pressed")


func _on_Create_pressed():
	emit_signal("create_button_pressed")


func _on_Stats_pressed():
	emit_signal("stats_button_pressed")
