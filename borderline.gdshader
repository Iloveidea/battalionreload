shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float x = UV.x;
	float y = UV.y;
	if (int(x*10000.0)%int(0.2*10000.0) < 1000){
		COLOR = vec4(1,0.722,0,1);
	}else{
		COLOR = vec4(1,1,1,1);
	}
	
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
