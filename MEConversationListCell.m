//
//  MEConverstaionListCell.m
//  Atlas Messenger
//
//  Created by steve on 3/14/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEConversationListCell.h"
#import "METextInputView.h"

@implementation MEConversationListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(BOOL)detectMakemojiMessage:(NSString *)message {
    
    NSString *pattern = @"[(.+?)";
    pattern = [NSString stringWithFormat: @"\\%@", pattern];
    pattern = [NSString stringWithFormat: @"%@\\", pattern];
    pattern = [NSString stringWithFormat: @"%@]", pattern];
    
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, message.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *totalMatches = [regex matchesInString:message options:NSMatchingReportProgress range:range];
    
    if (totalMatches.count > 0) {
        // possible message
        return YES;
    }
    
    return NO;
}

-(void)commonInit {
    self.messageView = [[MEMessageView alloc] initWithFrame:CGRectZero];
    self.messageView.autoresizingMask = UIViewAutoresizingNone;
    self.messageView.clipsToBounds = YES;
    [self.contentView addSubview:self.messageView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    UILabel * foundLabel = [self findLastMessageLabel];
    foundLabel.hidden = NO;
    if (self.isMakemojiText == YES) {
        if (self.messageView.subviews.count > 0) {
            foundLabel.hidden = YES;
            UIView * messageLabel = [self.messageView.subviews objectAtIndex:0];
            messageLabel.autoresizingMask = UIViewAutoresizingNone;
            self.messageView.frame = CGRectMake(30, 28.5, self.contentView.frame.size.width-70, 41);
            messageLabel.frame = CGRectMake(0, 0, self.messageView.frame.size.width, 40);
        }
    }
}

- (void)updateWithLastMessageText:(NSString *)lastMessageText {
    [super updateWithLastMessageText:lastMessageText];
    self.lastMessageText = lastMessageText;
    self.isMakemojiText = NO;
    if ([self detectMakemojiMessage:lastMessageText] == YES) {
        NSString * messageHTML = [METextInputView convertSubstituedToHTML:lastMessageText];
        UIColor * messageTextColor = self.lastMessageLabelColor;
        NSString * fontSize = [NSString stringWithFormat:@"font-size:%ipx;", 16];
        NSString * fontColor = [NSString stringWithFormat:@"color:%@;", [self hexStringFromColor:messageTextColor]];
        messageHTML = [messageHTML stringByReplacingOccurrencesOfString:@"font-size:16px;" withString:fontSize];
        messageHTML = [messageHTML stringByReplacingOccurrencesOfString:@"color:#000000;" withString:fontColor];
        self.isMakemojiText = YES;
        [self.messageView  setHTMLString:messageHTML];
    }

}

-(UILabel *)findLastMessageLabel {
    UILabel * foundLabel;
    for (id  view in self.contentView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel * sublabel = (UILabel *)view;
            if ([sublabel.text isEqualToString:self.lastMessageText]) {
                foundLabel = view;
            }
        }
    }
    return foundLabel;
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
