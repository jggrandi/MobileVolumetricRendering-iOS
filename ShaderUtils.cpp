/*==============================================================================
            Copyright (c) 2010-2011 QUALCOMM Incorporated.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary
==============================================================================*/


#include <math.h>
#include <stdio.h>
#include "ShaderUtils.h"


// Print a 4x4 matrix
void
ShaderUtils::printMatrix(const float* mat)
{
    for (int r = 0; r < 4; r++, mat += 4) {
        printf("%7.3f %7.3f %7.3f %7.3f", mat[0], mat[1], mat[2], mat[3]);
    }
}


// Print GL error information
void
ShaderUtils::checkGlError(const char* operation)
{ 
    for (GLint error = glGetError(); error; error = glGetError()) {
        printf("after %s() glError (0x%x)", operation, error);
    }
}


// Set the rotation components of a 4x4 matrix
void
ShaderUtils::setRotationMatrix(float angle, float x, float y, float z, 
                               float *matrix)
{
    double radians, c, s, c1, u[3], length;
    int i, j;
    
    radians = (angle * M_PI) / 180.0;
    
    c = cos(radians);
    s = sin(radians);
    
    c1 = 1.0 - cos(radians);
    
    length = sqrt(x * x + y * y + z * z);
    
    u[0] = x / length;
    u[1] = y / length;
    u[2] = z / length;
    
    for (i = 0; i < 16; i++) {
        matrix[i] = 0.0;
    }
    
    matrix[15] = 1.0;
    
    for (i = 0; i < 3; i++) {
        matrix[i * 4 + (i + 1) % 3] = u[(i + 2) % 3] * s;
        matrix[i * 4 + (i + 2) % 3] = -u[(i + 1) % 3] * s;
    }
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            matrix[i * 4 + j] += c1 * u[i] * u[j] + (i == j ? c : 0.0);
        }
    }
}


// Set the translation components of a 4x4 matrix
void
ShaderUtils::translatePoseMatrix(float x, float y, float z, float* matrix)
{
    if (matrix) {
        // matrix * translate_matrix
        matrix[12] += (matrix[0] * x + matrix[4] * y + matrix[8]  * z);
        matrix[13] += (matrix[1] * x + matrix[5] * y + matrix[9]  * z);
        matrix[14] += (matrix[2] * x + matrix[6] * y + matrix[10] * z);
        matrix[15] += (matrix[3] * x + matrix[7] * y + matrix[11] * z);
    }
}


// Apply a rotation
void
ShaderUtils::rotatePoseMatrix(float angle, float x, float y, float z,
                              float* matrix)
{
    if (matrix) {
        float rotate_matrix[16];
        ShaderUtils::setRotationMatrix(angle, x, y, z, rotate_matrix);
        
        // matrix * scale_matrix
        ShaderUtils::multiplyMatrix(matrix, rotate_matrix, matrix);
    }
}


// Apply a scaling transformation
void
ShaderUtils::scalePoseMatrix(float x, float y, float z, float* matrix)
{
    if (matrix) {
        // matrix * scale_matrix
        matrix[0]  *= x;
        matrix[1]  *= x;
        matrix[2]  *= x;
        matrix[3]  *= x;
        
        matrix[4]  *= y;
        matrix[5]  *= y;
        matrix[6]  *= y;
        matrix[7]  *= y;
        
        matrix[8]  *= z;
        matrix[9]  *= z;
        matrix[10] *= z;
        matrix[11] *= z;
    }
}


// Multiply the two matrices A and B and write the result to C
void
ShaderUtils::multiplyMatrix(float *matrixA, float *matrixB, float *matrixC)
{
    int i, j, k;
    float aTmp[16];
    
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            aTmp[j * 4 + i] = 0.0;
            
            for (k = 0; k < 4; k++) {
                aTmp[j * 4 + i] += matrixA[k * 4 + i] * matrixB[j * 4 + k];
            }
        }
    }
    
    for (i = 0; i < 16; i++) {
        matrixC[i] = aTmp[i];
    }
}

void ShaderUtils::loadIdentity(float *matrix){
    matrix[0]=1;
    matrix[1]=0;
    matrix[2]=0;
    matrix[3]=0;
    matrix[4]=0;
    matrix[5]=1;
    matrix[6]=0;
    matrix[7]=0;
    matrix[8]=0;
    matrix[9]=0;
    matrix[10]=1;
    matrix[11]=0;
    matrix[12]=0;
    matrix[13]=0;
    matrix[14]=0;
    matrix[15]=1;
}

