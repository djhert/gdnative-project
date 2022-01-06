extends GSettings

var _keymaps = {
	"default": {
		"forward": KEY_W,
		"back": KEY_S,
		"left": KEY_A,
		"right": KEY_D,
		"up": KEY_SPACE,
		"down": KEY_SHIFT,
		"collision": KEY_E,
		"escape": KEY_ESCAPE
	}
}

# Settings variable to hold all of the configurable settings
var _settings := {
		"display": {
			"width": 1280,
			"height": 720
		},
		"audio": {
			"music": true,
			"effects": true,
			"voice": true,
			"music_volume": 75,
			"effects_volume": 75,
			"voice_volume": 100
		}
}

func _ready():
	call_deferred("setup", _settings)
	call_deferred("setup_keys", _keymaps)
