//
//  WGTMapViewController.m
//  WhoGoesThere
//
//  Created by Dan Reife on 4/16/13.
//  Copyright (c) 2013 Dan Reife. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "WGTMapViewController.h"


@interface WGTMapViewController ()

@end

@implementation WGTMapViewController

CyclicMutableArray *pins;
NSNumber *selectedPin;
BOOL selected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Get the locationManager from the AppDelegate, init if necessary
    WGTAppDelegate *delegate = (WGTAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (delegate.locationManager == nil) {
        delegate.locationManager = [[CLLocationManager alloc] init];
    }
    
    // Assign the locationManager's and mapView's delegates
    delegate.locationManager.delegate = self;
    self.mapView.delegate = self;
    
    // Update location if possible, otherwise request user to allow location updates
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        [self centerViewAtLocation:delegate.locationManager.location:NO];
        [delegate.locationManager startUpdatingLocation];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"To re-enable, please go to: \nSettings > Privacy > Location."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Set up the gesture recognizer for dropping a pin
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.delaysTouchesBegan = YES;
    longPressRecognizer.delaysTouchesEnded = YES;
    [self.mapView addGestureRecognizer:longPressRecognizer];
    
    //UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    //[self.mapView addGestureRecognizer:tapRecognizer];
    
    self.composeButton.action = @selector(populateRecipients);
    self.composeButton.target = self;
    
    // Set up the array of pins
    pins = [[CyclicMutableArray alloc] initWithCapacity:4];
    
    // None are selected
    selectedPin = nil;
    selected = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    selectedPin = [NSNumber numberWithInt:[view.annotation.subtitle intValue] - 1];
    //NSLog(@"didSelect pin (%@)",selectedPin);
    [self.mapView selectAnnotation:view.annotation animated:NO];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    //view.canShowCallout = NO;
    [self performSelector:@selector(hidePinInView:) withObject:view afterDelay:0.01];
}

- (void) hidePinInView: (MKAnnotationView *) view {
    [self.mapView deselectAnnotation:view.annotation animated:NO];
    //NSLog(@"didDeselect pin (%@)",selectedPin);
    selectedPin = nil;
}

#pragma mark - Map methods

- (void) centerViewAtLocation:(CLLocation *)location
                             :(BOOL)animated {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 7500, 7500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:animated];
}

- (void)addPinToMapAtCoordinate:(CLLocationCoordinate2D) coordinate {
    
    // Set up the new pin
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = coordinate;
    pin.title = @"Pin";
    NSString *number;
    
    // Adjust the number of each pin if you're going to replace the least recently added one
    if ([pins count] == 4) {
        for (MKPointAnnotation *p in pins) {
            NSInteger n = [p.subtitle integerValue];
            p.subtitle = [NSString stringWithFormat:@"%d",n - 1];
        }
        number = [NSString stringWithFormat:@"%d",4];
    }
    else {
        number = [NSString stringWithFormat:@"%d",[pins count] + 1];
    }
    
    pin.subtitle = number;
    if ([pins count] == 4) {
        [self.mapView removeAnnotation:[pins firstObject]];
    }
    [pins addObject:pin];
    [self.mapView addAnnotation:pin];
    
    //NSLog(@"Added pin (%@) and selected pin (%@)",number,selectedPin);
}

- (void)replacePinAtIndex:(NSNumber *)index
           WithCoordinate:(CLLocationCoordinate2D) coordinate {
    
    MKPointAnnotation *old = [pins objectAtIndex:[index unsignedIntegerValue]];
    MKPointAnnotation *replacement = [[MKPointAnnotation alloc] init];
    
    replacement.coordinate = coordinate;
    replacement.title = @"Pin";
    replacement.subtitle = old.subtitle;
    
    [pins replaceObjectAtIndex:[index unsignedIntegerValue] withObject:replacement];
    [self.mapView removeAnnotation:old];
    [self.mapView addAnnotation:replacement];
    //NSLog(@"Replaced pin (%@) and selected pin (%@)",index,selectedPin);
}

-(MKAnnotationView *)viewForPinWithCoordinate:(CLLocationCoordinate2D) coordinate {
    for (MKPointAnnotation *pin in pins) {
        if ((pin.coordinate.latitude == coordinate.latitude) && (pin.coordinate.longitude == coordinate.longitude)) {
            return [self.mapView viewForAnnotation:pin];
        }
    }
    return nil;
}

- (UserArea *) getArea {
    NSMutableArray *cs = [[NSMutableArray alloc] init];
    NSArray *pins = [self.mapView annotations];
    for (MKPointAnnotation *p in pins) {
        CLLocation *l = [[CLLocation alloc] initWithLatitude:p.coordinate.latitude longitude:p.coordinate.longitude];
        [cs addObject:l];
    }
    UserArea *area = [[UserArea alloc] initWithCoordinates:cs];
    return area;
}

-(void)handleLongPress:(UIGestureRecognizer*)sender
{
    // Get the coordinate for the touch
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Add a pin if none were selected
        if (selectedPin == nil) {
            [self addPinToMapAtCoordinate:coordinate];
        }
        else { // replace the selected pin
            [self replacePinAtIndex:selectedPin
                     WithCoordinate:coordinate];
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        // Deselect it
        MKAnnotationView *view = [self viewForPinWithCoordinate:coordinate];
        [self mapView:self.mapView didDeselectAnnotationView:view];
    }
}

#pragma mark - FBFriendPickerDelegate methods

- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker handleError:(NSError *)error {
    
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id <FBGraphUser>)user {
    UserArea *area = [self getArea];
    PFQuery *query = [PFUser query];
    NSArray *users = [query findObjects];
    for (PFUser *parseUser in users) {
        if ([area containsUser:parseUser] && [user.id isEqualToString:[parseUser objectForKey:@"FBid"]]) {
            return YES;
        }
    }
    return NO;
}

- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker {
    
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    
}

- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    NSLog(@"Friend selection cancelled.");
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    FBFriendPickerViewController *fpc = (FBFriendPickerViewController *)sender;
    [self composeMessageWithRecipients:fpc.selection];
    
    /*
    for (id <FBGraphUser> user in fpc.selection) {
        NSLog(@"Friend selected: %@", user.name);
    }
    [self dismissModalViewControllerAnimated:YES];
     */
}



-(IBAction)compose:(UIStoryboardSegue *)segue {
    
}


-(void)populateRecipients {
    NSLog(@"populate");
    if (!self.friendPickerController) {
        self.friendPickerController = [[FBFriendPickerViewController alloc]
                                       initWithNibName:nil bundle:nil];
        
        // Set the friend picker delegate
        self.friendPickerController.delegate = self;
        self.friendPickerController.title = @"Select friends";
    }
    
    [self.friendPickerController loadData];
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

-(void)composeMessageWithRecipients:(NSArray *)users {
    
    
    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] initWithRootViewController:[[UIApplication sharedApplication] delegate]];
    
}

@end