void ShaderUtils::transposeMatrix(float *matrix){
    for (int i = 0; i < 4; i++) {
        for (int j = i + 1; j < 4; j++) {
            int save = matrix[j+i*4];
            matrix[j+i*4] = matrix[j*4+i];
            matrix[j*4+i] = save;
        }
    }
}

void ShaderUtils::copyMatrix(float *matrix, float *result){
    for (int i = 0; i < 16; i++)
        result[i]=matrix[i];
}

//added by Henrique Debarba

void ShaderUtils::multMatrixVec(float *matrix, float *inVector, float *outVector){

    outVector[0] = inVector[0]*matrix[0] + inVector[1]*matrix[4] + inVector[2]*matrix[8] + inVector[3]*matrix[12];
    outVector[1] = inVector[0]*matrix[1] + inVector[1]*matrix[5] + inVector[2]*matrix[9] + inVector[3]*matrix[13];
    outVector[2] = inVector[0]*matrix[2] + inVector[1]*matrix[6] + inVector[2]*matrix[10] + inVector[3]*matrix[14];
    outVector[3] = inVector[0]*matrix[3] + inVector[1]*matrix[7] + inVector[2]*matrix[11] + inVector[3]*matrix[15];
 
  /*  
    outVector[0] = inVector[0]*matrix[0] + inVector[1]*matrix[1] + inVector[2]*matrix[2] + inVector[3]*matrix[3];
    outVector[1] = inVector[0]*matrix[4] + inVector[1]*matrix[5] + inVector[2]*matrix[6] + inVector[3]*matrix[7];
    outVector[2] = inVector[0]*matrix[8] + inVector[1]*matrix[9] + inVector[2]*matrix[10] + inVector[3]*matrix[11];
    outVector[3] = inVector[0]*matrix[12] + inVector[1]*matrix[13] + inVector[2]*matrix[14] + inVector[3]*matrix[15];
   */ 
}


bool ShaderUtils::unProject(float winx, float winy, float winz,
            float* modelMatrix, 
            float* projMatrix,
            float* viewport,
             float *objx, float *objy, float *objz)
{
    float finalMatrix[16];
    float in[4];
    float out[4];
    
    //multiplyMatrix(modelMatrix, projMatrix, finalMatrix);
    //if (!inverseMatrix(finalMatrix, finalMatrix)) return(GL_FALSE);
    //inverseMatrix(finalMatrix, finalMatrix);
    
    in[0]=winx;
    in[1]=winy;
    in[2]=winz;
    in[3]=1.0;
    
    /* Map x and y from window coordinates */
    in[0] = (in[0] - viewport[0]) / viewport[2];
    in[1] = (in[1] - viewport[1]) / viewport[3];
    
    /* Map to range -1 to 1 */
    in[0] = in[0] * 2 - 1;
    in[1] = in[1] * 2 - 1;
    in[2] = in[2] * 2 - 1;
    
    //multMatrixVec(finalMatrix, in, out);
    multMatrixVec(modelMatrix, in, out);
    if (out[3] == 0.0) return(GL_FALSE);
    out[0] /= out[3];
    out[1] /= out[3];
    out[2] /= out[3];
    *objx = out[0];
    *objy = out[1];
    *objz = out[2];
    return(GL_TRUE);
}
//
/// \ calculates the determinant of a 4x4 matrix
//
float 
ShaderUtils::findDeterminant(float *matrix)
{
	return
	matrix[12]*matrix[9]*matrix[6]*matrix[3]-
	matrix[8]*matrix[13]*matrix[6]*matrix[3]-
	matrix[12]*matrix[5]*matrix[10]*matrix[3]+
	matrix[4]*matrix[13]*matrix[10]*matrix[3]+
	matrix[8]*matrix[5]*matrix[14]*matrix[3]-
	matrix[4]*matrix[9]*matrix[14]*matrix[3]-
	matrix[12]*matrix[9]*matrix[2]*matrix[7]+
	matrix[8]*matrix[13]*matrix[2]*matrix[7]+
	matrix[12]*matrix[1]*matrix[10]*matrix[7]-
	matrix[0]*matrix[13]*matrix[10]*matrix[7]-
	matrix[8]*matrix[1]*matrix[14]*matrix[7]+
	matrix[0]*matrix[9]*matrix[14]*matrix[7]+
	matrix[12]*matrix[5]*matrix[2]*matrix[11]-
	matrix[4]*matrix[13]*matrix[2]*matrix[11]-
	matrix[12]*matrix[1]*matrix[6]*matrix[11]+
	matrix[0]*matrix[13]*matrix[6]*matrix[11]+
	matrix[4]*matrix[1]*matrix[14]*matrix[11]-
	matrix[0]*matrix[5]*matrix[14]*matrix[11]-
	matrix[8]*matrix[5]*matrix[2]*matrix[15]+
	matrix[4]*matrix[9]*matrix[2]*matrix[15]+
	matrix[8]*matrix[1]*matrix[6]*matrix[15]-
	matrix[0]*matrix[9]*matrix[6]*matrix[15]-
	matrix[4]*matrix[1]*matrix[10]*matrix[15]+
	matrix[0]*matrix[5]*matrix[10]*matrix[15];
}

