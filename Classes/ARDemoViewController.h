//
//  ARDemoViewController.h
//  ARDemo
//
//  Created by Chris Greening on 10/10/2010.
//  CMG Research
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageUtils.h"

@class ARView;

@interface ARDemoViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *session;
	UIView *previewView;
	ARView *arView;
	Image *imageToProcess;
}

@property (nonatomic, retain) IBOutlet UIView *arView;
@property (nonatomic, retain) IBOutlet UIView *previewView;

@end

