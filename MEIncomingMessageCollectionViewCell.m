//
//  MEIncomingMessageCollectionViewCell.m
//  Atlas Messenger
//
//  Created by steve on 3/7/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEIncomingMessageCollectionViewCell.h"
#import "ATLConstants.h"
#import "METextInputView.h"
#import "ATLIncomingMessageCollectionViewCell.h"
#import "ATLMessagingUtilities.h"

@implementation MEIncomingMessageCollectionViewCell

- (void)presentMessage:(LYRMessage *)message {
    self.bubbleView.backgroundColor = [[ATLIncomingMessageCollectionViewCell appearance] bubbleViewColor];
    LYRMessagePart *part = message.parts[0];
    
    if ([part.MIMEType isEqualToString:@"text/plain"]) {
        NSString * messageString = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        NSString * messageHTML = [METextInputView convertSubstituedToHTML:messageString];
        UIColor * messageTextColor = [[ATLIncomingMessageCollectionViewCell appearance] messageTextColor];
        NSString * fontSize = [NSString stringWithFormat:@"font-size:%ipx;", 16];
        NSString * fontColor = [NSString stringWithFormat:@"color:%@;", [self hexStringFromColor:messageTextColor]];
        messageHTML = [messageHTML stringByReplacingOccurrencesOfString:@"font-size:16px;" withString:fontSize];
        messageHTML = [messageHTML stringByReplacingOccurrencesOfString:@"color:#000000;" withString:fontColor];
        [self setHTMLString:messageHTML];
        messageString = nil;
        
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (!self.superview) { return; }
    
    self.avatarImageView.frame = CGRectMake(ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, 27, 27);
    if (self.avatarImageView.hidden == YES) { self.avatarImageView.frame = CGRectZero; }
    
    CGRect bounds = self.contentView.bounds;
    CGFloat maxBubbleWidth = ATLMaxCellWidth();
    CGFloat maxTextWidth = maxBubbleWidth - (ATLMessageBubbleLabelHorizontalPadding*2);
    CGFloat textWidth = maxTextWidth;
    CGFloat bubbleWidth = maxBubbleWidth;
    CGFloat leadIn = ATLMessageCellHorizontalMargin+self.avatarImageView.frame.size.width;
    UIView * internalView = (UIView *)[[self.messageView subviews] objectAtIndex:0];
    self.bubbleView.frame = CGRectMake(leadIn, 0, bubbleWidth, bounds.size.height);
    internalView.frame = CGRectMake(leadIn+ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, textWidth, self.contentView.frame.size.height);
    
}


@end