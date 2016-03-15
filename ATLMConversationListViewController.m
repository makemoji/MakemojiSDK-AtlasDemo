//
//  ATLMConversationListViewController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/29/14.
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

#import "ATLMConversationListViewController.h"
#import "ATLMUser.h"
#import "ATLMConversationViewController.h"
#import "ATLMSettingsViewController.h"
#import "ATLMConversationDetailViewController.h"
#import "ATLMNavigationController.h"
#import "ATLMParticipantDataSource.h"
#import "ATLMSplitViewController.h"
#import "MEConversationListCell.h"

@interface ATLMConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource, ATLMSettingsViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) ATLMParticipantDataSource *participantDataSource;

@end

@implementation ATLMConversationListViewController

NSString *const ATLMConversationListTableViewAccessibilityLabel = @"Conversation List Table View";
NSString *const ATLMSettingsButtonAccessibilityLabel = @"Settings Button";
NSString *const ATLMComposeButtonAccessibilityLabel = @"Compose Button";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.accessibilityLabel = ATLMConversationListTableViewAccessibilityLabel;
    self.tableView.isAccessibilityElement = YES;
    self.delegate = self;
    self.dataSource = self;
    self.allowsEditing = YES;
    self.cellClass = [MEConversationListCell class];
    
    // Left navigation item
    UIButton* infoButton= [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *infoItem  = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [infoButton addTarget:self action:@selector(settingsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    infoButton.accessibilityLabel = ATLMSettingsButtonAccessibilityLabel;
    [self.navigationItem setLeftBarButtonItem:infoItem];
    
    // Right navigation item
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped)];
    composeButton.accessibilityLabel = ATLMComposeButtonAccessibilityLabel;
    [self.navigationItem setRightBarButtonItem:composeButton];
    
    self.participantDataSource = [ATLMParticipantDataSource participantDataSourceWithPersistenceManager:self.applicationController.persistenceManager];
    
    [self registerNotificationObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ATLConversationListViewControllerDelegate

/**
 Atlas - Informs the delegate of a conversation selection. Atlas Messenger pushses a subclass of the `ATLConversationViewController`.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    [self presentControllerWithConversation:conversation];
}

/**
 Atlas - Informs the delegate a conversation was deleted. Atlas Messenger does not need to react as the superclass will handle removing the conversation in response to a deletion.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation Successfully Deleted");
}

/**
 Atlas - Informs the delegate that a conversation deletion attempt failed. Atlas Messenger does not do anything in response.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Conversation Deletion Failed with Error: %@", error);
}

/**
 Atlas - Informs the delegate that a search has been performed. Atlas messenger queries for, and returns objects conforming to the `ATLParticipant` protocol whose `fullName` property contains the search text.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.participantDataSource participantsMatchingSearchText:searchText completion:^(NSSet *participants) {
        completion(participants);
    }];
}

#pragma mark - ATLConversationListViewControllerDataSource

/**
 Atlas - Returns a label that is used to represent the conversation. Atlas Messenger puts the name representing the `lastMessage.sentByUserID` property first in the string.
 */
- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    // If we have a Conversation name in metadata, return it.
    NSString *conversationTitle = conversation.metadata[ATLMConversationMetadataNameKey];
    if (conversationTitle.length) {
        return conversationTitle;
    }
    
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers minusSet:[NSSet setWithObject:self.layerClient.authenticatedUserID]];
    
    if (participantIdentifiers.count == 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[self.applicationController.persistenceManager usersForIdentifiers:participantIdentifiers] mutableCopy];
    if (participants.count == 0) return @"No Matching Participants";
    if (participants.count == 1) return [[participants allObjects][0] fullName];
    
    NSMutableArray *firstNames = [NSMutableArray new];
    [participants enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id<ATLParticipant> participant = obj;
        if (participant.firstName) {
            // Put the last message sender's name first
            if ([conversation.lastMessage.sender.userID isEqualToString:participant.participantIdentifier]) {
                [firstNames insertObject:participant.firstName atIndex:0];
            } else {
                [firstNames addObject:participant.firstName];
            }
        }
    }];
    NSString *firstNamesString = [firstNames componentsJoinedByString:@", "];
    return firstNamesString;
}

#pragma mark - Conversation Selection

