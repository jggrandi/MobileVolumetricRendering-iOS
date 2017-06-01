//
//  Shader_Volume.fsh
//
//  Created by Henrique Debarba on 25/11/2010.
//

//uniform parameters - texture and normal samplers
uniform sampler2D texture;
uniform sampler2D textureNormal;

//variables from vertex shader
varying mediump vec3 v_texcoord;
varying mediump vec4 v_texcoord2;

void main()
{
/*	
	// code for a 16 slices img
	mediump vec2 texcoord = mediump vec2(v_texcoord.x, v_texcoord.y/16.0);
    int slice = int(v_texcoord.z);//(v_texcoord.z*16);
	texcoord.y = texcoord.y + float(slice)/16.0;// v_texcoord.z;//(1.0 *v_texcoord.z);

	mediump vec2 texcoord2 = mediump vec2(v_texcoord2.x, v_texcoord2.y/16.0);
	slice = int(v_texcoord2.z);//(v_texcoord.z*16);
	texcoord2.y = texcoord2.y + float(slice)/16.0;// v_texcoord.z;//(1.0 *v_texcoord.z);
*/

/*	// code for a 8x8 slices img
	// no pre-integration and no Z filtering
	mediump vec2 texcoord = mediump vec2(v_texcoord.x*0.125, v_texcoord.y*0.125); // /8
    int slice = int(v_texcoord.z);
	int line = int(slice/8);// /8
	int row = slice-line*8;
	texcoord.x = texcoord.x + float(row)*0.125;
	texcoord.y = texcoord.y + float(line)*0.125;
	
	// code with no pre-integration table
	mediump vec2 texCol = mediump vec2(texture2D(texture,texcoord.xy).x,0.05);
	texCol.y= texCol.x;
	mediump vec4 lookup = texture2D(textureNormal,texCol.xy);
*/
/*
	// code for a 8x8 slices img
	// no pre-integration and no Z filtering
	mediump vec2 texcoord = mediump vec2(v_texcoord.x*0.125, v_texcoord.y*0.125); // /8
    int slice = int(v_texcoord.z);
		int line;
		int row;
		int limit=44;
		mediump vec2 texCol;
		mediump vec4 lookup = mediump vec4(0.0, 0.0, 0.0, 0.0);
		line = int(slice/8);// /8
		row = slice-line*8;
		texcoord.x = texcoord.x + float(row)*0.125;
		texcoord.y = texcoord.y + float(line)*0.125;
	if (slice < limit){

	
		// code with no pre-integration table
		texCol = mediump vec2(texture2D(texture,texcoord.xy).x,0.05);
		texCol.y= texCol.x;
		lookup = texture2D(textureNormal,texCol.xy);
	}

	*/
	

/*
	// code for a 8x8 slice img with no filtering in z
	// with pre-integration classification
	mediump vec2 texcoord = mediump vec2(v_texcoord.x*0.125, v_texcoord.y*0.125); // /8
    int slice = int(v_texcoord.z);
	int line = int(slice/8);// /8
	int row = slice-line*8;
	texcoord.x = texcoord.x + float(row)*0.125;
	texcoord.y = texcoord.y + float(line)*0.125;
	
	mediump vec2 texcoord2 = mediump vec2(v_texcoord2.x*0.125, v_texcoord2.y*0.125); // /8
	slice = int(v_texcoord2.z);
	line = int(slice/8); // /8
	row = slice-line*8;	
	texcoord2.x = texcoord2.x + float(row)*0.125;
	texcoord2.y = texcoord2.y + float(line)*0.125;
	
		
	// code with pre-integration table and no filtering in z
	mediump vec2 texCol = mediump vec2(texture2D(texture,texcoord.xy).x,texture2D(texture,texcoord2.xy).x);
	mediump vec4 lookup = texture2D(textureNormal,texCol.xy);
	//mediump vec4 lookup = texture2D(texture,texcoord.xy);
*/
/*	mediump vec2 texcoord2;
	mediump vec2 texcoord = mediump vec2(v_texcoord.x*0.125, v_texcoord.y*0.125); // /8
    int slice = int(v_texcoord.z);
	int line = int(slice/8);// /8
	int row = slice-line*8;
	texcoord.x = texcoord.x + float(row)*0.125;
	texcoord.y = texcoord.y + float(line)*0.125;
	
	mediump float weight1;
	if (float(slice)>v_texcoord.z){
		weight1 = float(slice)-v_texcoord.z;
		slice -=1;
	}
	else {
		weight1 = v_texcoord.z-float(slice);
		slice+=1;
	}
	line = int(slice/8);// /8
	row = slice-line*8;
	texcoord2.x = v_texcoord.x*0.125 + float(row)*0.125;
	texcoord2.y = v_texcoord.y*0.125 + float(line)*0.125;


	// code with pre-integration table and filtering on Z
	mediump vec2 texCol = mediump vec2(texture2D(texture,texcoord.xy).x,texture2D(texture,texcoord2.xy).x);//0.05);
	//mediump vec2 texCol2 = mediump vec2(texture2D(volumeSampler,texcoord3.xy).x,texture2D(volumeSampler,texcoord4.xy).x);
	
	mediump vec2 lerpTex; 
	lerpTex.x = mix(texCol.y,texCol.x,1.0-weight1);
	lerpTex.y =lerpTex.x;
	//lerpTex.x = mix(texCol.x,texCol2.x,weight1);//texCol.x*(1.0-weight1)+texCol2.x*weight1;
	//lerpTex.y = mix(texCol.y,texCol2.y,weight2);//texCol.y*(1.0-weight2)+texCol2.y*weight2;	

	mediump vec4 lookup = texture2D(textureNormal,lerpTex.xy);
*/


	// code with pre-integration table and filtering on Z
	mediump vec2 texcoord3;
	mediump vec2 texcoord4;
	mediump vec2 texcoord = mediump vec2(v_texcoord.x*0.125, v_texcoord.y*0.125); // /8
    int slice = int(v_texcoord.z);
	int line = int(slice/8);// /8
	int row = slice-line*8;
	texcoord.x = texcoord.x + float(row)*0.125;
	texcoord.y = texcoord.y + float(line)*0.125;
 	
	mediump vec4 lookup = vec4(1,0,0,0.5);
	

	
	mediump float weight1;
	if (float(slice)>v_texcoord.z){
		weight1 = float(slice)-v_texcoord.z;
		slice -=1;

	}
	else {
		weight1 = v_texcoord.z-float(slice);
		slice+=1;
	}
	line = int(slice/8);// /8
	row = slice-line*8;
	texcoord3.x = v_texcoord.x*0.125 + float(row)*0.125;
	texcoord3.y = v_texcoord.y*0.125 + float(line)*0.125;
	

	mediump vec2 texcoord2 = mediump vec2(v_texcoord2.x*0.125, v_texcoord2.y*0.125); // /8
	slice = int(v_texcoord2.z);
	line = int(slice/8); // /8
	row = slice-line*8;	
	texcoord2.x = texcoord2.x + float(row)*0.125;
	texcoord2.y = texcoord2.y + float(line)*0.125;
	
	
	mediump float weight2;
	if (float(slice)>v_texcoord2.z){
		weight2 = float(slice)-v_texcoord2.z;
		slice -=1;
		
	}
	else {
		weight2 = v_texcoord2.z-float(slice);
		slice+=1;
	}
	line = int(slice/8);// /8
	row = slice-line*8;
	texcoord4.x = v_texcoord2.x*0.125 + float(row)*0.125;
	texcoord4.y = v_texcoord2.y*0.125 + float(line)*0.125;


	// code with pre-integration table and filtering on Z
	mediump vec2 texCol = mediump vec2(texture2D(texture,texcoord.xy).x,texture2D(texture,texcoord2.xy).x);//0.05);
	
	//if(texCol.x>0.1){
	mediump vec2 texCol2 = mediump vec2(texture2D(texture,texcoord3.xy).x,texture2D(texture,texcoord4.xy).x);
	
	mediump vec2 lerpTex; 
	lerpTex.x = mix(texCol.x,texCol2.x,weight1);//texCol.x*(1.0-weight1)+texCol2.x*weight1;
	lerpTex.y = mix(texCol.y,texCol2.y,weight2);//texCol.y*(1.0-weight2)+texCol2.y*weight2;	
//lerpTex.x=0.5;
//lerpTex.y=0.5;
lookup = texture2D(textureNormal,lerpTex.xy);
//	lookup = texture2D(textureNormal,lerpTex.xy);
	//}
	
	gl_FragColor = lookup;	

}