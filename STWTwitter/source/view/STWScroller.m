//
//  STWScroller.m
//  STWTwitter
//
//  Created by Nakamura Hajime on 10/20/13.
//  Copyright (c) 2013 Hajime Nakamura. All rights reserved.
//

#import "STWScroller.h"

@implementation STWScroller

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Notiry next responder
    [self.nextResponder touchesBegan: touches withEvent:event];
    
    // Invoke super
    [super touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Notiry next responder
    [self.nextResponder touchesMoved: touches withEvent:event];
    
    // Invoke super
    [super touchesMoved: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Notiry next responder
    [self.nextResponder touchesEnded: touches withEvent:event];
    
    // Invoke super
    [super touchesEnded: touches withEvent: event];
}

@end
