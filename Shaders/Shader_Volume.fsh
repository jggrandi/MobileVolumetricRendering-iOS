const char* lowQFragShader = MAKESTRING
(
 //uniform parameters - volume and lookuptable samplers
 uniform sampler2D volumeSampler;
 uniform sampler2D lookupTableSampler;
 
 //variables from vertex shader
 varying mediump vec3 v_texcoord;
 varying mediump vec4 v_texcoord2;
 
 void main()
 {
     // code for a 8x8 slices img
     // no pre-integration and no Z filtering
     mediump vec2 texcoord = mediump vec2(v_texcoord.x*0.125, v_texcoord.y*0.125); // /8
     int slice = int(v_texcoord.z);
     int line = int(slice/8);// /8
     int row = slice-line*8;
     texcoord.x = texcoord.x + float(row)*0.125;
     texcoord.y = texcoord.y + float(line)*0.125;
     
     // code with no pre-integration table
     mediump vec2 texCol = mediump vec2(texture2D(volumeSampler,texcoord.xy).x,0.05);
     texCol.y= texCol.x;
     
     mediump vec4 lookup = texture2D(lookupTableSampler,texCol.xy);
     
     gl_FragColor = lookup;	
 }
 );

const char* mediumQZFilterFragShader = MAKESTRING
(
 //uniform parameters - volume and lookuptable samplers
 uniform sampler2D volumeSampler;
 uniform sampler2D lookupTableSampler;
 
 //variables from vertex shader
 varying mediump vec3 v_texcoord;
 varying mediump vec4 v_texcoord2;
 
 void main()
 {
     // code for a 8x8 slice img with filtering in z
     mediump vec2 texcoord2;
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
     mediump vec2 texCol = mediump vec2(texture2D(volumeSampler,texcoord.xy).x,texture2D(volumeSampler,texcoord2.xy).x);//0.05);
     //mediump vec2 texCol2 = mediump vec2(texture2D(volumeSampler,texcoord3.xy).x,texture2D(volumeSampler,texcoord4.xy).x);
     
     mediump vec2 lerpTex; 
     lerpTex.x = mix(texCol.y,texCol.x,1.0-weight1);
     lerpTex.y =lerpTex.x;
     //lerpTex.x = mix(texCol.x,texCol2.x,weight1);//texCol.x*(1.0-weight1)+texCol2.x*weight1;
     //lerpTex.y = mix(texCol.y,texCol2.y,weight2);//texCol.y*(1.0-weight2)+texCol2.y*weight2;	
     mediump vec4 lookup = texture2D(lookupTableSampler,lerpTex.xy);
     
     gl_FragColor = lookup;	
 }
 );

const char* mediumQPreIntTableFragShader = MAKESTRING
(
 //uniform parameters - volume and lookuptable samplers
 uniform sampler2D volumeSampler;
 uniform sampler2D lookupTableSampler;
 
 //variables from vertex shader
 varying mediump vec3 v_texcoord;
 varying mediump vec4 v_texcoord2;
 
 void main()
 {
     // code for a 8x8 slice img pre-integration classification
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
     mediump vec2 texCol = mediump vec2(texture2D(volumeSampler,texcoord.xy).x,texture2D(volumeSampler,texcoord2.xy).x);
     mediump vec4 lookup = texture2D(lookupTableSampler,texCol.xy);
     //mediump vec4 lookup = texture2D(texture,texcoord.xy);
     gl_FragColor = lookup;	
 }
 );

const char* highQFragShader = MAKESTRING
(
 //uniform parameters - volume and lookuptable samplers
 uniform sampler2D volumeSampler;
 uniform sampler2D lookupTableSampler;
 
 //variables from vertex shader
 varying mediump vec3 v_texcoord;
 varying mediump vec4 v_texcoord2;
 
 void main()
 {
     // code with pre-integration table and filtering on Z
     mediump vec2 texcoord3;
     mediump vec2 texcoord4;
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
     mediump vec2 texCol = mediump vec2(texture2D(volumeSampler,texcoord.xy).x,texture2D(volumeSampler,texcoord2.xy).x);//0.05);
     mediump vec2 texCol2 = mediump vec2(texture2D(volumeSampler,texcoord3.xy).x,texture2D(volumeSampler,texcoord4.xy).x);
     
     mediump vec2 lerpTex; 
     lerpTex.x = mix(texCol.x,texCol2.x,weight1);//texCol.x*(1.0-weight1)+texCol2.x*weight1;
     lerpTex.y = mix(texCol.y,texCol2.y,weight2);//texCol.y*(1.0-weight2)+texCol2.y*weight2;	
     
     mediump vec4 lookup = texture2D(lookupTableSampler,lerpTex.xy);
     
     
     gl_FragColor = lookup;	
     //if (lookup.w < 0.5)
     //    gl_FragColor = vec4(0.0);
     //else
     //    gl_FragColor = vec4(vec3(gl_FragCoord.z), 1.0);
 }
 );