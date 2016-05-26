//
//  MEAtlasCollectionViewCell.m
//  Atlas Messenger
//
//  Created by steve on 2/27/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEOutgoingMessageCollectionViewCell.h"
#import "METextInputView.h"

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
    
    self.avatarImageView = [[ATLAvatarImageView alloc] init];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.hidden = YES;
    self.avatarImageView.frame = CGRectZero;
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView bringSubviewToFront:self.avatarImageView];
    
}

- (void)updateWithSender:(id<ATLParticipant>)sender {
    if (sender) {
        self.avatarImageView.hidden = NO;
        self.avatarImageView.avatarItem = sender;
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem {
    self.shouldDisplayAvatar = shouldDisplayAvatarItem;
}

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
    self.avatarImageView.frame = CGRectMake(self.contentView.frame.size.width-27-ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, 27, 27);
    if (!self.superview) { return; }
    if (self.shouldDisplayAvatar == NO) { self.avatarImageView.frame = CGRectZero; }
    CGFloat maxBubbleWidth = ATLMaxCellWidth() + (ATLMessageBubbleLabelHorizontalPadding*2);
    CGFloat textHeight = self.contentView.frame.size.height-(ATLMessageBubbleLabelVerticalPadding*2);
    CGSize textSize = [self.messageView suggestedSizeForTextForSize:CGSizeMake(ATLMaxCellWidth(), textHeight)];
    CGFloat bubbleWidth = maxBubbleWidth;
    textSize.width += (ATLMessageBubbleLabelHorizontalPadding * 2);
    if (textSize.width < maxBubbleWidth) { bubbleWidth = textSize.width; }

    CGFloat leadIn = self.contentView.frame.size.width - bubbleWidth - ATLMessageCellHorizontalMargin - self.avatarImageView.frame.size.width;

    self.bubbleView.frame = CGRectMake(leadIn, 0, bubbleWidth, self.contentView.frame.size.height);
    self.messageView.frame = CGRectMake(leadIn+ATLMessageBubbleLabelHorizontalPadding, ATLMessageBubbleLabelVerticalPadding, self.bubbleView.frame.size.width-(ATLMessageBubbleLabelVerticalPadding*2), self.bubbleView.frame.size.height-(ATLMessageBubbleLabelVerticalPadding*2));
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
