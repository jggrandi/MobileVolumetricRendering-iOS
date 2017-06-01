//
//  VolumeAppDelegate.h
//  Volume
//
//  Created by Henrique Debarba on 25/10/2010.
//

#import <UIKit/UIKit.h>

@class VolumeViewController;

@interface VolumeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    VolumeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet VolumeViewController *viewController;

@end

