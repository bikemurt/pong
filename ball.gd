class_name Ball
extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $"../RightPaddleArea2D/CollisionShape2D"
@onready var ball_collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var left_score_label: Label = $"../LeftScoreLabel"
@onready var right_score_label: Label = $"../RightScoreLabel"

@export var initial_speed := 400.0
@export var fast_speed := 800.0
@export var margin := 3
@export var steepness_factor := 1.0

var speed := 0.0
var start_speed := true
var direction := Vector2(1,0)
var paddle_height := 0.0
var ball_radius := 0.0
static var left_score := 0
static var right_score := 0

var rng := RandomNumberGenerator.new()
func _ready() -> void:
	var s: RectangleShape2D = collision_shape_2d.shape
	paddle_height = s.size.y
	
	var ball_s: CircleShape2D = ball_collision_shape_2d.shape
	ball_radius = ball_s.radius
	
	reset_ball()

func reset_ball() -> void:
	position.x = Pong.w_width / 2.0
	position.y = Pong.w_height / 2.0
	
	var random_angle := rng.randf_range(-45, 45)
	direction = Vector2(1,0)
	direction = direction.rotated(deg_to_rad(random_angle))
	
	var random_direction := rng.randi_range(1,10)
	if random_direction >= 6:
		direction.x *= -1
	
	speed = initial_speed
	start_speed = true

func _process(delta: float) -> void:
	if not Pong.pause:
		if (position.y - ball_radius <= margin) or \
			position.y + ball_radius >= Pong.w_height - margin:
			direction.y *= -1
		
		position += speed * direction * delta
		
		if position.x - ball_radius <= margin:
			right_score += 1
			reset_ball()
		
		if position.x + ball_radius >= Pong.w_width - margin:
			left_score += 1
			reset_ball()
	
	left_score_label.text = str(left_score)
	right_score_label.text = str(right_score)
	
func _on_area_entered(area: Area2D) -> void:
	if "Paddle" in area.name:
		if start_speed:
			speed = fast_speed
			start_speed = false
		
		# compare y positions
		var delta_y := area.position.y - position.y
		var deviation_percent := delta_y / (paddle_height/2.0)
		
		var sign_x: int = sign(direction.x)
		
		var new_direction := Vector2(1, 0)
		new_direction = new_direction.rotated(- deviation_percent * steepness_factor)
		new_direction.x = -1 * sign_x
		
		direction = new_direction
