/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <UIKit/UIKit.h>
#import "SampleAppMenu.h"
#import "VideoPlaybackEAGLView.h"
#import "SampleApplicationSession.h"
#import <QCAR/DataSet.h>

@interface VideoPlaybackViewController : UIViewController <SampleApplicationControl, SampleAppMenuCommandProtocol>{
    CGRect viewFrame;
    VideoPlaybackEAGLView* eaglView;
    QCAR::DataSet*  dataSet;
    SampleApplicationSession * vapp;
    
    BOOL fullScreenPlayerPlaying;
    
    UINavigationController * navController;
}

- (void)rootViewControllerPresentViewController:(UIViewController*)viewController inContext:(BOOL)currentContext;
- (void)rootViewControllerDismissPresentedViewController;

- (void) setNavigationController:(UINavigationController *) navController;
@end
