extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

signal died

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -850.0

var alive: bool = true
var can_move: bool = true
var health: int = 3
var just_got_hit: bool = false

func _physics_process(delta: float) -> void:
	if !alive or just_got_hit:
		return
	
	# Add animation
	if can_move:
		if velocity.x > 1 or velocity.x < -1:
			animated_sprite_2d.animation = "running";
		else:
			animated_sprite_2d.animation = "idle";
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "jumping";
		
	if can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_sound.play()

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
		if direction == 1.0:
			animated_sprite_2d.flip_h = false;
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true;


func hit() -> void:
	hit_sound.play()
	animated_sprite_2d.animation = "dying"
	just_got_hit = true
	health -= 1
	
	if health == 0:
		die()


func die() -> void:
	death_sound.play()
	alive = false
	died.emit()
	


func set_animation(animation_name: String) -> void:
	animated_sprite_2d.animation = animation_name


# --------------------------------
# SIGNAL HANDLERS
# --------------------------------

func _on_animated_sprite_2d_animation_looped() -> void:
	# Short hit animation
	if animated_sprite_2d.animation == "dying" and just_got_hit:
		just_got_hit = false
