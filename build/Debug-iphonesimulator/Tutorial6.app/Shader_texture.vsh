//
//  Shader_ReliefMapping.vsh
//
//  Created by Henrique Debarba on 25/11/2010.
//

//vertex attributes
attribute vec3 vertexPos;
//attribute vec3 normal;
//attribute vec3 tangent;
attribute vec3 texcoord;

//uniform parameters
uniform mat4 modelView;
uniform mat4 mvp;
uniform mat4 view;

//passing parameters
varying mediump vec3 v_texcoord;
/*varying mediump vec2 v_texcoord;
varying mediump vec4 v_normal;
varying mediump vec4 v_tangent;
varying mediump vec4 v_binormal;
varying mediump vec4 v_viewVertPos;
varying mediump vec4 v_lightVector;
varying mediump vec4 v_lightPos;
*/
//this sample uses only a direction for the light
//in a real aplication, light shoud be passad as an uniform parameter
//mediump vec4 lightDir = vec4(1.0,-1.0,-1.0,0.0);
//mediump vec4 lightPos = vec4(1.0,-1.0,-10.0,1.0);
//working on the modelview space, the eye position is always 0,0,0
//mediump vec4 viewEyePos = vec4(0.0,0.0,0.0,0.1);
			
void main()
{
	//transform position to clipping space
	gl_Position = mvp * vec4(vertexPos,1.0);
	
/*	//calculate vertPos in view space per-vertex
	v_viewVertPos = (modelView * vec4(position,1.0));

	//lightVector -lightDir = vector from vertex to light
	//v_lightVector = normalize(modelView * -lightDir ); //in view coordinates system
	v_lightVector = normalize(view * -lightDir ); //in view coordinates system
	//v_lightPos = normalize( lightPos ); //in view coordinates system
	v_lightPos =  lightPos ;
	//v_lightVector = normalize(-lightDir ); //light folow the camera 
	

	//normal in modelview space per-vertex
	v_normal = modelView * vec4(normal,0.0);
	//tangent in modelview space per-vertex
	v_tangent = modelView * vec4(tangent,0.0);
	//binormal is the cross product of normal and tangent
	v_binormal = modelView * vec4(cross(normal,tangent),0.0);
	*/
	//texcoord passthrough
	v_texcoord=texcoord;
		
}