// The following method handles presenting the correct `ATLMConversationViewController`, regardeless of the current state of the navigation stack.
- (void)presentControllerWithConversation:(LYRConversation *)conversation
{
    ATLMConversationViewController *existingConversationViewController = [self existingConversationViewController];
    if (existingConversationViewController && existingConversationViewController.conversation == conversation) {
        if (self.navigationController.topViewController == existingConversationViewController) return;
        [self.navigationController popToViewController:existingConversationViewController animated:YES];
        return;
    }
    
    BOOL shouldShowAddressBar = (conversation.participants.count > 2 || !conversation.participants.count);
    ATLMConversationViewController *conversationViewController = [ATLMConversationViewController conversationViewControllerWithLayerClient:self.applicationController.layerClient];
    conversationViewController.applicationController = self.applicationController;
    conversationViewController.displaysAddressBar = shouldShowAddressBar;
    conversationViewController.conversation = conversation;
    
    [self.applicationController.splitViewController setDetailViewController:conversationViewController];
}

#pragma mark - Actions

- (void)settingsButtonTapped
{
    ATLMSettingsViewController *settingsViewController = [[ATLMSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsViewController.applicationController = self.applicationController;
    settingsViewController.settingsDelegate = self;
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)composeButtonTapped
{
    [self presentControllerWithConversation:nil];
}

#pragma mark - Conversation Selection From Push Notification

- (void)selectConversation:(LYRConversation *)conversation
{
    if (conversation) {
        [self presentControllerWithConversation:conversation];
    }
}

#pragma mark - ATLMSettingsViewControllerDelegate

- (void)logoutTappedInSettingsViewController:(ATLMSettingsViewController *)settingsViewController
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    if (self.applicationController.layerClient.isConnected) {
        [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
            [SVProgressHUD dismiss];
        }];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Unable to logout. Layer is not connected"];
    }
}

- (void)settingsViewControllerDidFinish:(ATLMSettingsViewController *)settingsViewController
{
    [settingsViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Handlers

- (void)conversationDeleted:(NSNotification *)notification
{
    if (self.ATLM_navigationController.isAnimating) {
        [self.ATLM_navigationController notifyWhenCompletionEndsUsingBlock:^{
            [self conversationDeleted:notification];
        }];
        return;
    }
    
    ATLMConversationViewController *conversationViewController = [self existingConversationViewController];
    if (!conversationViewController) return;
    
    LYRConversation *deletedConversation = notification.object;
    if (![conversationViewController.conversation isEqual:deletedConversation]) return;
    
    [self.navigationController popToViewController:self animated:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Conversation Deleted"
                                                        message:@"The conversation has been deleted."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)conversationParticipantsDidChange:(NSNotification *)notification
{
    if (self.ATLM_navigationController.isAnimating) {
        [self.ATLM_navigationController notifyWhenCompletionEndsUsingBlock:^{
            [self conversationParticipantsDidChange:notification];
        }];
        return;
    }
    
    NSString *authenticatedUserID = self.applicationController.layerClient.authenticatedUserID;
    if (!authenticatedUserID) return;
    LYRConversation *conversation = notification.object;
    if ([conversation.participants containsObject:authenticatedUserID]) return;
    
    ATLMConversationViewController *conversationViewController = [self existingConversationViewController];
    if (!conversationViewController) return;
    if (![conversationViewController.conversation isEqual:conversation]) return;
    
    [self.navigationController popToViewController:self animated:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Removed From Conversation"
                                                        message:@"You have been removed from the conversation."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Helpers

- (ATLMConversationViewController *)existingConversationViewController
{
    if (!self.navigationController) return nil;
    
    NSUInteger listViewControllerIndex = [self.navigationController.viewControllers indexOfObject:self];
    if (listViewControllerIndex == NSNotFound) return nil;
    
    NSUInteger nextViewControllerIndex = listViewControllerIndex + 1;
    if (nextViewControllerIndex >= self.navigationController.viewControllers.count) return nil;
    
    id nextViewController = [self.navigationController.viewControllers objectAtIndex:nextViewControllerIndex];
    if (![nextViewController isKindOfClass:[ATLMConversationViewController class]]) return nil;
    
    return nextViewController;
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationDeleted:) name:ATLMConversationDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationParticipantsDidChange:) name:ATLMConversationParticipantsDidChangeNotification object:nil];
}

@end