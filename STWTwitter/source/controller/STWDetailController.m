//
//  STWDetailController.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/21/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWDetailController.h"
#import <CoreMotion/CoreMotion.h>

@interface STWDetailController ()
{
    CMMotionManager*    _motionManager;
}

@property (weak, nonatomic) IBOutlet UIView* containerView;


@end

@implementation STWDetailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Invoke super
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Invoke super
    [super viewWillAppear:animated];
    
    // Start device motion update roll pitch yaw
    float   updateInterval = 0.01f;
//    float   size = 100;
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    if ([_motionManager isDeviceMotionAvailable] == YES) {
        [_motionManager setDeviceMotionUpdateInterval:updateInterval];
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion* deviceMotion, NSError* error) {
            // ContainerView
#if 0
            CMRotationMatrix    r;
            CATransform3D       t;
            r = deviceMotion.attitude.rotationMatrix;
            t = CATransform3DIdentity;
            t.m11=r.m11;    t.m12=r.m21;    t.m13=r.m31;    t.m14=0;
            t.m21=r.m12;    t.m22=r.m22;    t.m23=r.m32;    t.m24=0;
            t.m31=r.m13;    t.m32=r.m23;    t.m33=r.m33;    t.m34=0;
            t.m41=0;        t.m42=0;        t.m43=0;        t.m44=1;
            
            CATransform3D perspectiveTransform = CATransform3DIdentity;
            perspectiveTransform.m34 = 1.0 / -650;
            
            CATransform3D   newt;
            newt = CATransform3DIdentity;
            
            t = CATransform3DConcat(t, perspectiveTransform);
            
            t = CATransform3DConcat(t, CATransform3DMakeScale(1.0, 1.0, 1.0));
            t = CATransform3DConcat(t, CATransform3DMakeTranslation(0.0, 0.0, size));
            self.containerView.layer.transform = t;
#else
            // For tentative parallax effect
            CATransform3D   transform;
            transform = CATransform3DIdentity;
            
            CATransform3D perspectiveTransform;
            perspectiveTransform = CATransform3DIdentity;
            perspectiveTransform.m34 = 1.0 / -200;
            transform = CATransform3DConcat(transform, perspectiveTransform);
            
            transform = CATransform3DConcat(transform, CATransform3DMakeRotation(deviceMotion.attitude.pitch / -6, 0, 1, 0));
            transform = CATransform3DConcat(transform, CATransform3DMakeRotation(deviceMotion.attitude.roll / 6, 1, 0, 0));
            self.containerView.layer.transform = transform;
#endif
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Stop device motion update
    if ([_motionManager isDeviceMotionActive] == YES) {
        [_motionManager stopDeviceMotionUpdates];
    }
    
    // Invoke super
    [super viewDidDisappear:animated];
}

//--------------------------------------------------------------//
#pragma mark -- TapGesture --
//--------------------------------------------------------------//

- (IBAction)tapgesture:(id)sender {
    if ([self.delegate respondsToSelector:@selector(detailControllerDidTouched:)]) {
        [self.delegate detailControllerDidTouched:self];
    }
}


@end
