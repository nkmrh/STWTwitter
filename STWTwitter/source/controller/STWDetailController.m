//
//  STWDetailController.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/21/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWDetailController.h"
#import <CoreMotion/CoreMotion.h>
#import "AMBlurView.h"

#define DETAILCONTROLLER_MOTION_EFFECT_LAYER_LEVEL (2)

@interface STWDetailController ()
{
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
    
    // Create motion effects
    UIInterpolatingMotionEffect*    xAxis;
    UIInterpolatingMotionEffect*    yAxis;
    UIMotionEffectGroup*    group;
    xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0 * DETAILCONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0 * DETAILCONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    
    yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0 * DETAILCONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0 * DETAILCONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    
    group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    
    // Add motion
    [self.containerView addMotionEffect:group];
}

- (void)viewDidDisappear:(BOOL)animated
{
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
