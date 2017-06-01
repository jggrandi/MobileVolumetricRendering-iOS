//
//  VolumeViewController.h
//  Volume
//
//  Created by Henrique Debarba on 25/10/2010.
//

#import <UIKit/UIKit.h>

#import <CoreMotion/CoreMotion.h>
#import <CoreMotion/CMAttitude.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "PinholeCamera.h"

#import "esUtil.h"

@interface VolumeViewController : UIViewController
{
	
	CMMotionManager *motionManager;
	PinholeCamera *m_camera;
	// data to draw
	GLfloat *volumeVertices;
	GLfloat *cubeVertices;
	GLfloat *cubeNormals;
	GLfloat *cubeTangents;
	GLfloat *cubeTexCoords;
	GLushort *cubeIndices;
	GLuint textureId;
	GLuint textureNormalId;
	// angle for rotations
	float rCube;
    EAGLContext *context;
    GLuint simpleProgram;
	GLuint uniformMvp;
	GLuint uniformModelView;
	GLuint uniformModelViewInverse;
	GLuint uniformView;
	GLuint uniformTexture;
	GLuint uniformTextureNormal;
	GLuint uniformSliceDistance;
	
    BOOL zFiltering;
    BOOL preIntTable;

	int nroIndices;
	
    float timeCounter, prevTime, FPS;
    int frame, framesPerFPS;
    struct timeval tv;
    struct timeval tv0;
    
    unsigned int highQVolumeShader;
    unsigned int medQZFilterVolumeShader;
    unsigned int medQPreIntTableVolumeShader;
    unsigned int lowQVolumeShader;
    
    
	ESMatrix viewMatrix;
	ESMatrix modelView;
	ESMatrix modelViewInverse;
	ESMatrix projection;
	ESMatrix mvp;
	ESMatrix orientationTest;
	
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    /*
	 Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	 CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	 The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
	 */
    id displayLink;
    NSTimer *animationTimer;
	
	CGFloat initialDistance;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;

@end
