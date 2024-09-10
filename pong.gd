class_name Pong
extends Node2D

enum DIFFICULTY { EASY, MEDIUM, HARD }

@onready var right_paddle_area_2d: Area2D = $RightPaddleArea2D
@onready var collision_shape_2d: CollisionShape2D = $RightPaddleArea2D/CollisionShape2D
@onready var left_paddle_area_2d: Area2D = $LeftPaddleArea2D
@onready var ball_area_2d: Area2D = $BallArea2D
@onready var pause_control: Control = $PauseControl
@onready var check_box: CheckBox = $PauseControl/CheckBox
@onready var option_button: OptionButton = $PauseControl/OptionButton
@onready var winner_label: Label = $PauseControl/WinnerLabel
@onready var line_edit: LineEdit = $PauseControl/LineEdit

@export var start_x_pos := 70.0
@export var two_player := false
@export var max_score := 5

static var w_width := 1152.0
static var w_height := 648.0
static var pause := true

var top_limit := 0.0
var bottom_limit := 0.0

var challenge := DIFFICULTY.HARD

var ball_y_positions := []
var count_min := 0
var count_max := 0
var next_count_max := 0
var rng := RandomNumberGenerator.new()

var run_time := 0.0
var game_over := false

func set_level() -> void:
	if challenge == DIFFICULTY.EASY:
		count_min = 15
		count_max = 30
	elif challenge == DIFFICULTY.MEDIUM:
		count_min = 10
		count_max = 20
	elif challenge == DIFFICULTY.HARD:
		count_min = 5
		count_max = 15
	
	next_count_max = rng.randi_range(count_min, count_max)

func reset() -> void:
	right_paddle_area_2d.position = Vector2(w_width - start_x_pos, w_height/2.0)
	left_paddle_area_2d.position = Vector2(start_x_pos, w_height/2.0)

func _ready() -> void:
	reset()
	set_level()
	
	var s: RectangleShape2D = collision_shape_2d.shape
	
	top_limit = 0.0 + s.size.y/2.0
	bottom_limit = w_height - s.size.y/2.0

var button_index := 0
func _input(event: InputEvent) -> void:
	
	if two_player:
		if event is InputEventMouseButton:
			var mb_event: InputEventMouseButton = event
			button_index = mb_event.button_index
		
	if event is InputEventMouseMotion and not pause:
		var mm_event: InputEventMouseMotion = event
		if two_player:
			if button_index == 1:
				var new_pos := left_paddle_area_2d.position.y + mm_event.relative.y
				left_paddle_area_2d.position.y = clampf(new_pos, top_limit, bottom_limit)
			elif button_index == 2:
				var new_pos := right_paddle_area_2d.position.y + mm_event.relative.y
				right_paddle_area_2d.position.y = clampf(new_pos, top_limit, bottom_limit)
		else:
			var new_pos := right_paddle_area_2d.position.y + mm_event.relative.y
			right_paddle_area_2d.position.y = clampf(new_pos, top_limit, bottom_limit)
		

func _process(delta: float) -> void:
	game_over = Ball.left_score >= max_score or Ball.right_score >= max_score
	if Input.is_action_just_pressed("quit") or game_over:
		_pause()
		
	if not pause and not two_player:
		ball_y_positions.push_front(ball_area_2d.position.y)
		if len(ball_y_positions) >= next_count_max:
			ball_y_positions.pop_back()
			
		run_time += delta
		if run_time >= 1.0:
			set_level()
		
		var ball_y_avg := 0.0
		for pos in ball_y_positions:
			ball_y_avg += pos
		ball_y_avg /= len(ball_y_positions)
		
		left_paddle_area_2d.position.y = ball_y_avg

func _pause() -> void:
	pause_control.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause = true
	
	if Ball.left_score >= max_score:
		winner_label.text = "Left Player Won!"
	elif Ball.right_score >= max_score:
		winner_label.text = "Right Player Won!"
	if game_over:
		winner_label.show()
	else:
		winner_label.hide()

func resume() -> void:
	if game_over:
		Ball.left_score = 0
		Ball.right_score = 0
	
	pause_control.hide()
	two_player = check_box.button_pressed
	challenge = option_button.selected as DIFFICULTY
	max_score = int(line_edit.text)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause = false

func _on_button_pressed() -> void:
	resume()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
