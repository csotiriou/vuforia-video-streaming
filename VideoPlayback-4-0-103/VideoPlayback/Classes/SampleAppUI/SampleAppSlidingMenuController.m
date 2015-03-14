/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
Confidential and Proprietary - Qualcomm Connected Experiences, Inc.
Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import "SampleAppSlidingMenuController.h"
#import "SampleAppLeftMenuViewController.h"

// the duration of the animation to display the menu
static const CGFloat kSlidingMenuSlideDuration = 0.3;

#define MAX_PAN_VELOCITY 600

// shadow properties
#define SHADOW_OPACITY 0.8f
#define SHADOW_RADIUS_CORNER 3.0f

#define ANIMATION_DURATION .3

@interface SampleAppSlidingMenuController ()
- (void)setRootViewControllerShadow:(BOOL)val;

@property(nonatomic,retain) SampleAppLeftMenuViewController *menuViewController;
@property(nonatomic,retain) UIViewController *rootViewController;

@end

@implementation SampleAppSlidingMenuController

@synthesize menuViewController=_menuViewController;
@synthesize rootViewController=_rootViewController;

- (id)initWithRootViewController:(UIViewController*) controller {
    if ((self = [super init])) {
        self.rootViewController = controller;
        // the left view controller is the menu associated to the application
        SampleAppLeftMenuViewController *  mvc =[[SampleAppLeftMenuViewController alloc] init];
        self.menuViewController = mvc;
        self.menuViewController.slidingMenuViewController = self;
        [mvc release];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];

        kSlidingMenuWidth = screenBounds.size.width * 0.85;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dismiss)
                                                     name:@"kMenuDismissViewController"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showMenu)
                                                     name:@"show_menu"
                                                   object:nil];
        ignoreDoubleTap = NO;

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_menuViewController release];
    _menuViewController = nil;
    [_rootViewController release];
    _rootViewController = nil;
    [super dealloc];
}

- (void) shouldIgnoreDoubleTap {
    ignoreDoubleTap = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)isIpad{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // add the view associated to the root view controller
    UIView *view = self.rootViewController.view;
    view.frame = self.view.bounds;
    [self.view addSubview:view];
    
    // pan recognizer to display the menu
    panGestureRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)] autorelease];
    panGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [view addGestureRecognizer:panGestureRecognizer];
    
    // double tap used to also trigger the menu
    UITapGestureRecognizer *doubleTap = NULL;
    if (! ignoreDoubleTap) {
        doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapGestureAction:)] autorelease];
        doubleTap.numberOfTapsRequired = 2;
        [self.view addGestureRecognizer:doubleTap];
    }
    
    // tap to dismiss the menu
    tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)] autorelease];
    tapGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer setEnabled:NO];
    if (doubleTap != NULL) {
        [tapGestureRecognizer requireGestureRecognizerToFail:doubleTap];
    }
    
    // we pass the navigation conroller to the VideoPlaybackViewController - this will be needed
    // to play the video fullscreen
    [self.rootViewController performSelector:@selector(setNavigationController:) withObject:self.navigationController afterDelay:0];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    tapGestureRecognizer = nil;
    panGestureRecognizer = nil;
}

- (void)panGestureAction:(UIPanGestureRecognizer*)gesture {
    
    // direction of the pan movement
    enum {PAN_LEFT, PAN_RIGHT}  panDirection;

    // the x motion gives the orientation of the pan gesture
    if([gesture velocityInView:self.view].x > 0) {
        panDirection = PAN_RIGHT;
    } else {
        panDirection = PAN_LEFT;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (panDirection == PAN_RIGHT) {
            [self setRootViewControllerShadow:YES];
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (panDirection == PAN_RIGHT) {
            // we update the position of the root controller
            CGPoint translation = [gesture translationInView:self.view];
            CGRect frame = self.rootViewController.view.frame;
            frame.origin.x = translation.x;
            
            // if frame has moved, we display the menu
            if (frame.origin.x > 0.0f && !showingLeftMenu) {
                showingLeftMenu = YES;
                CGRect frame = self.view.bounds;
                frame.size.width = kSlidingMenuWidth;
                self.menuViewController.view.frame = frame;
                [self.menuViewController updateMenu];
                [self.view insertSubview:self.menuViewController.view atIndex:0];
            }
            self.rootViewController.view.frame = frame;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self.view setUserInteractionEnabled:NO];
        
        // at the end of the gesture, we will display either the root view or the menu view.
        enum { DISPLAY_ROOT, DISPLAY_MENU } completion;
        
        if (panDirection == PAN_RIGHT && showingLeftMenu) {
            // if the left menu is being displayed and we have a right motion,
            // then we display the left menu
            completion = DISPLAY_MENU;
        } else {
            completion = DISPLAY_ROOT;
        }
        
        CGFloat width = self.rootViewController.view.frame.size.width;
        CGFloat spanMenu = kSlidingMenuWidth;
        CGFloat duration = kSlidingMenuSlideDuration;
        
        // we prepare the menu animation
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (completion == DISPLAY_MENU) {
                [self showLeftMenu:NO];
            } else {
                [self showRootController:NO];
            }
            [self.rootViewController.view.layer removeAllAnimations];
            [self.view setUserInteractionEnabled:YES];
        }];
        
        // we setup an animation to have a smooth animation
        CGPoint pos = self.rootViewController.view.layer.position;
        
        // we move the frame for the animation
        CAKeyframeAnimation *frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        frameAnimation.fillMode = kCAFillModeForwards;
        frameAnimation.duration = duration;
        frameAnimation.removedOnCompletion = NO;
        
        NSMutableArray *animationValues = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
        
        // the reference point of the animation
        // is the center of the screen
        CGFloat widthref = (width/2);
        [animationValues addObject:[NSValue valueWithCGPoint:pos]];
        if (completion == DISPLAY_MENU) {
            [animationValues addObject:[NSValue valueWithCGPoint:CGPointMake(widthref + spanMenu, pos.y)]];
        } else {
            [animationValues addObject:[NSValue valueWithCGPoint:CGPointMake(widthref, pos.y)]];
        }
        
        // we set the farme positions for the animation
        frameAnimation.values = animationValues;
        [self.rootViewController.view.layer addAnimation:frameAnimation forKey:nil];

        // we trigger the animation
        [CATransaction commit];
    }    
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == panGestureRecognizer) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        // the pan gesture is accepted is accepted if the velocity is below a max value
        return ([panGesture velocityInView:self.view].x < MAX_PAN_VELOCITY);
    } else if (gestureRecognizer == tapGestureRecognizer) {
        // tap is accepted if we tap in the root view controller while the
        // left menu is displayed
        if (showingLeftMenu) {
            return CGRectContainsPoint(self.rootViewController.view.frame, [gestureRecognizer locationInView:self.view]);
        }
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // only the tap gesture accepts a simultaneous gesture
    return (tapGestureRecognizer == gestureRecognizer);
}

