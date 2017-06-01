//
//  PinholeCamera.m
//  Volume
//
//  Created by Henrique on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PinholeCamera.h"



@implementation PinholeCamera


//orthogonal camera
- (BOOL)Create:(float)leftClippingPlaneCoord rightClip:(float)rightClippingPlaneCoord bottonClip:(float)bottomClippingPlaneCoord 
		topClip:(float)topClippingPlaneCoord nearDepth:(float) nearPlaneDepth farDepth:(float)farPlaneDepth 
	 windowWidth:(int)windowWidth windowHeight:(int)windowHeight
{
	m_projectionType = ORTHOGONAL_PROJECTION;
	
	m_cameraType = TRACKBALL_CAMERA;
	
	m_leftClippingPlaneCoord = leftClippingPlaneCoord;
	m_rightClippingPlaneCoord = rightClippingPlaneCoord;
	m_bottomClippingPlaneCoord = bottomClippingPlaneCoord;
	m_topClippingPlaneCoord = topClippingPlaneCoord;
	
	m_fieldOfView = 0.0f;
	
	m_nearPlaneDepth = nearPlaneDepth;
	m_farPlaneDepth = farPlaneDepth;
	
	m_viewport[0] = 0;
	m_viewport[1] = 0;
	m_viewport[2] = windowWidth;
	m_viewport[3] = windowHeight;
	
	m_pitchRotation = 0.0f;
	m_yawRotation = 0.0f;
	
	m_eyeVectorDisplacement = 0.0f;
	m_sideVectorDisplacement = 0.0f;
	m_upVectorDisplacement = 0.0f;
	
	[self ResetViewMatrix];
	[self CalculateProjectionMatrix];
	
	// It doesn't make any sense here.
	//ResetImagePlaneMatrix();
	
	return true;
}


//perspective camera
- (BOOL)Create:(float)fieldOfView nearPlaneDepth:(float)nearPlaneDepth farPlaneDepth:(float)farPlaneDepth 
   windowWidth:(int)windowWidth windowHeight:(int) windowHeight
{
	m_projectionType = PERSPECTIVE_PROJECTION;
	
	m_cameraType = TRACKBALL_CAMERA;
	//m_cameraType = FLYBY_CAMERA;
	
	m_leftClippingPlaneCoord = -1.0f;
	m_rightClippingPlaneCoord = 1.0f;
	m_bottomClippingPlaneCoord = -1.0f;
	m_topClippingPlaneCoord = 1.0f;
	
	m_fieldOfView = fieldOfView;
	
	m_nearPlaneDepth = nearPlaneDepth;
	m_farPlaneDepth = farPlaneDepth;
	
	m_viewport[0] = 0;
	m_viewport[1] = 0;
	m_viewport[2] = windowWidth;
	m_viewport[3] = windowHeight;
	
	m_pitchRotation = 0.0f;
	m_yawRotation = 0.0f;
	
	m_eyeVectorDisplacement = 0.0f;
	m_sideVectorDisplacement = 0.0f;
	m_upVectorDisplacement = 0.0f;
	
	[self ResetViewMatrix];
	[self CalculateProjectionMatrix];
	
	//discover what is a image plane matrix.... and why would i need one
	//CalculateImagePlaneMatrix();
	
	return true;	
	
}

//default create
- (void)Create
{
	m_projectionType = PERSPECTIVE_PROJECTION;
	
	m_cameraType = TRACKBALL_CAMERA;  
	
	m_leftClippingPlaneCoord = -1.0f;
	m_rightClippingPlaneCoord = 1.0f;
	m_bottomClippingPlaneCoord = -1.0f;
	m_topClippingPlaneCoord = 1.0f;
	
	m_fieldOfView = 45.0f;
	
	m_nearPlaneDepth = 1.0f;
	m_farPlaneDepth = 600.0f;
	
	m_viewport[0] = 0;
	m_viewport[1] = 0;
	m_viewport[2] = 360;
	m_viewport[3] = 480;
	
	m_pitchRotation = 0.0f;
	m_yawRotation = 0.0f;
	
	m_eyeVectorDisplacement = 0.0f;
	m_sideVectorDisplacement = 0.0f;
	m_upVectorDisplacement = 0.0f;
	
	[self ResetViewMatrix];
	[self CalculateProjectionMatrix];
	
	//ResetImagePlaneMatrix();
	
	m_centerOfProjection[0] = 0.0f;
	m_centerOfProjection[1] = 0.0f;
	m_centerOfProjection[2] = 0.0f;
}

- (void)ResetViewMatrix
{
	esMatrixLoadIdentity(&m_viewMatrix);
}

- (void)MoveFront:(float)step
{
	m_eyeVectorDisplacement += step;
}

- (void)MoveSide:(float)step
{
	m_sideVectorDisplacement += step;
}

- (void)MoveUp:(float)step
{
	m_upVectorDisplacement += step;
}

