extends HBoxContainer

signal pressed

func _ready():
	add_to_group("levelbuttons")

func _on_Button_pressed():
	emit_signal("pressed")
