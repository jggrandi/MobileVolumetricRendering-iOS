
//
//  VolumeViewController.m
//  Volume
//
//  Created by Henrique Debarba on 25/10/2010.
//

#import <QuartzCore/QuartzCore.h>

#import "VolumeViewController.h"
#import "EAGLView.h"

#import "ShaderUtils.h"
#define MAKESTRING(x) #x
#import "../Shaders/Shader_Volume.fsh"
#import "../Shaders/Shader_Volume.vsh"

#import "texture_support.h"
#include "LookUpTable.h"
#include "wsg.h"
#include <sys/time.h>


@interface VolumeViewController ()
@property (nonatomic, retain) EAGLContext *context;

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
- (CGPoint)centerOfTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

@end

@implementation VolumeViewController

@synthesize animating, context;



- (void) InitTimeCounter
{
    gettimeofday(&tv0, NULL);
    framesPerFPS = 1;
}

- (void) UpdateTimeCounter
{
    gettimeofday(&tv, NULL);
    timeCounter = (float)(tv.tv_sec-tv0.tv_sec) + 0.000001*((float)(tv.tv_usec-tv0.tv_usec));
}

- (void) CalculateFPS
{
    frame ++;
    
    if((frame%framesPerFPS) == 0) 
    {
        //FPS = ((float)(framesPerFPS)) / (timeCounter-prevTime); // frames per second
        FPS = (timeCounter-prevTime); // time per frame
        prevTime = timeCounter; 
    } 
}

- (void)awakeFromNib
{
    
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!aContext)
    {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2) 
    {
		m_camera = [[PinholeCamera alloc] init];
		//Perspective view
		[m_camera Create:45.0 nearPlaneDepth:(float)2.0 farPlaneDepth:(float)600.0 windowWidth:(int)self.view.frame.size.width windowHeight:(int)self.view.frame.size.height];

		[m_camera MoveFront:0.0];
		projection = [m_camera GetProjectionMatrix];
		
	}
	InitializeLookUpTable(m_windowCenter, m_windowWidth);
	textureNormalId=createPreintegrationTable (m_lookUpTable);
	
	animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
	
	// create a cube
	nroIndices = esGenCube(1.0f, &cubeVertices, &cubeNormals, &cubeTexCoords, &cubeIndices, &cubeTangents);
	
	// load up a texture
	NSString *fileName = [[NSBundle mainBundle] pathForResource:  @"body01" ofType: @"raw"];
	textureId=loadRAWTexture(fileName, 512, 512, 43);	

    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
	
    zFiltering = false;
    preIntTable = false;
    frame = 1;
    prevTime = 0.0f;
    
    lowQVolumeShader = ShaderUtils::createProgramFromBuffer(vertexShader, lowQFragShader);
    
    medQPreIntTableVolumeShader = ShaderUtils::createProgramFromBuffer(vertexShader, mediumQPreIntTableFragShader);
    
    medQZFilterVolumeShader = ShaderUtils::createProgramFromBuffer(vertexShader, mediumQZFilterFragShader);
    
    highQVolumeShader = ShaderUtils::createProgramFromBuffer(vertexShader, highQFragShader);
    
	[self InitTimeCounter];
    
    //CGRect screenSize = [[UIScreen mainScreen] bounds];
    //NSLog(@"ScreenRes:%fx%f",screenSize.size.width,screenSize.size.height);
}

