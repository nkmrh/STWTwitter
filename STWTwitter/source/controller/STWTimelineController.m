//
//  STWTimelineController.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/18/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWTimelineController.h"
#import <Social/Social.h>
#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "STWConfigController.h"
#import "STWTwitterManager.h"
#import "STWDetailController.h"
#import "AMBlurView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define TEXTLABEL_FONT ([UIFont fontWithName:@"Helvetica-Bold" size:13])
#define DETAIL_TEXTLABEL_FONT ([UIFont fontWithName:@"Helvetica" size:11])
#define VIEW_SCALE (0.98f)
#define ANIMATION_SPEED (0.2f)
#define TIMELINECONTROLLER_MOTION_EFFECT_LAYER_LEVEL (1)

//#define SOUND_ON
#define ENABLE_PARSPECTIVE

@interface STWTimelineController ()
{
    AVAudioPlayer*      _audioPlayer;
    UIView*             _tableHeaderView;
}

// Property
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet SKView* spaceView;
@property (weak, nonatomic) IBOutlet UIScrollView* scroller;
@property (weak, nonatomic) IBOutlet UIImageView* profileBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView* profileImageView;
@property (weak, nonatomic) IBOutlet UILabel* userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* userScreenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* userDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView* userUrlTextView;

@end

@implementation STWTimelineController

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)dealloc
{
    // Unregister as observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//--------------------------------------------------------------//
#pragma mark -- View --
//--------------------------------------------------------------//

- (void)viewDidLoad
{
    // Invoke super
    [super viewDidLoad];
    
    // Set modal presentation style current context
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    // Configure to search bar display in navigation bar
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
    // Create bar button item
    self.searchDisplayController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(pressComposeButtonAction:)];
    
    
    // Get user name
    NSString*   userName;
    userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    // Request Get method for user infomations
    [[STWTwitterManager sharedManager] requestWithScreenName:userName];
    
    // Configure views appearance
    [self _configureViews];
    
#ifdef SOUND_ON
    // Play audio
    [self _playAudio];
#endif
    
    // Register notification
    NSNotificationCenter*   center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(twitterManagerDidUpdateProfile:) name:STWTwitterManagerDidUpdateProfileNotification object:nil];
    [center addObserver:self selector:@selector(twitterManagerDidUpdateProfileBanner:) name:STWTwitterManagerDidUpdateProfileBannerNotification object:nil];
    [center addObserver:self selector:@selector(twitterManagerDidUpdateProfileStatuses:) name:STWTwitterManagerDidUpdateStatusesNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Invoke super
    [super prepareForSegue:segue sender:sender];
}

//--------------------------------------------------------------//
#pragma mark -- Appearance --
//--------------------------------------------------------------//

- (void)_configureViews
{
    //
    // Space view
    SKScene*        spaceScene;
    NSString*       spaceEmitterPath;
    SKEmitterNode*  spaceEmitter;
    
    // Create scene
    spaceScene = [SKScene sceneWithSize:self.spaceView.frame.size];
    spaceScene.backgroundColor = [UIColor clearColor];
    
    // Add particle
    spaceEmitterPath = [[NSBundle mainBundle] pathForResource:@"spaceParticle" ofType:@"sks"];
    spaceEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:spaceEmitterPath];
    spaceEmitter.position = CGPointMake(CGRectGetMidX(self.spaceView.frame), CGRectGetMidY(self.spaceView.frame) + 100);
    [spaceScene addChild:spaceEmitter];
    
    // Present scene
    [self.spaceView presentScene:spaceScene];
    
    //
    // Space view layer
    self.spaceView.layer.zPosition = -100;
    
    //
    // Table view layer
#ifdef ENABLE_PARSPECTIVE
    CATransform3D   transform;
    transform = CATransform3DIdentity;
    transform.m34 = 1.0/ -100;
    transform = CATransform3DTranslate(transform, 0, -50, 0);
    transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(30.0f), 1, 0, 0);
    self.tableView.layer.transform = transform;
