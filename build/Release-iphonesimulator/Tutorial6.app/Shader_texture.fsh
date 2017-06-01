//
//  Shader_BumpMapping.fsh
//
//  Created by Henrique Debarba on 25/11/2010.
//

//uniform parameters - texture and normal samplers
uniform sampler2D texture;
uniform sampler2D textureNormal;
uniform mediump mat4 view;

//light and material information (in a real application, could be uniform parameters)
mediump vec4 lightColor = vec4(1.0,1.0,1.0,1.0);
mediump vec4 lightAmbientColor = vec4(0.5,0.5,0.5,1.0);
mediump vec4 materialDiffuseColor = vec4(1.0,1.0,1.0,1.0);
mediump vec4 materialSpecularColor = vec4(1.0,1.0,1.0,1.0);
mediump float shininess = 20.0;
//mediump float bumpy = 1.0;
mediump float depth = 0.3;
mediump float tile = 8.0;

//variables from vertex shader
varying mediump vec2 v_texcoord;
varying mediump vec4 v_normal;
varying mediump vec4 v_tangent;
varying mediump vec4 v_binormal;
varying mediump vec4 v_viewVertPos;
//varying mediump vec4 v_eyeVector;
varying mediump vec4 v_lightVector;
//varying mediump vec4 v_halfVector;

//expand the 0 to 1 vector in the normalMap to -1 to 1
mediump vec3 expand(mediump vec3 vec)
{
  	return(vec - 0.5)* 2.0;
}

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

