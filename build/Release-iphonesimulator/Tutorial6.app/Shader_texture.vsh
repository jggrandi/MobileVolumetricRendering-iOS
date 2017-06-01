//
//  Shader_BumpMapping.vsh
//
//  Created by Henrique Debarba on 25/11/2010.
//

//vertex attributes
attribute vec3 position;
attribute vec3 normal;
attribute vec3 tangent;
attribute vec2 texcoord;

//uniform parameters

uniform mat4 modelView;
uniform mat4 mvp;

//passing parameters
varying mediump vec2 v_texcoord;
varying mediump vec4 v_normal;
varying mediump vec4 v_tangent;
varying mediump vec4 v_binormal;
varying mediump vec4 v_viewVertPos;
//varying mediump vec4 v_eyeVector;
varying mediump vec4 v_lightVector;
//varying mediump vec4 v_halfVector;
	
//this sample uses only a direction for the light
//in a real aplication, light shoud be passad as an uniform parameter
mediump vec4 lightDir = vec4(1.0,-1.0,-1.0,0.0);
//working on the modelview space, the eye position is always 0,0,0
mediump vec4 viewEyePos = vec4(0.0,0.0,0.0,0.1);
			
void main()
{
	//transform position to clipping space
	gl_Position = mvp * vec4(position,1.0);
	
	//calculate vertPos in view space per-vertex
	v_viewVertPos = (modelView * vec4(position,1.0));
	//eyeVector from current vertex to eye
//	v_eyeVector = normalize(viewEyePos-v_viewVertPos);

//	DONE USING DIRECTION	// light position in view space
//DONE	float4 lp=float4(lightpos.x,lightpos.y,lightpos.z,1);
//DONE	OUT.lightpos=mul(lp,view);

	//lightVector -lightDir = vector from vertex to light
	v_lightVector = normalize(modelView * -lightDir ); //in view coordinates system
	//v_lightVector = normalize(-lightDir ); //light folow the camera 
	
	//halfVector between eyeVector and lightVector
//	v_halfVector = normalize(v_eyeVector+v_lightVector);

	//normal in modelview space per-vertex
	v_normal = modelView * vec4(normal,0.0);
	//tangent in modelview space per-vertex
	v_tangent = modelView * vec4(tangent,0.0);
	//binormal is the cross product of normal and tangent
	v_binormal = modelView * vec4(cross(normal,tangent),0.0);
	
	//texcoord passthrough
	v_texcoord=texcoord;
		
}
/*
struct a2v 
{
DONE    float4 pos		: POSITION;
WTF     float4 color	: COLOR0;
DONE    float3 normal	: NORMAL;
DONE    float2 txcoord	: TEXCOORD0;
DONE    float3 tangent	: TANGENT0;
ON THE FLY    float3 binormal	: BINORMAL0;
};

struct v2f
{
DONE    float4 hpos		: POSITION;
WTF THIS IS DOING HERE	float4 color	: COLOR0;
DONE    float2 txcoord	: TEXCOORD0;
DONE    float3 vpos		: TEXCOORD1;
DONE    float3 tangent	: TEXCOORD2;
DONE    float3 binormal	: TEXCOORD3;
DONE    float3 normal	: TEXCOORD4;
DONE LIGHTDIRECTION	float4 lightpos	: TEXCOORD5;

};

v2f view_space(a2v IN)
{
DONE	v2f OUT;

DONE	// vertex position in object space
DONE	float4 pos=float4(IN.pos.x,IN.pos.y,IN.pos.z,1.0);

REDUCTION ON THE MATRIX SIZE	// compute modelview rotation only part
NOT NECESSARY	float3x3 modelviewrot;
....	modelviewrot[0]=modelview[0].xyz;
....	modelviewrot[1]=modelview[1].xyz;
....	modelviewrot[2]=modelview[2].xyz;

DONE	// vertex position in clip space
DONE	OUT.hpos=mul(pos,modelviewproj);

DONE	// vertex position in view space (with model transformations)
DONE	OUT.vpos=mul(pos,modelview).xyz;

DONE USING DIRECTION	// light position in view space
DONE	float4 lp=float4(lightpos.x,lightpos.y,lightpos.z,1);
DONE	OUT.lightpos=mul(lp,view);

DONE	// tangent space vectors in view space (with model transformations)
DONE	OUT.tangent=mul(IN.tangent,modelviewrot);
DONE	OUT.binormal=mul(IN.binormal,modelviewrot);
DONE	OUT.normal=mul(IN.normal,modelviewrot);

DONE	// copy color and texture coordinates
WTF THIS IS DOING HERE	OUT.color=IN.color;
DONE	OUT.txcoord=IN.txcoord.xy;

DONE	return OUT;
}
*/