#endif
    
    //
    // Profile image view
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.cornerRadius = 8.0f;
    self.profileImageView.layer.borderWidth = 2.0f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // Add motion effects
    [self _addMotionEffects];
}

//--------------------------------------------------------------//
#pragma mark -- Private --
//--------------------------------------------------------------//

- (void)_addMotionEffects
{
    //
    // Create motion effects
    UIInterpolatingMotionEffect*    xAxis;
    UIInterpolatingMotionEffect*    yAxis;
    UIMotionEffectGroup*    group;
    xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0 * TIMELINECONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0 * TIMELINECONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    
    yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0 * TIMELINECONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0 * TIMELINECONTROLLER_MOTION_EFFECT_LAYER_LEVEL];
    
    group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    
    // Add motion
    [self.profileImageView addMotionEffect:group];
    [self.userNameLabel addMotionEffect:group];
    [self.userScreenNameLabel addMotionEffect:group];
    [self.userDescriptionLabel addMotionEffect:group];
    [self.userUrlTextView addMotionEffect:group];
}

- (void)_reloadData
{
    // Reload table view
    [self.tableView reloadData];
    
    // Update scroll view content size
    CGSize  size;
    size = self.tableView.contentSize;
    size.height += 550;
    self.scroller.contentSize = size;
    
}

- (void)_updateProfile
{
    NSDictionary*   profileDict;
    NSString*       path;
    NSURL*          url;
    NSData*         imageData;
    UIImage*        image;
    profileDict = [STWTwitterManager sharedManager].profileDict;
    path = [profileDict objectForKey:@"profile_image_url"];
    path = [path stringByReplacingOccurrencesOfString:@"_normal" withString:@"_reasonably_small"];
    url = [NSURL URLWithString:path];
    imageData = [NSData dataWithContentsOfURL:url];
    image = [UIImage imageWithData:imageData];
    self.profileImageView.image = image;
    
    // Set user name
    self.userNameLabel.text = [profileDict objectForKey:@"name"];
    
    // Set user screen name
    self.userScreenNameLabel.text = [NSString stringWithFormat:@"@%@",[profileDict objectForKey:@"screen_name"]];
    
    // Set user description
    self.userDescriptionLabel.text = [profileDict objectForKey:@"description"];
    
    // Set user url
    if (![[profileDict objectForKey:@"url"] isKindOfClass:[NSNull class]]) {
        self.userUrlTextView.text = [profileDict objectForKey:@"url"];
    }
}

- (void)_updateProfileBanner
{
    NSDictionary*   bannerDict;
    NSString*       path;
    NSURL*          url;
    NSData*         imageData;
    UIImage*        image;
    bannerDict = [STWTwitterManager sharedManager].profileBannerDict;
    path = [[[bannerDict objectForKey:@"sizes"] objectForKey:@"mobile_retina"] objectForKey:@"url"];
    url = [NSURL URLWithString:path];
    imageData = [NSData dataWithContentsOfURL:url];
    image = [UIImage imageWithData:imageData];
    self.profileBackgroundImageView.image = image;
}

