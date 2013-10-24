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

NSString* const STWTwitterManagerDidUpdateProfileNotification = @"STWTwitterManagerDidUpdateProfileNotification";
NSString* const STWTwitterManagerDidUpdateProfileBannerNotification = @"STWTwitterManagerDidUpdateProfileBannerNotification";
NSString* const STWTwitterManagerDidUpdateStatusesNotification = @"STWTwitterManagerDidUpdateStatusesNotification";

@interface STWTwitterManager ()
{
    NSDictionary*   _profileDict;
    NSDictionary*   _profileBannerDict;
    NSArray*        _statuses;
}

@end

@implementation STWTwitterManager

@synthesize profileDict = _profileDict;
@synthesize profileBannerDict = _profileBannerDict;
@synthesize statuses = _statuses;

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
    
    return self;
}

//--------------------------------------------------------------//
#pragma mark -- TWitter API --
//--------------------------------------------------------------//

- (void)requestWithScreenName:(NSString*)screenName
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
                
                // Request
                NSString*   urlString;
                NSURL*      url;
                SLRequest*  request;
                
                //
                // For to get profile Dict
                //
                urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@&include_entities=true", screenName];
                url = [NSURL URLWithString:urlString];
                request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
                [request setAccount:account];
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
                        _profileDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                        
                        if (_profileDict) {
#ifdef DEBUG
                            //                            NSLog(@"dict: %@", dict);
#endif
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // Post notification
                                [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidUpdateProfileNotification object:nil];
                            });
                        }
                        else {
#ifdef DEBUG
                            NSLog(@"error : %@", error);
#endif
                        }
                    }
                }];
                
                //
                // For to get profile banner Dict
                //
                urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/profile_banner.json?screen_name=%@", screenName];
                url = [NSURL URLWithString:urlString];
                request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
                [request setAccount:account];
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
                        _profileBannerDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                        
                        if (_profileBannerDict) {
#ifdef DEBUG
                            //                            NSLog(@"dict: %@", dict);
#endif
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // Post notification
                                [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidUpdateProfileBannerNotification object:nil];
                            });
                        }
                        else {
#ifdef DEBUG
                            NSLog(@"error : %@", error);
#endif
                        }
                    }
                }];
                
                //
                // For to get user timeline statuses
                //
                urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=%@&include_rts=true", screenName];
                url = [NSURL URLWithString:urlString];
                request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:nil];
                [request setAccount:account];
                [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error){
                    // Error
                    if (!responseData) {
#ifdef DEBUG
                        NSLog(@"%@", error);
#endif
                    }
                    // Convert data to json
                    else {
                        // Clear statuses
                        _statuses = nil;
                        
                        // Convert and get statuses
                        NSError*    error;
                        _statuses = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                        
                        if (_statuses && _statuses.count > 2) {
#ifdef DEBUG
                            //                            NSLog(@"_statuses : %@", _statuses);
#endif
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // Post notification
                                [[NSNotificationCenter defaultCenter] postNotificationName:STWTwitterManagerDidUpdateStatusesNotification object:nil];
                            });
                        }
                        else {
#ifdef DEBUG
                            NSLog(@"error : %@", error);
#endif
                        }
                    }
                }];
            }
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

@end
