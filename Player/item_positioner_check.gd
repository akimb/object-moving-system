extends Marker3D

signal item_in_hand(is_holding)

var is_holding : bool = false

func _ready() -> void:
	item_in_hand.connect(change_holding)

func change_holding(object_exists: bool) -> void:
	is_holding = object_exists
