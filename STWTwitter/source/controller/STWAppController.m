//
//  STWAppDelegate.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/18/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWAppController.h"
#import <AVFoundation/AVFoundation.h>

@implementation STWAppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register default user name
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = @{@"username" : @"starwars"};
    [defaults registerDefaults:dict];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Prevent audio crash (http://stackoverflow.com/questions/19014012/sprite-kit-the-right-way-to-multitask)
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /// Prevent audio crash
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Resume audio
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end

@implementation UINavigationController (AutoRotate)

- (NSUInteger)supportedInterfaceOrientations{
    return UIDeviceOrientationPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