- (NSString*)_userNameAtIndexPathRow:(NSInteger)row
{
    // Get status
    NSDictionary*    status;
    status = [[STWTwitterManager sharedManager] statusWithIndexPathRow:row];
    
    if ([status objectForKey:@"retweeted_status"] != nil) {
        // For retweet
        return [[[status objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"name"];
    }
    
    return [[status objectForKey:@"user"] objectForKey:@"name"];
}

- (NSString*)_statusTextAtIndexPathRow:(NSInteger)row
{
    // Get status
    NSDictionary*    status;
    status = [[STWTwitterManager sharedManager] statusWithIndexPathRow:row];
    
    if ([status objectForKey:@"retweeted_status"] != nil) {
        // For retweet
        return [[status objectForKey:@"retweeted_status"] objectForKey:@"text"];
    }
    
    return [status objectForKey:@"text"];
}

- (NSString*)_userImagePathAtIndexPathRow:(NSInteger)row
{
    // Get status
    NSDictionary*    status;
    status = [[STWTwitterManager sharedManager] statusWithIndexPathRow:row];
    
    if ([status objectForKey:@"retweeted_status"] != nil) {
        // For retweet
        return [[[status objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"profile_image_url"];
    }
    
    return [[status objectForKey:@"user"] objectForKey:@"profile_image_url"];
}



//--------------------------------------------------------------//
#pragma mark -- Audio --
//--------------------------------------------------------------//

- (void)_playAudio
{
    // Get mp3 file path
    NSString*   filePath;
    NSURL*      fileUrl;
    filePath = [[NSBundle mainBundle] pathForResource:@"star_wars_theme" ofType:@"mp3"];
    fileUrl = [NSURL fileURLWithPath:filePath];

    // Create audio player
    NSError* error = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
    if(!error) {
        // Play
        [_audioPlayer prepareToPlay];
        _audioPlayer.numberOfLoops = -1;
        [_audioPlayer play];
    } else {
#ifdef DEBUG
        NSLog(@"AVAudioPlayer Error");
#endif
    }
}

//--------------------------------------------------------------//
#pragma mark -- Table view data source --
//--------------------------------------------------------------//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[STWTwitterManager sharedManager].statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure cell
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 4.0f;
    cell.imageView.layer.borderWidth = 1.0f;
    cell.imageView.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    cell.selected = NO;
    cell.highlighted = NO;
    
    static UIView* backgroundView;
    if (!backgroundView) {
        backgroundView = [[UIView alloc] init] ;
        backgroundView.backgroundColor = [UIColor colorWithRed:37 / 255.0f green:165 / 255.0f blue:255 / 255.0f alpha:0.5f];
    }
    cell.selectedBackgroundView = backgroundView;
    
    // Configure labels
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = TEXTLABEL_FONT;
    cell.detailTextLabel.font = DETAIL_TEXTLABEL_FONT;
    cell.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    // Set name
    cell.textLabel.text = [self _userNameAtIndexPathRow:indexPath.row];
    
    // Set text
    cell.detailTextLabel.text = [self _statusTextAtIndexPathRow:indexPath.row];
    
    // Get user image path
    NSString* path;
    path = [self _userImagePathAtIndexPathRow:indexPath.row];
    
    // Configure icon image view
    NSURL*      url;
    NSData*     imageData;
    UIImage*    image;
    url = [NSURL URLWithString:path];
    imageData = [NSData dataWithContentsOfURL:url];
    image = [UIImage imageWithData:imageData];
    cell.imageView.image = image;
    
    return cell;
}

//--------------------------------------------------------------//
#pragma mark -- Table view delegate --
//--------------------------------------------------------------//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"indexPath.row : %d", indexPath.row);
    
    // Get status
    NSDictionary*   status;
    status = [[STWTwitterManager sharedManager].statuses objectAtIndex:indexPath.row];
//    NSLog(@"status : %@", status);
    
    // Get text
    NSString*   text;
    text = [status objectForKey:@"text"];
    
    // Get media
    NSDictionary*   entities;
    NSArray*        media;
    NSString*       mediaType;
    NSString*       mediaUrlString;
    UIImage*        image;
    NSData*         imageData;
    entities = [status objectForKey:@"entities"];
    media = [entities objectForKey:@"media"];
    
    if (media.count > 0) {
        // Get item
        NSDictionary*   item;
        item = [media objectAtIndex:0];
        
        // Get media type
        mediaType = [item objectForKey:@"type"];
        
        // Get media url string
        if ([mediaType isEqualToString:@"photo"]) {
            mediaUrlString = [item objectForKey:@"media_url"];
            
            // Get image
            imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:mediaUrlString]];
            image = [UIImage imageWithData:imageData];
        }
    }
    
    // Create detail controller
    UIStoryboard*           storyboard;
    STWDetailController*    detailController;
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    detailController = [storyboard instantiateViewControllerWithIdentifier:@"detailController"];
    detailController.delegate = self;
    [detailController loadView];
    detailController.view.frame = [[UIScreen mainScreen] bounds];
    detailController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Check media count
    if (media.count == 0) {
        // Adjust y position
        CGRect    rect;
        rect = detailController.profileImageView.frame;
        rect.origin = CGPointMake(rect.origin.x, 100);
        detailController.profileImageView.frame = rect;
        
        rect = detailController.textView.frame;
        rect.origin = CGPointMake(rect.origin.x, 100);
        detailController.textView.frame = rect;
    }
    
    CATransform3D  transform;
    transform = CATransform3DIdentity;
    transform.m34 = 1.0/ -100;
    detailController.view.layer.transform = transform;
    detailController.view.layer.zPosition = 1000;
    detailController.imageView.image = image;
    
    // Get proile image
    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self _userImagePathAtIndexPathRow:indexPath.row]]];
    image = [UIImage imageWithData:imageData];
    detailController.profileImageView.image = image;
    
    // Get name
    NSString*   textViewString;
    NSString*   name;
    name = [self _userNameAtIndexPathRow:indexPath.row];
    textViewString = [NSString stringWithFormat:@"%@\n%@", name, text];
    detailController.textView.text = textViewString;
    detailController.view.alpha = 0.0f;
    detailController.textView.textColor = [UIColor whiteColor];
    
    // Present modal because disable touch event under view
    detailController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:detailController animated:NO completion:nil];
    
    // Scale animation
    detailController.view.transform = CGAffineTransformMakeScale(VIEW_SCALE, VIEW_SCALE);
    
    // Implement block for setViewTypeAnimation
    void (^animation) (void);
    void (^completion) (BOOL finished);
    animation = ^ {
        detailController.view.alpha = 1.0f;
        detailController.view.transform = CGAffineTransformIdentity;
    };
    completion = ^(BOOL finished) {
        // Do nothing
    };
    
    // Do animation
    [UIView animateWithDuration:ANIMATION_SPEED delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Calc height
    float   width = 200.0f;
    float   minHeight = 80.0f;
    CGRect  rect1, rect2;
    NSDictionary*   attributes;
    
    // For textlabel
    attributes = @{NSFontAttributeName : TEXTLABEL_FONT};
    rect1 = [[self _userNameAtIndexPathRow:indexPath.row] boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    // For detail textlabel
    attributes = @{NSFontAttributeName : DETAIL_TEXTLABEL_FONT};
    rect2 = [[self _statusTextAtIndexPathRow:indexPath.row] boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    // Decide height
    return MAX(rect1.size.height + rect2.size.height, minHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (!_tableHeaderView) {
            // Create table header view
            _tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
            _tableHeaderView.backgroundColor = [UIColor clearColor];
        }
        return _tableHeaderView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return 250.0f;
    }
    else {
        return 0.0f;
    }
}

//--------------------------------------------------------------//
#pragma mark -- UIScrollViewDelegate --
//--------------------------------------------------------------//

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update content offset
    self.tableView.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Unhighlit for visible cells
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [cell setHighlighted:NO animated:NO];
    }
    // Clear index path
    willSelectIndexPath = nil;
}

