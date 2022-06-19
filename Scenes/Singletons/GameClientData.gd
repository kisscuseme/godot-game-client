extends Node
class_name GameClientData

var token

var ice_spear_damage setget SetIceSpearDamage
var player_stats setget SetPlayerStats

func SetIceSpearDamage(s_damage):
	ice_spear_damage = s_damage


func SetPlayerStats(s_stats):
	player_stats = s_stats