- (void)tapGestureAction:(UITapGestureRecognizer*) theGesture {
    [theGesture setEnabled:NO];
    [self showRootController:YES];
}

- (void)doubleTapGestureAction:(UITapGestureRecognizer*)theGesture {
    if (!showingLeftMenu) {
        [self showLeftMenu:YES];
    }
}

- (void)setRootViewControllerShadow:(BOOL) displayShadow {
    if (displayShadow) {
        self.rootViewController.view.layer.shadowOpacity = SHADOW_OPACITY;
        self.rootViewController.view.layer.cornerRadius = SHADOW_RADIUS_CORNER;
        self.rootViewController.view.layer.shadowRadius = SHADOW_RADIUS_CORNER;
        self.rootViewController.view.layer.shadowOffset = CGSizeZero;
        // use of a bezier path for the shadow around the view
        self.rootViewController.view.layer.shadowPath =
            [UIBezierPath bezierPathWithRect:self.rootViewController.view.bounds].CGPath;
    } else {
        // no shadow
        self.rootViewController.view.layer.shadowOpacity = 0.0f;
    }
}

- (void)showRootController:(BOOL)animated {
    
    [tapGestureRecognizer setEnabled:NO];
    self.rootViewController.view.userInteractionEnabled = YES;

    CGRect frame = self.rootViewController.view.frame;
    frame.origin.x = 0.0f;

    // keep track of the state of the animations
    BOOL animationEnabled = [UIView areAnimationsEnabled];
    if (!animated) {
        [UIView setAnimationsEnabled:NO];
    }

    // the animation will position the root view controller to its final frame position
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.rootViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        // at the end, we remove the menu
        // from its superview to make it disappear
        if (self.menuViewController && self.menuViewController.view.superview) {
            [self.menuViewController.view removeFromSuperview];
        }
        showingLeftMenu = NO;
        [self setRootViewControllerShadow:NO];
    }];
    
    if (!animated) {
        // restore the state of the animations
        [UIView setAnimationsEnabled:animationEnabled];
    }
    
}

- (void)showLeftMenu:(BOOL)animated {
    showingLeftMenu = YES;
    [self setRootViewControllerShadow:YES];

    // compute sizes of different frames for the animation
    UIView *view = self.menuViewController.view;
	CGRect frame = self.view.bounds;
	frame.size.width = kSlidingMenuWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    [self.menuViewController viewWillAppear:animated];
    
    frame = self.rootViewController.view.frame;
    frame.origin.x = kSlidingMenuWidth;
    
    // keep track of the state of the animations
    BOOL animationEnabled = [UIView areAnimationsEnabled];
    if (!animated) {
        [UIView setAnimationsEnabled:NO];
    }
    
    // perform the animation
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.rootViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        [tapGestureRecognizer setEnabled:YES];
    }];
    
    if (!animated) {
        // restore the state of the animations
        [UIView setAnimationsEnabled:animationEnabled];
    }
    
}

- (void) dismiss {
    // dismiss the controller by going back to the root
    // of the navigation controller
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) showMenu {
    if (!showingLeftMenu) {
        [self showLeftMenu:YES];
    }
}

//------------------------------------------------------------------------------
#pragma mark - Autorotation
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
