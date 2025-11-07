extends CharacterBody2D


@export_enum("blinky", "pinky", "inky", "clyde") var ghost_type: String = "blinky"
@export var speed: float = 80.0

@onready var body: Sprite2D = $Body
@onready var eyes: Sprite2D = $Eyes
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var pacman: CharacterBody2D

func _ready(): 
	pacman = get_tree().get_first_node_in_group("pacman")
	apply_color()
	$AnimationPlayer.play("walk")
	
	agent.radius = 12.0  # Adjust this until it stops clipping
	agent.path_desired_distance = 2.0  # keeps a small buffer from walls
	collision_shape.shape.radius = 10.0 

func _physics_process(delta: float):
	if pacman:
		agent.target_position = get_target_position()
	
	if not agent.is_navigation_finished():
		var next_point = agent.get_next_path_position()
		var to_next = next_point - global_position
		if to_next.length() > 0.1:
				var dir = to_next.normalized()
				velocity = dir * speed
				move_and_slide()
				update_eyes(dir)
				

func get_target_position() -> Vector2:
	match ghost_type:
		"blinky":
			#Chase Pac-Man
			return pacman.global_position
		
		"pinky":
			#Aim 4 tiles ahead of PacMan
			var ahead = pacman.velocity.normalized() * 32 * 4
			return pacman.global_position + ahead
		
		"inky":
			var blinky = get_tree().get_nodes_in_group("ghosts").filter(func(g): return g.ghost_type == "blinky")
			if blinky.size() > 0:
				var blinky_pos = blinky[0].global_position
				var ahead = pacman.global_position + pacman.velocity.normalized() * 32 * 2
				return blinky_pos + (ahead - blinky_pos) * 2
			return pacman.global_position
			
		"clyde":
			var dist = global_position.distance_to(pacman.global_position)
			if dist > 96: 
				return pacman.global_position
			else:
				return Vector2(16,16)
			
		_:
			return pacman.global_position



func apply_color():
	match ghost_type:
		"blinky": body.modulate = Color(1,0,0) #red
		"pinky": body.modulate = Color(1, 0.6, 0.8) #pink
		"inky": body.modulate = Color(0,1,1) #cyan
		"clyde": body.modulate = Color(1, 0.5, 0) #orange

func update_eyes(dir: Vector2):
	if dir.length() < 0.1:
		return
	eyes.position = dir.normalized() * 4.0
