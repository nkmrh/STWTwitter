//
//  STWDetailController.h
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/21/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STWDetailController : UIViewController

// Property
@property (weak, nonatomic) id delegate;

// Outlets
@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UIImageView* profileImageView;
@property (weak, nonatomic) IBOutlet UITextView* textView;
@property (weak, nonatomic) IBOutlet UIImageView* imageView;

@end

@interface NSObject (STWDetailControllerDelegate)

- (void)detailControllerDidTouched:(STWDetailController*)controller;

@end