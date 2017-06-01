//
//  PinholeCamera.h
//  Volume
//
//  Created by Henrique on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "esUtil.h"

enum ProjectionTypeEnum {
	PERSPECTIVE_PROJECTION,
	ORTHOGONAL_PROJECTION
};
enum CameraTypeEnum{
	TRACKBALL_CAMERA,
	FLYBY_CAMERA
};

enum ProjectionTypeEnum m_projectionType;
enum CameraTypeEnum m_cameraType;  

@interface PinholeCamera : NSObject {
	
//	enum ProjectionTypeEnum m_projectionType;
	enum CameraTypeEnum m_cameraType;  


	float m_leftClippingPlaneCoord;
	float m_rightClippingPlaneCoord;
	float m_bottomClippingPlaneCoord;
	float m_topClippingPlaneCoord;
	float m_fieldOfView;
	float m_nearPlaneDepth;
	float m_farPlaneDepth;
	int m_viewport[4];
	float m_pitchRotation;
	float m_yawRotation;
	float m_eyeVectorDisplacement;
	float m_sideVectorDisplacement;
	float m_upVectorDisplacement;
	ESMatrix m_viewMatrix;
	ESMatrix m_projectionMatrix;
	//float m_viewMatrix[16];
	//float m_projectionMatrix[16];
	float m_imagePlaneMatrix[9];
	float m_centerOfProjection[3];	
	
}



- (void)Create;
- (BOOL)Create:(float)leftClippingPlaneCoord rightClip:(float)rightClippingPlaneCoord bottonClip:(float)bottomClippingPlaneCoord 
		topClip:(float)topClippingPlaneCoord nearDepth:(float) nearPlaneDepth farDepth:(float)farPlaneDepth 
		windowWidth:(int)windowWidth windowHeight:(int)windowHeight;
- (BOOL)Create:(float) fieldOfView nearPlaneDepth:(float)nearPlaneDepth farPlaneDepth:(float)farPlaneDepth 
		windowWidth:(int)windowWidth windowHeight:(int) windowHeight;
- (void)ResetViewMatrix;
- (void)MoveFront:(float)step;
- (void)MoveSide:(float)step;
- (void)MoveUp:(float)step;
- (ESMatrix)ApplyTransform;
- (void)SetViewport:(int)x y:(int)y width:(int)width height:(int)height;
- (void)Pitch:(float)angle;
- (void)Yaw:(float)angle;
- (ESMatrix)GetProjectionMatrix;
- (ESMatrix)GetViewMatrix;
- (void)CalculateProjectionMatrix;

@end
