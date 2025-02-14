extends Node

var setup = preload("res://phases/setup.tscn")
var phase1 = preload("res://phases/phase_1_storm.tscn")
var phase2 = preload("res://phases/phase_2_spice.tscn")
var phase3 = preload("res://phases/phase_3.tscn")
var phase4 = preload("res://phases/phase_4.tscn")
var phase5 = preload("res://phases/phase_5.tscn")
var phase6 = preload("res://phases/phase_6.tscn")
var phase7 = preload("res://phases/phase_7.tscn")
var phase8 = preload("res://phases/phase_8.tscn")
var phase9 = preload("res://phases/phase_9.tscn")
var phase = "none"
var instance
var phaseInfoRequest
var mapSpiceRequest
var requestCompleted: bool = true
@onready var timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	instance = phase1.instantiate()
	add_child(instance)
	# GET PHASE INFO REQUEST
	phaseInfoRequest = HTTPRequest.new()
	phaseInfoRequest.connect("request_completed", _on_phase_info_request_completed)
	add_child(phaseInfoRequest)
	var error = phaseInfoRequest.request(PlayerData.api_url + "get_phase_info/" + PlayerData.username)
	if error != OK:
		push_error("ERROR: HTTP: GET_PHASE_INFO")
	mapSpiceRequest = HTTPRequest.new()
	mapSpiceRequest.connect("request_completed", _on_map_spice_request_completed)
	add_child(mapSpiceRequest)
	#error = mapSpiceRequest.request(PlayerData.api_url + "get_map_spice")
	#if error != OK:
		#push_error("ERROR: HTTP: GET_PHASE_INFO")
	 # Configure and start the timer#############################################
	timer.wait_time = 1  # 1s milliseconds
	timer.connect("timeout", _on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if (PlayerData.requestCompleted):
		pass;
		var error = phaseInfoRequest.request(PlayerData.api_url + "get_phase_info/" + PlayerData.username)
		if error != OK:
			push_error("ERROR: HTTP: GET_PHASE_INFO")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (phase != GameData.phase):
		instance.queue_free();
		phase = GameData.phase
		print(phase)
		if (phase == "Set-up"):
			instance = setup.instantiate()
			add_child(instance)
		if (phase == "Storm"):
			instance = phase1.instantiate()
			add_child(instance)
		if (phase == "Spice Blow and Nexus"):
			PlayerData.lastSpice = PlayerData.spice	
			instance = phase2.instantiate()
			add_child(instance)
		if (phase == "Charity Phase"):
			# to check if our spice changed
			instance = phase3.instantiate()
			add_child(instance)
		if (phase == "Bidding"):
			instance = phase4.instantiate()
			add_child(instance)
		if (phase == "Revival"):
			instance = phase5.instantiate()
			add_child(instance)
		if (phase == "Shipment And Movement"):
			instance = phase6.instantiate()
			add_child(instance)
		if (phase == "Battle"):
			PlayerData.lastSpice = PlayerData.spice	
			instance = phase7.instantiate()
			add_child(instance)
		if (phase == "Spice Collection"):
			instance = phase8.instantiate()
			add_child(instance)
		if (phase == "Mentat Pause"):
			instance = phase9.instantiate()
			add_child(instance)

func _on_phase_info_request_completed(_result, _response_code, _headers, body):
	var response_string = body.get_string_from_utf8()
	var json = JSON.parse_string(response_string)
	if (json == null):
		push_error("ERROR: NULL RESPONSE FROM SERVER")
	else:
		#print("Got phase info")
		#GameData.roundd = json["round"]
		GameData.phase = json["name"]
		GameData.phaseMoment = json["moment"]
		GameData.roundd = json["round"]
		GameData.playersToInput = json["playersToInput"]
		#print(GameData.playersToInput)

func _on_map_spice_request_completed(_result, _response_code, _headers, body):
	var response_string = body.get_string_from_utf8()
	var json = JSON.parse_string(response_string)
	if (json == null):
		push_error("ERROR: NULL RESPONSE FROM SERVER")
	else:
		print("Got map spice info")
		MapData.territorySpice = json;
