class_name GameConfig

const TABLE_WIDTH : int = 960
const BALL_DIAMETER : int = 20
const CPU_PADDLE_Y : int = 260
const PADDLE_HOME : Vector2 = Vector2(500, 250)
const PADDLE_MIN_X : int = 80
const LOSE_ROW_Y : int = 1800
const GRID_SIZE : int = 100
const BLOCK_START_POS : Vector2 = Vector2(50, 200)
const MAX_COLUMNS : int = 10
const STARTING_ROWS : int = 8
const MIN_AIM_ANGLE : float = 15.0
const MAX_AIM_ANGLE : float = 165.0
const MAX_POINTS : int = 11
const BASE_SPEED_MODS : Array[int] = [40, 45, 50]
const COUNTDOWN_SEC : float = 0.8
const SERVE_DELAY : float = 0.5
const SCORE_INCREMENT : int = 1
const STARTING_SPEEDS : Array[int] = [400, 500, 600]
const BRICK_HP_FONT_SIZE : int = 28

# Physics layers (bit values matching project.godot layer names 1-9)
const LAYER_WALLS : int = 1 << 0
const LAYER_PLAYER : int = 1 << 1
const LAYER_ENEMY : int = 1 << 2
const LAYER_BLOCK : int = 1 << 4
const LAYER_BALL : int = 1 << 6
const LAYER_BB_MOD_PLAYER : int = 1 << 7
const LAYER_FLOOR : int = 1 << 8

# Collision masks (layers each body detects)
const MASK_BALL : int = LAYER_WALLS | LAYER_BLOCK | LAYER_BB_MOD_PLAYER  # 145
const MASK_BB_CLASSIC_BALL : int = LAYER_WALLS | LAYER_PLAYER | LAYER_BLOCK | LAYER_FLOOR  # 275
const MASK_ALL : int = MASK_BALL
const MASK_PONG_BALL : int = LAYER_WALLS | LAYER_PLAYER | LAYER_ENEMY  # 7
const MASK_PLAYER : int = LAYER_WALLS | LAYER_BALL  # 65
const MASK_BB_MOD_PLAYER : int = 0
const MASK_WALL : int = LAYER_WALLS  # 1

# Groups (must equal class_name of each script)
const GROUP_BALL : StringName = &"Ball"
const GROUP_PLAYER : StringName = &"Player"
const GROUP_CPU : StringName = &"CPU"
const GROUP_BRICK : StringName = &"Brick"
const GROUP_LEVEL_PONG : StringName = &"LevelPong"
const GROUP_LEVEL_BB_CLASSIC : StringName = &"LevelBbClassic"
const GROUP_LEVEL_BB_MODERN : StringName = &"LevelBbModern"
const GROUP_BB_MOD_PLAYER : StringName = &"BbModPlayer"
const GROUP_MAIN_MENU_UI : StringName = &"MainMenuUi"
