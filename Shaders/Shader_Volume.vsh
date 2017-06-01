const char* vertexShader = MAKESTRING
(
 attribute vec3 vertexPos;
 attribute vec3 texCoord;
 
 uniform mat4 modelViewInverse;
 uniform mat4 mvp;
 uniform float sliceDistance;
 
 varying mediump vec3 v_texcoord;
 varying mediump vec4 v_texcoord2;
 
 void main()
{
    gl_Position = mvp * vec4(vertexPos,1.0);
    v_texcoord=texCoord;
    
    vec4 vPosition = vec4(0.0, 0.0, 0.0, 1.0);
    vPosition = modelViewInverse*vPosition;
    vec4 vDir = vec4(0.0, 0.0, -1.0, 1.0);
    vDir = normalize(modelViewInverse*vDir);
    
    vec4 eyeToVert = normalize(vec4(vertexPos,1.0) - vPosition);
    vec4 sB = vec4(texCoord,1.0) - eyeToVert*(sliceDistance/dot(vDir, eyeToVert));
    
    v_texcoord2 = sB;		
}
 
 );