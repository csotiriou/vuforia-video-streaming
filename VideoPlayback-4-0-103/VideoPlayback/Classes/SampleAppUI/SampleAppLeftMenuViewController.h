/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <UIKit/UIKit.h>

@class SampleAppSlidingMenuController;

@interface SampleAppLeftMenuViewController : UIViewController {
    id observer;
}

@property(nonatomic,retain) UITableView *tableView;

@property(nonatomic,assign) SampleAppSlidingMenuController *slidingMenuViewController;

- (void) updateMenu;

@end
