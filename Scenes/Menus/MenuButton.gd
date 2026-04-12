extends Button

signal HoveredOver(button : Button)
signal ClickedButton(button : Button)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	HoveredOver.emit(self)
	
func _on_mouse_clicked() -> void:
	ClickedButton.emit(self)