- (void)dealloc
{
    if (simpleProgram)
    {
        glDeleteProgram(simpleProgram);
        simpleProgram = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (simpleProgram)
    {
        glDeleteProgram(simpleProgram);
        simpleProgram = 0;
    }
	
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{

    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
			 */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

const int k=20;
int values[k];
int iii=0;
     
- (void)drawFrame
{	
    [self UpdateTimeCounter];
    
    
	[(EAGLView *)self.view setFramebuffer];
//	float quat_w = motionManager.deviceMotion.attitude.quaternion.w;
//	float quat_x = motionManager.deviceMotion.attitude.quaternion.x;
//	float quat_y = motionManager.deviceMotion.attitude.quaternion.y;
//	float quat_z = motionManager.deviceMotion.attitude.quaternion.z;
//	float norma = sqrt(quat_x*quat_x + quat_y*quat_y + quat_z*quat_z);
//	quat_x /= norma;
//	quat_y /= norma;
//	quat_z /= norma;
//	quat_w = acos(quat_w)*2*(180/3.14);
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glCullFace(GL_BACK);
	
    glClearColor(0.8f, 0.8f, 0.8f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2)
    {
		//[m_camera Yaw:5.0];
        //[m_camera Pitch:5.0];
		viewMatrix = [m_camera ApplyTransform];

		esMatrixLoadIdentity(&modelView);        // reset our modelview to identity
		esTranslate(&modelView, 0.0f , 0.0f, -4.5f); // configs para resolucao 480x320
		//esTranslate(&modelView, -0.3f , 0.3f, -6.0f);  // configs para resolucao nativa
        
		// rotate the triangle
		//esRotate(&modelView, rCube, 1.0, 1.0, 0.0);
		esMatrixMultiply(&modelView,&viewMatrix,&modelView);

		esRotate(&modelView, 180, 0, 1, 0);
		
		
        if(!zFiltering && !preIntTable)
            glUseProgram(lowQVolumeShader);
        else if(zFiltering && preIntTable)
        {
            glUseProgram(highQVolumeShader);
        }
        else if(zFiltering)
        {
            glUseProgram(medQZFilterVolumeShader);
        }
        
		esInverseMatrix(&modelViewInverse, &modelView);//get the modelView Inverse
		esMatrixMultiply(&mvp, &modelView, &projection );// create our new mvp matrix

        glUniformMatrix4fv(glGetUniformLocation(highQVolumeShader, "mvp"), 1, GL_FALSE, (const GLfloat*)&mvp.m[0][0]); 
        glUniformMatrix4fv(glGetUniformLocation(highQVolumeShader, "modelViewInverse"), 1, GL_FALSE, (const GLfloat*)&modelViewInverse.m[0][0]);
        glUniform1fv(glGetUniformLocation(highQVolumeShader, "sliceDistance"), 1, (const GLfloat*) &SPACING );
		
		// set the texture uniform
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, textureId);
		glUniform1i(glGetUniformLocation(highQVolumeShader, "volumeSampler"), 0);
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, textureNormalId);
		glUniform1i(glGetUniformLocation(highQVolumeShader, "lookupTableSampler"), 1);
	
		float eyeVector[3];
		eyeVector[0] = -modelView.m[0][2];
		eyeVector[1] = -modelView.m[1][2];
		eyeVector[2] = -modelView.m[2][2];
		//normalize
		float eyeVectorMagnitude = sqrt((eyeVector[0] * eyeVector[0]) + (eyeVector[1] * eyeVector[1]) + (eyeVector[2] * eyeVector[2]));
		eyeVector[0] = eyeVector[0]/eyeVectorMagnitude;
		eyeVector[1] = eyeVector[1]/eyeVectorMagnitude;
		eyeVector[2] = eyeVector[2]/eyeVectorMagnitude;
		//plot from wsg
		plot(eyeVector, &volumeVertices);
	
    }
    else
    {
		NSAssert(NO, @"You'll need to add your own code to do the ES 1.0 rendering...");
    }
	
    [(EAGLView *)self.view presentFramebuffer];

    [self CalculateFPS];
    
     
     values[iii] = FPS;
     iii++;
     if(iii==k)
     {
     iii=0;
     float result;
     for(int i=0;i<k;i++)
     {
     result = result+values[i];
     }
     result=result/k;
     NSLog(@"TimePerFrame:%f",result);
     }
     
    // NSLog(@"FPS:%f",FPS*1000);
 
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	
	float x = toPoint.x - fromPoint.x;
	float y = toPoint.y - fromPoint.y;
	
	return sqrt(x * x + y * y);
}
- (CGPoint)centerOfTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
	CGPoint centerPoint;
	centerPoint.x = (toPoint.x + fromPoint.x)*0.5;
	centerPoint.y = (toPoint.y + fromPoint.y)*0.5;
	
	return centerPoint;
}
// Handle the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	NSSet *allTouches = [event allTouches];
    zFiltering = false;
    preIntTable = false;
    SPACING = 0.05f;
    NSLog(@"TouchBegin");
	switch ([allTouches count])
	{
		case 1: 
        {
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint location = [touch locationInView:[self view]];
            //NSLog(@"Location x:%f,y:%f",location.x,location.y);
            CGRect screenSize = [[UIScreen mainScreen] bounds];
            //NSLog(@"ScreenRes:%fx%f",screenSize.size.width,screenSize.size.height);
            if(location.y < 50) 
                touchmode = WINDOW_CENTER;
            else if (location.y > screenSize.size.height -50)
                touchmode = WINDOW_WIDTH;
            else
                touchmode = ROTATE;
            
			
		} break;
		case 2: {
			//The image is being zoomed in or out.
			
			UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
			UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
			
			//Calculate the distance between the two fingers.
			initialDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:[self view]]
														   toPoint:[touch2 locationInView:[self view]]];
			
		} break;
	}
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//if([timer isValid])
	//	[timer invalidate];
    zFiltering = false;
    preIntTable = false;
    SPACING = 0.05f;
	NSSet *allTouches = [event allTouches];
	
	switch ([allTouches count])
	{
		case 1: {
			UITouch*			touch = [touches anyObject];//[[event touchesForView:self] anyObject];
			
			CGPoint location = [touch locationInView:(EAGLView *)self.view];
			CGPoint previousLocation = [touch previousLocationInView:(EAGLView *)self.view];
			
			CGPoint deltaDistVec = previousLocation;
			deltaDistVec.x -= location.x;
			deltaDistVec.y -= location.y;
			
			switch (touchmode) {	
					break;	
				case 	WINDOW_CENTER:
					m_windowCenter += deltaDistVec.x*10;
					InitializeLookUpTable(m_windowCenter, m_windowWidth);
					textureNormalId=createPreintegrationTable (m_lookUpTable);
					break;
				case 	WINDOW_WIDTH:
					m_windowWidth -= deltaDistVec.x;
					if (m_windowWidth<0)
						m_windowWidth=0;
					InitializeLookUpTable(m_windowCenter, m_windowWidth);
					textureNormalId=createPreintegrationTable (m_lookUpTable);
					break;
				case 	ROTATE:{
					
					[m_camera Pitch:(0.5*deltaDistVec.y)];
					[m_camera Yaw:(0.5*deltaDistVec.x)];
				}break;
				default:
					break;
			}
			

	//n             		m_windowCenter+=deltaDistVec.y;
	//		m_windowWidth+=deltaDistVec.x;
	//		InitializeLookUpTable(m_windowCenter, m_windowWidth);
	//		textureNormalId=createPreintegrationTable (m_lookUpTable);
			
		} break;
		case 2: {
			//The image is being zoomed in or out.
			
			UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
			UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
			
			//Calculate the distance between the two fingers.
			CGFloat finalDistance = [self distanceBetweenTwoPoints:[touch1 locationInView:[self view]]
														   toPoint:[touch2 locationInView:[self view]]];
			
			if (initialDistance >1.0)
			{
				CGFloat deltaDistance = finalDistance - initialDistance;
				[m_camera MoveFront:deltaDistance*0.01];
				initialDistance=finalDistance;
			}else
				initialDistance=finalDistance;
			
			//Calculate the distance between the two fingers.
			CGPoint centerOfTouch = [self centerOfTwoPoints:[touch1 locationInView:[self view]] toPoint:[touch2 locationInView:[self view]]];
			CGPoint centerOfPreviousTouch = [self centerOfTwoPoints:[touch1 previousLocationInView:[self view]] toPoint:[touch2 previousLocationInView:[self view]]];
			//CGPoint deltaCenterOfTouch = centerOfTouch - centerOfPreviousTouch;
			[m_camera MoveSide:(centerOfTouch.x-centerOfPreviousTouch.x)*0.01];
			[m_camera MoveUp:-(centerOfTouch.y-centerOfPreviousTouch.y)*0.01];
			//Check if zoom in or zoom out.
			/*if(initialDistance > finalDistance) {
				NSLog(@"Zoom Out");
			}
			else {
				NSLog(@"Zoom In");
			}*/
			
		} break;
	}
	
}
// Handles the end of a touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
     NSLog(@"TouchEnd");
	initialDistance=0.0; 
    zFiltering = TRUE;
    preIntTable = TRUE;
    SPACING = 0.01f;
}

@end