- (ESMatrix)ApplyTransform
{
	
	if (m_cameraType == TRACKBALL_CAMERA)
	{
		esTranslate(&m_viewMatrix, 
					m_sideVectorDisplacement*m_viewMatrix.m[0][0] + m_upVectorDisplacement*m_viewMatrix.m[0][1] + m_eyeVectorDisplacement*m_viewMatrix.m[0][2], 
					m_sideVectorDisplacement*m_viewMatrix.m[1][0] + m_upVectorDisplacement*m_viewMatrix.m[1][1] + m_eyeVectorDisplacement*m_viewMatrix.m[1][2], 
					m_sideVectorDisplacement*m_viewMatrix.m[2][0] + m_upVectorDisplacement*m_viewMatrix.m[2][1] + m_eyeVectorDisplacement*m_viewMatrix.m[2][2]);
		esRotate(&m_viewMatrix, m_pitchRotation, m_viewMatrix.m[0][0], m_viewMatrix.m[1][0], m_viewMatrix.m[2][0]);
		esRotate(&m_viewMatrix, m_yawRotation, m_viewMatrix.m[0][1], m_viewMatrix.m[1][1], m_viewMatrix.m[2][1]);

	}
	else if (m_cameraType == FLYBY_CAMERA)
	{
		m_centerOfProjection[0] = m_viewMatrix.m[0][0]*m_viewMatrix.m[3][0] + m_viewMatrix.m[0][1]*m_viewMatrix.m[3][1] + m_viewMatrix.m[0][2]*m_viewMatrix.m[3][2];
		m_centerOfProjection[1] = m_viewMatrix.m[1][0]*m_viewMatrix.m[3][0] + m_viewMatrix.m[1][1]*m_viewMatrix.m[3][1] + m_viewMatrix.m[1][2]*m_viewMatrix.m[3][2];
		m_centerOfProjection[2] = m_viewMatrix.m[2][0]*m_viewMatrix.m[3][0] + m_viewMatrix.m[2][1]*m_viewMatrix.m[3][1] + m_viewMatrix.m[2][2]*m_viewMatrix.m[3][2];
		
		esTranslate(&m_viewMatrix, -m_centerOfProjection[0], -m_centerOfProjection[1], -m_centerOfProjection[2]);
		
		esRotate(&m_viewMatrix, m_pitchRotation, m_viewMatrix.m[0][0], m_viewMatrix.m[1][0], m_viewMatrix.m[2][0]);
		esRotate(&m_viewMatrix, m_yawRotation, 0.0f, 1.0f, 0.0f);
		
		m_centerOfProjection[0] += m_sideVectorDisplacement*m_viewMatrix.m[0][0] + m_upVectorDisplacement*m_viewMatrix.m[0][1] + m_eyeVectorDisplacement*m_viewMatrix.m[0][2];
		m_centerOfProjection[1] += m_sideVectorDisplacement*m_viewMatrix.m[1][0] + m_upVectorDisplacement*m_viewMatrix.m[1][1] + m_eyeVectorDisplacement*m_viewMatrix.m[1][2];
		m_centerOfProjection[2] += m_sideVectorDisplacement*m_viewMatrix.m[2][0] + m_upVectorDisplacement*m_viewMatrix.m[2][1] + m_eyeVectorDisplacement*m_viewMatrix.m[2][2];
		
		esTranslate(&m_viewMatrix, m_centerOfProjection[0], m_centerOfProjection[1], m_centerOfProjection[2]);
	}
	
	m_pitchRotation = 0.0f;
	m_yawRotation = 0.0f;
	
	m_eyeVectorDisplacement = 0.0f;
	m_sideVectorDisplacement = 0.0f;
	m_upVectorDisplacement = 0.0f;
	
	return m_viewMatrix;
	
}

- (void)SetViewport:(int)x y:(int)y width:(int)width height:(int)height
{
	m_viewport[0] = x;
	m_viewport[1] = y;
	m_viewport[2] = width;
	m_viewport[3] = height;
	
	[self CalculateProjectionMatrix];	
}

- (void)Pitch:(float)angle
{
	m_pitchRotation += angle;	
}

- (void)Yaw:(float)angle
{
	m_yawRotation += angle;
}

- (ESMatrix)GetProjectionMatrix
{
	return m_projectionMatrix;
}
- (ESMatrix)GetViewMatrix
{
	return m_viewMatrix;
}

- (void)CalculateProjectionMatrix
{
	float viewportWidth,
	viewportHeight;
	float viewportAspect, 
	nearPlaneWidth,
	nearPlaneHeight,
	nearPlaneHorizontalMidpoint;
	
	esMatrixLoadIdentity(&m_projectionMatrix);
	
	viewportWidth = m_viewport[2] - m_viewport[0];
	viewportHeight = m_viewport[3] - m_viewport[1];
	
	viewportAspect = viewportWidth/viewportHeight;
	
	if (m_projectionType == PERSPECTIVE_PROJECTION){
		esPerspective(&m_projectionMatrix, m_fieldOfView, viewportAspect, m_nearPlaneDepth, m_farPlaneDepth);
	}
	else if (m_projectionType == ORTHOGONAL_PROJECTION)
	{
		nearPlaneHeight = m_topClippingPlaneCoord - m_bottomClippingPlaneCoord;
		nearPlaneWidth = nearPlaneHeight*viewportAspect;
		
		nearPlaneHorizontalMidpoint = 0.5f*(m_leftClippingPlaneCoord + m_rightClippingPlaneCoord);
		
		esOrtho(&m_projectionMatrix, nearPlaneHorizontalMidpoint - 0.5f*nearPlaneWidth, 
				nearPlaneHorizontalMidpoint + 0.5f*nearPlaneWidth, m_bottomClippingPlaneCoord, 
				m_topClippingPlaneCoord, m_nearPlaneDepth, m_farPlaneDepth);
	}
}

@end
