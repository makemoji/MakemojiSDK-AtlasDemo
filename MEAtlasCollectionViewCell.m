//
//  MEAtlasCollectionViewCell.m
//  Atlas Messenger
//
//  Created by steve on 2/27/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEAtlasCollectionViewCell.h"
#import "ATLConstants.h"

@implementation MEAtlasCollectionViewCell

- (void)updateWithSender:(id<ATLParticipant>)sender{return;}
- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem{return;}
- (void)presentMessage:(LYRMessage *)message {
    LYRMessagePart *part = message.parts[0];
    if([part.MIMEType isEqualToString:@"text/html"]) {
        NSString * html = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        [self setHTMLString:html];
        html = nil;
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.messageView.frame = CGRectMake(13, 8, self.contentView.frame.size.width-13, self.contentView.frame.size.height-8);
}


@end