//--------------------------------------------------------------//
#pragma mark -- Touch --
//--------------------------------------------------------------//

static NSIndexPath* willSelectIndexPath = nil;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get point
    CGPoint point;
    point = [[touches anyObject] locationInView:self.tableView];
    
    // Search cell at point
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        // For contain cell
        if (CGRectContainsPoint(cell.frame, point)) {
            // Highliting
            [cell setHighlighted:YES animated:YES];
            
            // Save index path
            willSelectIndexPath = [self.tableView indexPathForCell:cell];
            
            break;
        }
        else {
            // Unhighlit for find cell
            [cell setHighlighted:NO animated:NO];
        }
    }
    
    // Invoke super
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get point
    CGPoint point;
    point = [[touches anyObject] locationInView:self.tableView];
    
    // Unhighlit for visible cells
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [cell setHighlighted:NO animated:NO];
    }
    
    // Clear index path
    willSelectIndexPath = nil;
    
    // Invoke super
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Get point
    CGPoint point;
    point = [[touches anyObject] locationInView:self.tableView];
    
    // Search cell on point
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        if (CGRectContainsPoint(cell.frame, point)) {
            // For contain cell
            // Check whether tap or not
            if (willSelectIndexPath &&
                willSelectIndexPath.row == [self.tableView indexPathForCell:cell].row) {
                
                // Unhighlit for find cell
                [cell setHighlighted:NO animated:YES];
                
                // Call delegate method
                [self tableView:self.tableView didSelectRowAtIndexPath:willSelectIndexPath];
                
                // Clear index path
                willSelectIndexPath = nil;
            }
        }
        else {
            // Unhighlit for find cell
            [cell setHighlighted:NO animated:NO];
        }
    }
    
    // Clear index path
    willSelectIndexPath = nil;
    
    // Invoke super
    [super touchesEnded:touches withEvent:event];
}