void main()
{
    mediump vec3 p = v_viewVertPos.xyz;
    mediump vec3 Vn = normalize(p);
    mediump float a = dot(v_normal.xyz,-Vn);
    mediump vec3 s  = mediump vec3(dot(Vn,v_tangent.xyz), dot(Vn,v_binormal.xyz), a);
    s  *= depth/a;
    mediump vec2 ds = s.xy;
    mediump	vec2 dp = v_texcoord;//IN.UV;
    mediump float d  = ray_intersect_rm(textureNormal,dp,ds);
    // get rm and color texture points
    mediump vec2 uv = dp+ds*d;
    mediump vec3 texCol = texture2D(texture,uv).xyz;
    mediump vec3 tNorm = expand(texture2D(textureNormal,uv).xyz);// - mediump vec3(0.5,0.5,0.5);
    tNorm = normalize(tNorm.x*v_tangent.xyz - tNorm.y*v_binormal.xyz + tNorm.z*v_normal.xyz);
    // compute light direction
    //p += Vn*d/(a*Depth);
    mediump vec3 Ln = normalize(v_lightVector.xyz);//(p-IN.lightpos.xyz);
    // compute diffuse and specular terms

    mediump float att = clamp(dot(-Ln,v_normal.xyz),0.0,1.0); //saturate
    mediump float diff = clamp(dot(-Ln,tNorm),0.0,1.0); //saturate
    mediump float spec = clamp(dot(normalize(-Ln-Vn),tNorm),0.0,1.0); //saturate
    spec = pow(spec,shininess);
    // compute final color
    mediump vec3 finalcolor = lightAmbientColor.xyz * texCol.xyz +
		att * (texCol.xyz * materialDiffuseColor.xyz * diff + materialSpecularColor.xyz * spec);
    //return float4(finalcolor.rgb,1.0);
	
	//mediump vec4 tNorm2 = texture2D(textureNormal,v_texcoord);
	gl_FragColor = mediump vec4(finalcolor,1);
	//gl_FragColor = mediump vec4(tNorm2.w,tNorm2.w,tNorm2.w,1);
/*	
	mediump vec4 t;
	mediump vec4 p,v,l,s,c;
	mediump vec2 dp,ds,uv;
	mediump float d,a;

	// ray intersect in view direction
	p  = v_viewVertPos; //v_position
	v  = normalize(p); //normalized v_position?
	a  = dot(v_normal,-v);
	s  = normalize(float3(dot(v,v_tangent),dot(v,v_binormal),a));
	s *= depth/a;
	ds = s.xy;
	dp = v_texcoord*tile;
	d  = ray_intersect_rm(textureNormal,dp,ds);
	
	// get rm and color texture points
	uv=dp+ds*d;
	t=texture2D(textureNormal,uv);
	c=texture2D(texture,uv);
	
	// expand normal from normal map in local polygon space
	t.xy=t.xy*2.0-1.0;
	t.z=sqrt(1.0-dot(t.xy,t.xy));
	t.xyz=normalize(t.x*IN.tangent-t.y*IN.binormal+t.z*IN.normal);
	
		
	t = normalize(mul(t, view));
 	v = normalize(mul(v, view));
 */	
 	/*float4 ReflectColor;

 	float3 RefDir_Red   = refraction(v, t, etaRatios.r);
 	float3 RefDir_Green = refraction(v, t, etaRatios.g);
 	float3 RefDir_Blue  = refraction(v, t, etaRatios.b);
*/

//	float3 ReflectDir = myReflect(v, t);
//	ReflectColor = texCUBE(BgSampler, ReflectDir);

//	refl_factor = fresnelBias + fresnelScale * pow(1 + dot(v, t), fresnelPower);

//  	return lerp (RefractColor, ReflectColor, refl_factor);
//	gl_FragColor = mediump vec4(1,1,1,1);
	/*
	//sample the diffuse texture and the normal map texture
	mediump vec4 diffuseTexture = texture2D(texture, v_texcoord);
	mediump vec4 normalMapTexture = expand(texture2D(textureNormal, v_texcoord));

	//normalize the interpolated normal, tangent and binormal
	mediump vec4 v_normal = normalize(v_normal) * bumpy;
	mediump vec4 v_tangent = normalize(v_tangent);
	mediump vec4 v_binormal = normalize(v_binormal) ;

	//construct the new normal for this fragment, and normalize it
    mediump vec4 normalBump = normalize(normalMapTexture.g*-v_tangent + normalMapTexture.r*-v_binormal + normalMapTexture.b*v_normal*bumpy);
 
	//calculate diff and specular contribution
	mediump float diff = max( 0.0, dot(normalBump,v_lightVector));
	mediump float spec = max( 0.0, pow(dot(normalBump,v_halfVector) , shininess)); 
	if( diff <= 0.0){
		spec = 0.0;
	}

	//ambient + diffuse colors to scale the texture sample
	mediump vec4 ambientColor = materialDiffuseColor * lightAmbientColor;
	mediump vec4 diffuseColor = materialDiffuseColor * diff * lightColor; 
	
	//scale diffuse and ambient values by the sampled diffuse texture color
	mediump vec4 diffAmbColor = (diffuseColor + ambientColor) * diffuseTexture;	
	//specColor, will be added to the final color
	mediump vec4 specColor = materialSpecularColor * lightColor * spec;
	
	//THE FINAL COLOR!
	gl_FragColor = diffAmbColor + specColor;*/
	
}
/*

float4 relief_map(
	v2f IN,
	uniform sampler2D texmap,
	uniform sampler2D reliefmap) : COLOR
{
	float4 t;
	float3 p,v,l,s,c;
	float2 dp,ds,uv;
	float d,a;

	// ray intersect in view direction
	p  = IN.vpos; //v_position
	v  = normalize(p); //normalized v_position?
	a  = dot(IN.normal,-v);
	s  = normalize(float3(dot(v,IN.tangent),dot(v,IN.binormal),a));
	s *= depth/a;
	ds = s.xy;
	dp = IN.txcoord*tile;
	d  = ray_intersect_rm(reliefmap,dp,ds);
	
	// get rm and color texture points
	uv=dp+ds*d;
	t=tex2D(reliefmap,uv);
	c=tex2D(texmap,uv);

	// expand normal from normal map in local polygon space
	t.xy=t.xy*2.0-1.0;
	t.z=sqrt(1.0-dot(t.xy,t.xy));
	t.xyz=normalize(t.x*IN.tangent-t.y*IN.binormal+t.z*IN.normal);
	
	t = normalize(mul(t, viewI));
 	v = normalize(mul(v, viewI));
 	
 	float4 RefractColor;
 	float4 ReflectColor;

 	float3 RefDir_Red   = refraction(v, t, etaRatios.r);
 	float3 RefDir_Green = refraction(v, t, etaRatios.g);
 	float3 RefDir_Blue  = refraction(v, t, etaRatios.b);

	RefractColor.r = texCUBE(BgSampler, RefDir_Red).r;
	RefractColor.g = texCUBE(BgSampler, RefDir_Green).g;
	RefractColor.b = texCUBE(BgSampler, RefDir_Blue).b;
	RefractColor.a = 1;

	float3 ReflectDir = myReflect(v, t);
	ReflectColor = texCUBE(BgSampler, ReflectDir);

	refl_factor = fresnelBias + fresnelScale * pow(1 + dot(v, t), fresnelPower);

  	return lerp (RefractColor, ReflectColor, refl_factor);
}*/