//
/// \ calculate the inverse of a 4x4 matrix
//
void 
ShaderUtils::inverseMatrix(float *matrix, float *result)
{
	float x=findDeterminant(matrix);
	if (x==0) return ;
	
	result[0]= (-matrix[13]*matrix[10]*matrix[7] +matrix[9]*matrix[14]*matrix[7] +matrix[13]*matrix[6]*matrix[11]
					  -matrix[5]*matrix[14]*matrix[11] -matrix[9]*matrix[6]*matrix[15] +matrix[5]*matrix[10]*matrix[15])/x;
	result[4]= ( matrix[12]*matrix[10]*matrix[7] -matrix[8]*matrix[14]*matrix[7] -matrix[12]*matrix[6]*matrix[11]
					  +matrix[4]*matrix[14]*matrix[11] +matrix[8]*matrix[6]*matrix[15] -matrix[4]*matrix[10]*matrix[15])/x;
	result[8]= (-matrix[12]*matrix[9]* matrix[7] +matrix[8]*matrix[13]*matrix[7] +matrix[12]*matrix[5]*matrix[11]
					  -matrix[4]*matrix[13]*matrix[11] -matrix[8]*matrix[5]*matrix[15] +matrix[4]*matrix[9]* matrix[15])/x;
	result[12]=( matrix[12]*matrix[9]* matrix[6] -matrix[8]*matrix[13]*matrix[6] -matrix[12]*matrix[5]*matrix[10]
					 +matrix[4]*matrix[13]*matrix[10] +matrix[8]*matrix[5]*matrix[14] -matrix[4]*matrix[9]* matrix[14])/x;
	result[1]= ( matrix[13]*matrix[10]*matrix[3] -matrix[9]*matrix[14]*matrix[3] -matrix[13]*matrix[2]*matrix[11]
					  +matrix[1]*matrix[14]*matrix[11] +matrix[9]*matrix[2]*matrix[15] -matrix[1]*matrix[10]*matrix[15])/x;
	result[5]= (-matrix[12]*matrix[10]*matrix[3] +matrix[8]*matrix[14]*matrix[3] +matrix[12]*matrix[2]*matrix[11]
					  -matrix[0]*matrix[14]*matrix[11] -matrix[8]*matrix[2]*matrix[15] +matrix[0]*matrix[10]*matrix[15])/x;
	result[9]= ( matrix[12]*matrix[9]* matrix[3] -matrix[8]*matrix[13]*matrix[3] -matrix[12]*matrix[1]*matrix[11]
					  +matrix[0]*matrix[13]*matrix[11] +matrix[8]*matrix[1]*matrix[15] -matrix[0]*matrix[9]* matrix[15])/x;
	result[13]=(-matrix[12]*matrix[9]* matrix[2] +matrix[8]*matrix[13]*matrix[2] +matrix[12]*matrix[1]*matrix[10]
					 -matrix[0]*matrix[13]*matrix[10] -matrix[8]*matrix[1]*matrix[14] +matrix[0]*matrix[9]* matrix[14])/x;
	result[2]= (-matrix[13]*matrix[6]* matrix[3] +matrix[5]*matrix[14]*matrix[3] +matrix[13]*matrix[2]*matrix[7]
					  -matrix[1]*matrix[14]*matrix[7] -matrix[5]*matrix[2]*matrix[15] +matrix[1]*matrix[6]* matrix[15])/x;
	result[6]= ( matrix[12]*matrix[6]* matrix[3] -matrix[4]*matrix[14]*matrix[3] -matrix[12]*matrix[2]*matrix[7]
					  +matrix[0]*matrix[14]*matrix[7] +matrix[4]*matrix[2]*matrix[15] -matrix[0]*matrix[6]* matrix[15])/x;
	result[10]=(-matrix[12]*matrix[5]* matrix[3] +matrix[4]*matrix[13]*matrix[3] +matrix[12]*matrix[1]*matrix[7]
					 -matrix[0]*matrix[13]*matrix[7] -matrix[4]*matrix[1]*matrix[15] +matrix[0]*matrix[5]* matrix[15])/x;
	result[14]=( matrix[12]*matrix[5]* matrix[2] -matrix[4]*matrix[13]*matrix[2] -matrix[12]*matrix[1]*matrix[6]
					 +matrix[0]*matrix[13]*matrix[6] +matrix[4]*matrix[1]*matrix[14] -matrix[0]*matrix[5]* matrix[14])/x;
	result[3]= ( matrix[9]* matrix[6]* matrix[3] -matrix[5]*matrix[10]*matrix[3] -matrix[9]* matrix[2]*matrix[7]
					  +matrix[1]*matrix[10]*matrix[7] +matrix[5]*matrix[2]*matrix[11] -matrix[1]*matrix[6]* matrix[11])/x;
	result[7]= (-matrix[8]*matrix[6]* matrix[3] +matrix[4]*matrix[10]*matrix[3] +matrix[8]* matrix[2]*matrix[7]
					  -matrix[0]*matrix[10]*matrix[7] -matrix[4]*matrix[2]*matrix[11] +matrix[0]*matrix[6]* matrix[11])/x;
	result[11]=( matrix[8]*matrix[5]* matrix[3] -matrix[4]*matrix[9]* matrix[3] -matrix[8]* matrix[1]*matrix[7]
					 +matrix[0]*matrix[9]* matrix[7] +matrix[4]*matrix[1]*matrix[11] -matrix[0]*matrix[5]* matrix[11])/x;
	result[15]=(-matrix[8]*matrix[5]* matrix[2] +matrix[4]*matrix[9]* matrix[2] +matrix[8]* matrix[1]*matrix[6]
					 -matrix[0]*matrix[9]* matrix[6] -matrix[4]*matrix[1]*matrix[10] +matrix[0]*matrix[5]* matrix[10])/x;
	
	//return TRUE;
}

