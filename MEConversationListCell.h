//
//  MEConverstaionListCell.h
//  Atlas Messenger
//
//  Created by steve on 3/14/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEMessageView.h"
#import "ATLConversationPresenting.h"
#import "ATLConversationTableViewCell.h"

@interface MEConversationListCell : ATLConversationTableViewCell <ATLConversationPresenting>
@property MEMessageView * messageView;
@property NSString * lastMessageText;
@property BOOL isMakemojiText;
@end
