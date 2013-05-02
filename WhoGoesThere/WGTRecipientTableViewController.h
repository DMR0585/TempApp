//
//  WGTRecipientTableViewController.h
//  WhoGoesThere
//
//  Created by Dan Reife on 4/16/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface WGTRecipientTableViewController : UITableViewController <UITableViewDataSource,
UITableViewDelegate, FBFriendPickerDelegate>

/*
- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker handleError:(NSError *)error;

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id <FBGraphUser>)user;

- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker;

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker;
*/
 
@end
