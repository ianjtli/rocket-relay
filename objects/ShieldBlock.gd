extends Area2D

var damage : int
var rotationMultiplier : float
var hp : int

func _ready():
	add_to_group("bullets")
	damage = 1
	hp = 1
	rotationMultiplier = 2.8

#Move
func _process(delta):
	rotate(delta * 5)
	position += rotationMultiplier * delta * Vector2(position.y, -position.x)

func _on_ShieldBlock_area_entered(area):
	if "damage" in area:
		hp -= area.damage
	if hp <= 0:
		queue_free()
	
	#Damage obstacle/enemy
	area.damagedBy(self)
