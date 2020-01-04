extends Area2D

var damage : int
var hp : int
var velocity : Vector2

#Initiate
func _ready():
	add_to_group("bullets")
	damage = 1
	hp = 1
	velocity = Vector2(0, -600)
	
	set_collision_layer_bit(3, true) #Anti-enemy layer
	set_collision_mask_bit(2, true) #Detect enemy layer

#Move
func _process(delta):
	position += velocity * delta

#Rotate bullet and direction
func aimDirection(angle):
	rotate(angle)
	velocity = Vector2(600*sin(angle),-600*cos(angle))

#Collision
func _on_Bullet_area_entered(area):
	if "damage" in area:
		hp -= area.damage
	if hp <= 0:
		queue_free()
	
	#Damage obstacle/enemy
	area.damagedBy(self)

#Delete after leaving screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()