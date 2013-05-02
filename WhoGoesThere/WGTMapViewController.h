//
//  WGTMapViewController.h
//  WhoGoesThere
//
//  Created by Dan Reife on 4/16/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "WGTTableViewController.h"
#import "WGTAppDelegate.h"
#import "WGTRecipientTableViewController.h"
#import "CyclicMutableArray.h"
#import "UserArea.h"


@interface WGTMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, FBViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UINavigationBar *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;

@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;

-(void)populateRecipients;
-(IBAction)compose:(UIStoryboardSegue *)segue;

@end
