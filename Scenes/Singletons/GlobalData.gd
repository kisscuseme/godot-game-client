extends Node

var server_info = LoadDataFromJSON("GlobalData")

func LoadDataFromJSON(path):
	var data_file = File.new()
	data_file.open("res://Data/"+path+".json", File.READ)
	var data_json = JSON.parse(data_file.get_as_text())
	data_file.close()
	return data_json.result
