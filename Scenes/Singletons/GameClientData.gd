extends Node
class_name GameClientData

var token

var ice_spear_damage setget SetIceSpearDamage
var player_stats setget SetPlayerStats

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

var skip_auth = false

func SetIceSpearDamage(s_damage):
	ice_spear_damage = s_damage


func SetPlayerStats(s_stats):
	player_stats = s_stats
