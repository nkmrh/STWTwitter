//
//  STWTwitterManager.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/20/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWTwitterManager.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "STWAppController.h"

NSString* const STWTwitterManagerDidUpdateProfileNotification = @"STWTwitterManagerDidUpdateProfileNotification";
NSString* const STWTwitterManagerDidUpdateProfileBannerNotification = @"STWTwitterManagerDidUpdateProfileBannerNotification";
NSString* const STWTwitterManagerDidUpdateStatusesNotification = @"STWTwitterManagerDidUpdateStatusesNotification";
NSString* const STWTwitterManagerDidFilterdUsersNotification = @"STWTwitterManagerDidFilterdUsersNotification";

@interface STWTwitterManager ()
{
    NSDictionary*       _profileDict;
    NSDictionary*       _profileBannerDict;
    NSMutableArray*     _statuses;
    NSString*           _maxId;
    NSString*           _userName;
    NSMutableArray*     _filterdUsers;
    NSString*           _prevFilterdName;
}

@end

@implementation STWTwitterManager

@synthesize profileDict = _profileDict;
@synthesize profileBannerDict = _profileBannerDict;
@synthesize statuses = _statuses;
@synthesize userName = _userName;
@synthesize filterdUsers = _filterdUsers;

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

static STWTwitterManager*  _sharedInstance = nil;

+ (STWTwitterManager*)sharedManager
{
    // Create instance
    if (!_sharedInstance) {
        _sharedInstance = [[STWTwitterManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // Create mutable array
    _filterdUsers = [NSMutableArray array];
    
    return self;
}

//--------------------------------------------------------------//
#pragma mark -- Property --
//--------------------------------------------------------------//

- (void)setUserName:(NSString*)name
{
    // Set user name
    _userName = name;
    
    // Clear instances
    [_statuses removeAllObjects];
    _statuses = nil;
    
    // Save to user default
    NSUserDefaults* defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:STWUserNameDefaultKey];
    
    // Update
    [self updateProfileDict];
    [self updateProfileBannerDict];
    [self updateUserTimelineStatuses];
}

//--------------------------------------------------------------//
#pragma mark -- Private --
//--------------------------------------------------------------//

- (void)_updateUserTimelineStatusesWithAccount:(ACAccount*)account
{
    //
    // For to get user timeline statuses
    //
    NSString*   urlString;
    if (!_statuses) {
        // Create statuses
        _statuses = [NSMutableArray array];
        
        // Create request
        urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@&include_rts=true&count=20", self.userName];
    }
    else {
        // Create request specify max_id
        urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@&include_rts=true&count=21&max_id=%@", self.userName, _maxId];
    }
    
    NSURL*          url;
    SLRequest*      request;
    url = [NSURL URLWithString:urlString];
    request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
    [request setAccount:account];
    
    // Show network activity indicator
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error){
        // Error
        if (!responseData) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
        // Convert data to json
        else {
            // Convert and get statuses
            NSArray*    statuses;
            NSError*    error;
            statuses = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            
            if ([statuses isKindOfClass:[NSArray class]] && statuses && statuses.count > 2) {
#ifdef DEBUG
                //                            NSLog(@"_statuses : %@", _statuses);
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Set max_id
                    NSDictionary*   lastStatus;
                    lastStatus = [statuses lastObject];
                    _maxId = [lastStatus objectForKey:@"id_str"];
                    
                    NSMutableArray* array = [NSMutableArray array];
                    [array addObjectsFromArray:statuses];
                    
                    // Remove overlaped status
                    if (_statuses.count != 0) {
                        [array removeObjectAtIndex:0];
                    }
                    
                    // Append objects
                    [_statuses addObjectsFromArray:array];
                });
            }
            else {
#ifdef DEBUG
                NSLog(@"error : %@", error);
                NSLog(@"%s : %d", __PRETTY_FUNCTION__, __LINE__);
#endif
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Hide network activity indicator
            app.networkActivityIndicatorVisible = NO;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidUpdateStatusesNotification object:nil];
        });
    }];
}

- (void)_updateProfileDictWithAccount:(ACAccount*)account
{
    //
    // For to get profile Dict
    //
    NSString*       urlString;
    NSURL*          url;
    SLRequest*      request;
    urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@&include_entities=true", self.userName];
    url = [NSURL URLWithString:urlString];
    request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
    [request setAccount:account];
    
    // Show network activity indicator
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error){
        // Error
        if (!responseData) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
        // Convert data to json
        else {
            // Convert and get statuses
            NSDictionary*   dict;
            NSError*        error;
            dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            
            if (dict) {
#ifdef DEBUG
                //                            NSLog(@"dict: %@", dict);
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Save dict
                    _profileDict = dict;
                });
            }
            else {
#ifdef DEBUG
                NSLog(@"error : %@", error);
#endif
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Hide network activity indicator
            app.networkActivityIndicatorVisible = NO;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidUpdateProfileNotification object:nil];
        });
    }];
}

