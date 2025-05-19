shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (UV.x >= 0.95 || UV.x <= 0.05 || UV.y >= 0.95 || UV.y <= 0.05) {
		COLOR.rgb = vec3(1.0);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
