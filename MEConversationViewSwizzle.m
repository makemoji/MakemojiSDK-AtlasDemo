//
//  Swizzle.m
//  Atlas Messenger
//
//  Created by steve on 2/27/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEConversationViewSwizzle.h"
#import "JRSwizzle.h"

@implementation ATLConversationView (Tracking)

+ (void)initialize {
    [super initialize];
    [self jr_swizzleMethod:@selector(canBecomeFirstResponder)
                withMethod:@selector(SNcanBecomeFirstResponder)
                     error:nil];
}

- (BOOL)SNcanBecomeFirstResponder {
    return NO;
}



@end

