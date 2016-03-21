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
    self.avatarImageView.frame = CGRectMake(ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, 27, 27);
    if (!self.superview) { return; }
    if (self.shouldDisplayAvatar == NO) { self.avatarImageView.frame = CGRectZero; }
    
    CGFloat leadIn = ATLMessageCellHorizontalMargin+self.avatarImageView.frame.size.width;
    
    self.bubbleView.frame = CGRectMake(leadIn, 0, self.bubbleView.frame.size.width, self.bubbleView.frame.size.height);
    self.messageView.frame = CGRectMake(leadIn+ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, self.messageView.frame.size.width, self.messageView.frame.size.height);

}


@end