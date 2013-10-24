//
//  STWTwitterManager.h
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/20/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const STWTwitterManagerDidUpdateProfileNotification;
extern NSString* const STWTwitterManagerDidUpdateProfileBannerNotification;
extern NSString* const STWTwitterManagerDidUpdateStatusesNotification;

@interface STWTwitterManager : NSObject

// Property
@property (nonatomic, readonly) NSDictionary* profileDict;
@property (nonatomic, readonly) NSDictionary* profileBannerDict;
@property (nonatomic, readonly) NSArray* statuses;

// Initialize
+ (STWTwitterManager*)sharedManager;

// Request
- (void)requestWithScreenName:(NSString*)screenName;

- (NSDictionary*)statusWithIndexPathRow:(NSInteger)row;

@end
