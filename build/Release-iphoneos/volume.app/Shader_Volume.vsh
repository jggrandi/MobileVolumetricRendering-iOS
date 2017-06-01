//
//  Shader_Volume.vsh
//
//  Created by Henrique Debarba on 25/11/2010.
//

//vertex attributes
attribute vec3 vertexPos;
attribute vec3 texcoord;

//uniform parameters
//uniform mat4 modelView;
uniform mat4 modelViewInverse;
uniform mat4 mvp;
//uniform mat4 view;
uniform float SliceDistance;

//passing parameters
varying mediump vec3 v_texcoord;
varying mediump vec4 v_texcoord2;

			
void main()
{
	//transform position to clipping space
	gl_Position = mvp * vec4(vertexPos,1.0);
	//texcoord passthrough
	v_texcoord=texcoord;
	
	// transform view pos and view dir to obj space
	vec4 vPosition = vec4(0.0, 0.0, 0.0, 1.0);
	vPosition = modelViewInverse*vPosition;
	vec4 vDir = vec4(0.0, 0.0, -1.0, 1.0);
	vDir = normalize(modelViewInverse*vDir);
	
	// compute position of sB
	vec4 eyeToVert = normalize(vec4(vertexPos,1.0) - vPosition);
	//vec3 sB = texcoord - eyeToVert.xyz*(SliceDistance/dot(vDir.xyz, eyeToVert.xyz));
	vec4 sB = vec4(texcoord,1.0) - eyeToVert*(SliceDistance/dot(vDir, eyeToVert));
	
	// compute the texture coordinate for sB
	v_texcoord2 = sB;

//	slice = 1;//(int)texcoord.z;
		
}