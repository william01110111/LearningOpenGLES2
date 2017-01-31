varying lowp vec2 frag_TexCoord;
precision mediump float;

void main(void) {
	
	float dstSq = frag_TexCoord.x*frag_TexCoord.x+frag_TexCoord.y*frag_TexCoord.y;
	
	if (dstSq<0.2*0.2 && dstSq>0.15*0.15) {
		
		float cycle = 0.33;
		float ang = degrees(atan(frag_TexCoord.y, frag_TexCoord.x))/360.0;
		
		gl_FragColor.r=mod(ang-cycle*1.0+0.5, 1.0);
		gl_FragColor.b=mod(ang-cycle*2.0, 1.0);
		gl_FragColor.g=mod(ang-cycle*3.0, 1.0);
		gl_FragColor.a=1.0;
	}
	else {
		
		gl_FragColor = vec4(0, 0, 0, 1);
	}
}