// Initialise a shader
int
ShaderUtils::initShader(GLenum nShaderType, const char* pszSource)
{
    GLuint shader = glCreateShader(nShaderType);
    
    if (shader) {
        glShaderSource(shader, 1, &pszSource, NULL);
        glCompileShader(shader);
        GLint compiled = 0;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
        
        if (!compiled) {
            GLint infoLen = 0;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
            
            if (infoLen) {
                char* buf = new char[infoLen];
                glGetShaderInfoLog(shader, infoLen, NULL, buf);
                printf("Could not compile shader %d: %s\n", shader, buf);
                delete[] buf;
            }
        }
    }
    
    return shader;
}


// Create a shader program
int
ShaderUtils::createProgramFromBuffer(const char* pszVertexSource, const char* pszFragmentSource)
{
    GLuint program = 0;
    GLuint vertexShader = initShader(GL_VERTEX_SHADER, pszVertexSource);
    GLuint fragmentShader = initShader(GL_FRAGMENT_SHADER, pszFragmentSource);
    
    if (vertexShader && fragmentShader) {
        program = glCreateProgram();
        
        if (program) {
            glAttachShader(program, vertexShader);
            checkGlError("glAttachShader");
            glAttachShader(program, fragmentShader);
            checkGlError("glAttachShader");
            
            
            glLinkProgram(program);
            GLint linkStatus;
            glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
            
            if (!GL_TRUE == linkStatus) {
                GLint infoLen = 0;
                glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
                
                if (infoLen) {
                    char* buf = new char[infoLen];
                    glGetProgramInfoLog(program, infoLen, NULL, buf);
                    printf("Could not link program %d: %s\n", program, buf);
                    delete[] buf;
                }
            }
        }
    }
    
    return program;
}



