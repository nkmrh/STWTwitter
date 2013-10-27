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
extern NSString* const STWTwitterManagerDidFilterdUsersNotification;

@interface STWTwitterManager : NSObject

// Property
@property (nonatomic) NSString* userName;
@property (nonatomic, readonly) NSDictionary* profileDict;
@property (nonatomic, readonly) NSDictionary* profileBannerDict;
@property (nonatomic, readonly) NSArray* statuses;
@property (nonatomic, readonly) NSArray* filterdUsers;

// Initialize
+ (STWTwitterManager*)sharedManager;

// Twitter API access
- (void)updateProfileDict;
- (void)updateProfileBannerDict;
- (void)updateUserTimelineStatuses;
- (void)updateFilterdUsersForSearchName:(NSString*)name;

- (NSDictionary*)statusWithIndexPathRow:(NSInteger)row;
- (NSDictionary*)filterdUserStatusWithIndexPathRow:(NSInteger)row;

@end