- (void)_updateProfileBannerDictWithAccount:(ACAccount*)account
{
    //
    // For to get profile banner Dict
    //
    NSString*       urlString;
    NSURL*          url;
    SLRequest*      request;
    urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/profile_banner.json?screen_name=%@", self.userName];
    url = [NSURL URLWithString:urlString];
    request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
    [request setAccount:account];
    
    // Show network activity indicator
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error){
        // Error
        if (!responseData) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
        // Convert data to json
        else {
            // Convert and get statuses
            NSError*        error;
            NSDictionary*   dict;
            dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            
            if (dict) {
#ifdef DEBUG
                //                            NSLog(@"dict: %@", dict);
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Save dict
                    _profileBannerDict = dict;
                });
            }
            else {
#ifdef DEBUG
                NSLog(@"error : %@", error);
#endif
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Hide network activity indicator
            app.networkActivityIndicatorVisible = NO;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidUpdateProfileBannerNotification object:nil];
        });
    }];
}

- (void)_updateFilterdUsersForSearchName:(NSString*)name withAccount:(ACAccount*)account page:(int)page count:(int)count;
{
    //
    // For to get filterd users
    //
    
    NSString*       urlString;
    NSURL*          url;
    SLRequest*      request;
    NSString*       encodedString;
    
    encodedString = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/search.json?q=%@&count=%d&page=%d", encodedString, count, page];
    url = [NSURL URLWithString:urlString];
    request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
    [request setAccount:account];
    
    // Show network activity indicator
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error){
        // Error
        if (!responseData) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
        // Convert data to json
        else {
            
            // Convert and get statuses
            NSArray*    array;
            NSError*    error;
            array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            
            if ([array isKindOfClass:[NSArray class]] && array && array.count > 0) {
#ifdef DEBUG
                //                            NSLog(@"dict: %@", dict);
#endif
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Add objects
                    [_filterdUsers addObjectsFromArray:array];
                });
            }
            else {
#ifdef DEBUG
                NSLog(@"error : %@", error);
#endif
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Hide network activity indicator
            app.networkActivityIndicatorVisible = NO;
            
            // Keep filterd name
            _prevFilterdName = name;
            
            // Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidFilterdUsersNotification object:nil];
        });
    }];
}

//--------------------------------------------------------------//
#pragma mark -- TWitter API access --
//--------------------------------------------------------------//

- (void)updateUserTimelineStatuses
{
    //
    // Check twitter account
    ACAccountStore* accountStore;
    ACAccountType*  twitterAccountType;
    accountStore = [[ACAccountStore alloc] init];
    twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            // Get twitter accounts
            NSArray*    twitterAccounts;
            twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            
            if ([twitterAccounts count] > 0) {
                // Get first account
                ACAccount*  account;
                account = [twitterAccounts objectAtIndex:0];
                
                // Update statuses
                [self _updateUserTimelineStatusesWithAccount:account];
            }
        }
        else {
#ifdef DEBUG
            NSLog(@"error : %@", error);
#endif
        }
    }];
}

- (void)updateProfileDict
{
    //
    // Check twitter account
    ACAccountStore* accountStore;
    ACAccountType*  twitterAccountType;
    accountStore = [[ACAccountStore alloc] init];
    twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            // Get twitter accounts
            NSArray*    twitterAccounts;
            twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            
            if ([twitterAccounts count] > 0) {
                // Get first account
                ACAccount*  account;
                account = [twitterAccounts objectAtIndex:0];
                
                // Update profile dict
                [self _updateProfileDictWithAccount:account];
            }
        }
        else {
#ifdef DEBUG
            NSLog(@"error : %@", error);
#endif
        }
    }];
}

- (void)updateProfileBannerDict
{
    //
    // Check twitter account
    ACAccountStore* accountStore;
    ACAccountType*  twitterAccountType;
    accountStore = [[ACAccountStore alloc] init];
    twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            // Get twitter accounts
            NSArray*    twitterAccounts;
            twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            
            if ([twitterAccounts count] > 0) {
                // Get first account
                ACAccount*  account;
                account = [twitterAccounts objectAtIndex:0];
                
                // Update profile banner dict
                [self _updateProfileBannerDictWithAccount:account];
            }
        }
        else {
#ifdef DEBUG
            NSLog(@"error : %@", error);
#endif
        }
    }];
}

- (void)updateFilterdUsersForSearchName:(NSString*)name
{
    //
    // Check twitter account
    ACAccountStore* accountStore;
    ACAccountType*  twitterAccountType;
    accountStore = [[ACAccountStore alloc] init];
    twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if (![name isEqualToString:_prevFilterdName]) {
        // Clear objects
        [_filterdUsers removeAllObjects];
    }
    
    // Culc page
    int page;
    int count = 15;
    page = ([_filterdUsers count] / count) + 1;
    
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            // Get twitter accounts
            NSArray*    twitterAccounts;
            twitterAccounts = [accountStore accountsWithAccountType:twitterAccountType];
            
            if ([twitterAccounts count] > 0) {
                // Get first account
                ACAccount*  account;
                account = [twitterAccounts objectAtIndex:0];
                
                // Update filterd users
                [self _updateFilterdUsersForSearchName:name withAccount:account page:page count:count];
            }
        }
        else {
#ifdef DEBUG
            NSLog(@"error : %@", error);
#endif
        }
    }];
}

- (NSDictionary*)statusWithIndexPathRow:(NSInteger)row
{
    if (_statuses.count > 2) {
        return [_statuses objectAtIndex:row];
    }
    
    return nil;
}

- (NSDictionary*)filterdUserStatusWithIndexPathRow:(NSInteger)row
{
    if (_filterdUsers.count > 0) {
        return [_filterdUsers objectAtIndex:row];
    }
    
    return nil;
}

@end
