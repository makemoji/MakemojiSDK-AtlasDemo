//
//  ATLMConversationViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Atlas/Atlas.h>
#import "ATLMApplicationController.h"

/**
 @abstract Subclass of the `ATLMConversationViewController`. Presents a user interface for displaying and sending messages.
 */
@interface ATLMConversationViewController : ATLConversationViewController <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate>

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMApplicationController *applicationController;

@end
