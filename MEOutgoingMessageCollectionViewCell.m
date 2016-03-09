//
//  MEAtlasCollectionViewCell.m
//  Atlas Messenger
//
//  Created by steve on 2/27/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEOutgoingMessageCollectionViewCell.h"
#import "ATLConstants.h"
#import "METextInputView.h"
#import "ATLOutgoingMessageCollectionViewCell.h"
#import "ATLMessagingUtilities.h"

@implementation MEOutgoingMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self meCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self meCommonInit];
    }
    return self;
}

-(void)meCommonInit {
    self.bubbleView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bubbleView.layer.cornerRadius = 16;
    [self.contentView addSubview:self.bubbleView];
    [self.contentView sendSubviewToBack:self.bubbleView];
}


- (void)updateWithSender:(id<ATLParticipant>)sender { return; }
- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem { return; }
- (void)presentMessage:(LYRMessage *)message {
    self.bubbleView.backgroundColor = [[ATLOutgoingMessageCollectionViewCell appearance] bubbleViewColor];
    LYRMessagePart *part = message.parts[0];

    if ([part.MIMEType isEqualToString:@"text/plain"]) {
        NSString * messageString = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        NSString * messageHTML = [METextInputView convertSubstituedToHTML:messageString];
        UIColor * messageTextColor = [[ATLOutgoingMessageCollectionViewCell appearance] messageTextColor];
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

    CGRect bounds = self.contentView.bounds;
    CGFloat maxBubbleWidth = ATLMaxCellWidth();
    CGFloat maxTextWidth = maxBubbleWidth - (ATLMessageBubbleLabelHorizontalPadding*2);
    CGFloat textWidth = maxTextWidth;
    CGFloat bubbleWidth = maxBubbleWidth;
    CGFloat leadIn = self.contentView.frame.size.width - maxBubbleWidth - ATLMessageCellHorizontalMargin;
    UIView * internalView = (UIView *)[[self.messageView subviews] objectAtIndex:0];
    self.bubbleView.frame = CGRectMake(leadIn, 0, bubbleWidth, bounds.size.height);
    internalView.frame = CGRectMake(leadIn+ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, textWidth, self.contentView.frame.size.height);

}

- (NSString *)hexStringFromColor:(UIColor *)color {
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r, g, b, a;
    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    }
    else if (colorSpace == kCGColorSpaceModelRGB) {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