//--------------------------------------------------------------//
#pragma mark -- Action --
//--------------------------------------------------------------//

- (IBAction)pressComposeButtonAction:(id)sender {
    // Show compose view
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        // Create compose view controller
        SLComposeViewController*   composeController;
        composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        // Prepare completion handler
        void (^completion) (SLComposeViewControllerResult result) = ^(SLComposeViewControllerResult result){
            // Dismiss compose view controller
            [composeController dismissViewControllerAnimated:YES completion:Nil];
            
            // Get user name
            NSString*   userName;
            userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            
            // Request
            [[STWTwitterManager sharedManager] requestWithScreenName:userName];
        };
        
        // Set completion handler
        [composeController setCompletionHandler:completion];
        
        // Show compose view by modal
        [self presentViewController:composeController animated:YES completion:nil];
    }
}

- (IBAction)pressSettingButtonAction:(id)sender {
    UIStoryboard*           storyboard;
    UINavigationController* navController;
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    navController = [storyboard instantiateViewControllerWithIdentifier:@"configNavController"];

    STWConfigController* controller;
//    controller = (STWConfigController*)navController.topViewController;
//    controller = [storyboard instantiateViewControllerWithIdentifier:@"configController"];
//    controller.view.backgroundColor = [UIColor clearColor];
//    navController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:navController animated:YES completion:nil];
}

//--------------------------------------------------------------//
#pragma mark -- STWTwitterManagerDidUpdateProfileNotification --
//--------------------------------------------------------------//

- (void)twitterManagerDidUpdateProfile:(NSNotification*)notification
{
    // Update
    [self _updateProfile];
}

//--------------------------------------------------------------//
#pragma mark -- STWTwitterManagerDidUpdateProfileBannerNotification --
//--------------------------------------------------------------//

- (void)twitterManagerDidUpdateProfileBanner:(NSNotification*)notification
{
    // Update
    [self _updateProfileBanner];
}

//--------------------------------------------------------------//
#pragma mark -- STWTwitterManagerDidUpdateStatusesNotification --
//--------------------------------------------------------------//

- (void)twitterManagerDidUpdateProfileStatuses:(NSNotification*)notification
{
    [self _reloadData];
}

//--------------------------------------------------------------//
#pragma mark -- STWDetailControllerDelegate --
//--------------------------------------------------------------//

- (void)detailControllerDidTouched:(STWDetailController *)controller
{
    // Implement block for setViewTypeAnimation
    void (^animation) (void);
    void (^completion) (BOOL finished);
    animation = ^ {
        controller.view.alpha = 0.0f;
        controller.view.transform = CGAffineTransformMakeScale(VIEW_SCALE, VIEW_SCALE);
    };
    completion = ^(BOOL finished) {
        // Dissmiss modal
        [controller dismissViewControllerAnimated:NO completion:nil];
    };
    
    // Do animation
    [UIView animateWithDuration:ANIMATION_SPEED delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:animation completion:completion];
}

//--------------------------------------------------------------//
#pragma mark -- UISearchDisplayDelegate --
//--------------------------------------------------------------//

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.contentInset = UIEdgeInsetsZero;
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

@end
