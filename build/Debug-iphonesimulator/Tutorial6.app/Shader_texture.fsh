//
//  Shader_ReliefMapping.fsh
//
//  Created by Henrique Debarba on 25/11/2010.
//

//uniform parameters - texture and normal samplers
uniform sampler2D texture;
uniform sampler2D textureNormal;
//uniform mediump mat4 view;

//light and material information (in a real application, could be uniform parameters)
/*mediump vec4 lightColor = vec4(1.0,1.0,1.0,1.0);
mediump vec4 lightAmbientColor = vec4(0.5,0.5,0.5,1.0);
mediump vec4 materialDiffuseColor = vec4(1.0,1.0,1.0,1.0);
mediump vec4 materialSpecularColor = vec4(1.0,1.0,1.0,1.0);
mediump float shininess = 20.0;
mediump float depth = 0.2;
mediump float tile = 8.0;
*/
//variables from vertex shader
varying mediump vec3 v_texcoord;
/*varying mediump vec2 v_texcoord;
varying mediump vec4 v_normal;
varying mediump vec4 v_tangent;
varying mediump vec4 v_binormal;
varying mediump vec4 v_viewVertPos;
varying mediump vec4 v_lightVector;
varying mediump vec4 v_lightPos;
*/
/*
//expand the 0 to 1 vector in the normalMap to -1 to 1
mediump vec3 expand(mediump vec3 vec)
{
  	return(vec - 0.5)* 2.0;
}

//depth of the first intersection
mediump float ray_intersect_rm(
		sampler2D reliefmap,
		mediump vec2 dp, 
		mediump vec2 ds)
{
	const int linear_search_steps=20;
	const int binary_search_steps=10;
	mediump float depth_step=1.0/mediump float(linear_search_steps);

	// current size of search window
	mediump float size=depth_step;
	// current depth position
	mediump float depth=0.0;
	// best match found (starts with last position 1.0)
	mediump float best_depth=1.0;

	// search front to back for first point inside object
	for( int i=0;i<linear_search_steps-1;i++ )
	{
		depth+=size;
		mediump vec4 t=texture2D(reliefmap,dp+ds*depth);

		if (best_depth>0.996)	// if no depth found yet
		if (depth>=t.w)
			best_depth=depth;	// store best depth
	}
	depth=best_depth;
	
	// recurse around first point (depth) for closest match
	for( int i=0;i<binary_search_steps;i++ )
	{
		size*=0.5;
		mediump vec4 t=texture2D(reliefmap,dp+ds*depth);
		if (depth>=t.w)
		{
			best_depth=depth;
			depth-=2.0*size;
		}
		depth+=size;
	}

	return best_depth;
}
*/
void main()
{
/*    mediump vec3 p = v_viewVertPos.xyz;
    mediump vec3 Vn = normalize(p);
    mediump float a = dot(v_normal.xyz,-Vn);
    mediump vec3 s  = mediump vec3(dot(Vn,v_tangent.xyz), dot(Vn,v_binormal.xyz), a);
    s  *= depth/a;
    mediump vec2 ds = s.xy;
    mediump	vec2 dp = v_texcoord;
    mediump float d  = ray_intersect_rm(textureNormal,dp,ds);
    // get rm and color texture points
    mediump vec2 uv = dp+ds*d;
    mediump vec3 texCol = texture2D(texture,uv).xyz;
    mediump vec3 tNorm = expand(texture2D(textureNormal,uv).xyz);
	//tNorm.z = sqrt(1.0-dot(tNorm.xy,tNorm.xy));
	//tNorm.z = sqrt(1.0 - (tNorm.x*tNorm.x+tNorm.y*tNorm.y)); 
	//mediump vec3 tNorm = texture2D(textureNormal,uv).xyz - mediump vec3(0.5,0.5,0.5);
	
    tNorm = normalize(tNorm.x*v_tangent.xyz - tNorm.y*v_binormal.xyz + tNorm.z*v_normal.xyz);
    // compute light direction
    //p += Vn*d/(a*depth);
    mediump vec3 Ln = normalize(v_lightVector.xyz);////(p-IN.lightpos.xyz);
    //mediump vec3 Ln = normalize(p-v_lightVector.xyz);
    //mediump vec3 Ln = normalize(p-v_lightPos.xyz);
    
	// compute diffuse and specular terms

    mediump float att = clamp(dot(-Ln,v_normal.xyz),0.0,1.0); //saturate
    mediump float diff = clamp(dot(-Ln,tNorm),0.0,1.0); //saturate
    mediump float spec = clamp(dot(normalize(-Ln-Vn),tNorm),0.0,1.0); //saturate
    spec = pow(spec,shininess);
    // compute final color
    mediump vec3 finalcolor = lightAmbientColor.xyz * texCol.xyz +
		att * (texCol.xyz * materialDiffuseColor.xyz * diff + materialSpecularColor.xyz * spec);
	
	gl_FragColor = mediump vec4(finalcolor,1);*/
	//mediump vec2 texCol = texture2D(texture,v_texcoord.xy).xy*255.0;
	mediump vec2 texcoord = mediump vec2(v_texcoord.x, v_texcoord.y/16.0);
    texcoord.y = texcoord.y + (1.0 *v_texcoord.z);
	mediump vec2 texCol = mediump vec2(texture2D(texture,texcoord.xy).x,1);
	
    //mediump vec2 texCol = mediump vec2(texture2D(textureNormal,v_texcoord.xy).x,1);
    
	//mediump vec2 texCol = mediump vec2(256,10);
	mediump vec4 lookup = texture2D(textureNormal,texCol);
//	gl_FragColor = mediump vec4(1.0,0.3,0.3,0.2);	
	gl_FragColor = mediump vec4(lookup.xyz, lookup.w*0.2);
	//gl_FragColor = lookup;	

}