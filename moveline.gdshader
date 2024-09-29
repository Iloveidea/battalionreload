shader_type canvas_item;

uniform float len = 5.0;

void vertex() {
	
	// Called for every vertex the material is visible on.
}

void fragment() {
	float start = 1.0/len;
	float end = 1.0-start;
	float body = 1.0-start-end;
	//COLOR = texture(TEXTURE,vec2(UV.x*body+(1.0/3.0),UV.y));
	COLOR = texture(TEXTURE,vec2(UV.x/start*(1.0/3.0),UV.y));
	
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
