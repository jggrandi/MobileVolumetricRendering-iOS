//
//  ARDemoViewController.m
//  ARDemo
//
//  Created by Chris Greening on 10/10/2010.
//  CMG Research
//

#import "ARDemoViewController.h"
#import "ImageUtils.h"
#import "ARView.h"

@interface ARDemoViewController()

-(void) startCameraCapture;
-(void) stopCameraCapture;

@end


@implementation ARDemoViewController

@synthesize arView;
@synthesize previewView;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self startCameraCapture];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Camera Capture Control

-(void) startCameraCapture {
	// start capturing frames
	// Create the AVCapture Session
	session = [[AVCaptureSession alloc] init];
	
	// create a preview layer to show the output from the camera
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
	previewLayer.frame = previewView.frame;
	[previewView.layer addSublayer:previewLayer];
	
	// Get the default camera device
	AVCaptureDevice* camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	// Create a AVCaptureInput with the camera device
	NSError *error=nil;
	AVCaptureInput* cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
	if (cameraInput == nil) {
		NSLog(@"Error to create camera capture:%@",error);
	}
	
	// Set the output
	AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	
	// create a queue to run the capture on
	dispatch_queue_t captureQueue=dispatch_queue_create("catpureQueue", NULL);
	
	// setup our delegate
	[videoOutput setSampleBufferDelegate:self queue:captureQueue];

	// configure the pixel format
	videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
									 nil];

	// and the size of the frames we want
	[session setSessionPreset:AVCaptureSessionPresetMedium];

	// Add the input and output
	[session addInput:cameraInput];
	[session addOutput:videoOutput];
	
	// Start the session
	[session startRunning];		
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	// only run if we're not already processing an image
	if(imageToProcess==NULL) {
		// this is the image buffer
		CVImageBufferRef cvimgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
		// Lock the image buffer
		CVPixelBufferLockBaseAddress(cvimgRef,0);
		// access the data
		int width=CVPixelBufferGetWidth(cvimgRef);
		int height=CVPixelBufferGetHeight(cvimgRef);
		// get the raw image bytes
		uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvimgRef);
		size_t bprow=CVPixelBufferGetBytesPerRow(cvimgRef);
		// turn it into something useful
		imageToProcess=createImage(buf, bprow, width, height);
		// trigger the image processing on the main thread
		[self performSelectorOnMainThread:@selector(processImage) withObject:nil waitUntilDone:NO];
	}
}


-(void) stopCameraCapture {
	[session stopRunning];
	[session release];
	session=nil;
}

#pragma mark -
#pragma mark Image processing
int centerX=100, centerY=100;
BOOL encontrado;
-(void) processImage {
	if(imageToProcess) {
		// move and scale the overlay view so it is on top of the camera image 
		// (the camera image will be aspect scaled to fit in the preview view)
		float scale=MIN(previewView.frame.size.width/imageToProcess->width, 
						previewView.frame.size.height/imageToProcess->height);
		arView.frame=CGRectMake((previewView.frame.size.width-imageToProcess->width*scale)/2,
									 (previewView.frame.size.height-imageToProcess->height*scale)/2,
									 imageToProcess->width, 
									 imageToProcess->height);
		arView.transform=CGAffineTransformMakeScale(scale, scale);
		
		
		// detect vertical lines
		CGMutablePathRef pathRef=CGPathCreateMutable();
		int lastX=-1000, lastY=-1000;
		int bigX=0, littleX=1000, bigY=0, littleY=1000;
		int startX, startY, endX, endY;
		if (encontrado==TRUE) {
			startX = MAX(1, centerX-100);
			startY = MAX(1, centerY-100);
			endX = MIN(imageToProcess->width-2, centerX+100);
			endY = MIN(imageToProcess->height-2, centerY+100);
		}else {
			startX = 1;
			startY = 1;
			endX = imageToProcess->width-2;
			endY = imageToProcess->height-2;
		}
		encontrado = FALSE;
		
		
		for(int y=startY; y<endY; y++) {
			for(int x=startX; x<endX; x++) {
		//for(int y=0; y<imageToProcess->height-1; y++) {
		//	for(int x=0; x<imageToProcess->width-1; x++) {
				/*int edge=(abs(imageToProcess->pixels[y][x]-imageToProcess->pixels[y][x+1])+
						  abs(imageToProcess->pixels[y][x]-imageToProcess->pixels[y+1][x])+
						  abs(imageToProcess->pixels[y][x]-imageToProcess->pixels[y+1][x+1]))/3;
				if(edge>10) {
				*/if (imageToProcess->pixels[y][x]==255){
					encontrado = TRUE;
					if (x>bigX)
						bigX=x;
					if (x<littleX)
						littleX=x;
					if (y>bigY)
						bigY=y;
					if (y<littleY)
						littleY=y;
								
				/*	int dist=(x-lastX)*(x-lastX)+(y-lastY)*(y-lastY);
					if(dist>50) {
						CGPathMoveToPoint(pathRef, NULL, x, y);
						lastX=x;
						lastY=y;
					} else if(dist>10) {
						CGPathAddLineToPoint(pathRef, NULL, x, y);
						lastX=x;
						lastY=y;
					}
				*/}
			}
		}	
		CGPathMoveToPoint(pathRef, NULL, littleX, littleY);
		CGPathAddLineToPoint(pathRef, NULL, bigX, littleY);
		CGPathAddLineToPoint(pathRef, NULL, bigX, bigY);
		CGPathAddLineToPoint(pathRef, NULL, littleX, bigY);
		CGPathAddLineToPoint(pathRef, NULL, littleX, littleY);
		centerX = littleX+(bigX-littleX)/2;
		centerY = littleY+(bigY-littleY)/2;
		
		// draw the path we've created in our ARView
		arView.pathToDraw=pathRef;
		
		// done with the image
		destroyImage(imageToProcess);
		imageToProcess=NULL;
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[self stopCameraCapture];
	self.previewView=nil;
}


- (void)dealloc {
	[self stopCameraCapture];
	self.previewView = nil;

	self.arView = nil;

    [super dealloc];
}

@end
