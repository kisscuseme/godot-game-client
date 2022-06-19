extends GameClientData
class_name GameClientMethods

func FetchAction(action_name, value_name, requester = null):
	rpc_id(1, "FetchAction", action_name, value_name, requester)


remote func ReturnAction(action_name, value_name, return_value, requester = null):
	if requester:
		instance_from_id(requester).ReturnAction(action_name, value_name, return_value)
	else:
		self.get_node("/root/Main").ReturnAction(action_name, value_name, return_value)


remote func FetchToken():
	rpc_id(1, "ReturnToken", token)


remote func ReturnTokenVerificationResults(result):
	if result == true:
		print("Successful token verification")
	else:
		print("Login failed, please try again")
