/*
 *  texture_support.h
 *  Volume
 *
 *  Created by Henrique Debarba on 25/10/2010.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

GLuint loadTexture(NSString *inFileName, int inWidth, int inHeight);
GLuint loadRAWTexture(NSString *inFileName, int inWidth, int inHeight, int inDepth);
