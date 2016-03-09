//
//  MEAtlasCollectionViewCell.h
//  Atlas Messenger
//
//  Created by steve on 2/27/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "MEMessageView.h"
#import "ATLMessagePresenting.h"
#import "MECollectionViewCell.h"
#import "ATLOutgoingMessageCollectionViewCell.h"

@interface MEOutgoingMessageCollectionViewCell : MECollectionViewCell <ATLMessagePresenting>
@property UIView * bubbleView;
- (NSString *)hexStringFromColor:(UIColor *)color;
@end
