shader_type canvas_item;

// It took me 1.5 days to find two lines of code to make this work. Those two
// lines of code were in the documentations. I am going to eat chip and cry.

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
}
