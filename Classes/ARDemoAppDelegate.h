//
//  ARDemoAppDelegate.h
//  ARDemo
//
//  Created by Chris Greening on 10/10/2010.
//  CMG Research
//

#import <UIKit/UIKit.h>

@class ARDemoViewController;

@interface ARDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ARDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ARDemoViewController *viewController;

@end

